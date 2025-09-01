// notification_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Keys for SharedPreferences
  static const String _wasteManagementDataKey = 'waste_management_data';
  static const String _farmAcceptancesKey = 'farm_acceptances';

  // Send data to waste management (from admin)
  Future<void> sendToWasteManagement(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = await getWasteManagementData();
    
    final wasteData = {
      ...data,
      'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      'totalAccepted': 0.0, // Total accepted by all farm holders
      'remainingWaste': data['predictedWaste'] ?? 0.0,
      'status': 'pending',
      'farmAcceptances': {}, // Store individual farm acceptances
    };
    
    currentData.insert(0, wasteData);
    await prefs.setString(_wasteManagementDataKey, jsonEncode(currentData));
  }

  // Farm holder accepts waste
  Future<void> acceptWaste(String wasteId, String farmHolderId, double acceptedAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final wasteData = await getWasteManagementData();
    
    final wasteIndex = wasteData.indexWhere((item) => item['timestamp'] == wasteId);
    
    if (wasteIndex != -1) {
      final wasteItem = wasteData[wasteIndex];
      final predictedWaste = wasteItem['predictedWaste'] ?? 0.0;
      
      // Initialize farmAcceptances if not exists
      if (wasteItem['farmAcceptances'] == null) {
        wasteItem['farmAcceptances'] = {};
      }
      
      // Update this farm holder's acceptance
      wasteItem['farmAcceptances'][farmHolderId] = acceptedAmount;
      
      // Calculate total accepted by all farm holders
      final totalAccepted = wasteItem['farmAcceptances'].values.fold(0.0, (sum, amount) => sum + amount);
      final remaining = predictedWaste - totalAccepted;
      
      wasteItem['totalAccepted'] = totalAccepted;
      wasteItem['remainingWaste'] = remaining > 0 ? remaining : 0;
      wasteItem['status'] = remaining > 0 ? 'partially_accepted' : 'fully_accepted';
      
      await prefs.setString(_wasteManagementDataKey, jsonEncode(wasteData));
      
      // Also update farm holder's personal acceptance record
      final farmAcceptances = await getFarmAcceptances();
      farmAcceptances[wasteId] = {
        'acceptedAmount': acceptedAmount,
        'timestamp': DateTime.now().toIso8601String(),
        'wasteData': wasteItem,
      };
      await prefs.setString(_farmAcceptancesKey, jsonEncode(farmAcceptances));
    }
  }

  // Admin sends remaining waste to compost
  Future<void> sendToCompost(String wasteId) async {
    final prefs = await SharedPreferences.getInstance();
    final wasteData = await getWasteManagementData();
    
    final wasteIndex = wasteData.indexWhere((item) => item['timestamp'] == wasteId);
    
    if (wasteIndex != -1) {
      wasteData[wasteIndex]['status'] = 'composted';
      wasteData[wasteIndex]['compostedAt'] = DateTime.now().toIso8601String();
      
      await prefs.setString(_wasteManagementDataKey, jsonEncode(wasteData));
    }
  }

  // Get waste management data for admin
  Future<List<Map<String, dynamic>>> getWasteManagementData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_wasteManagementDataKey);
    if (data == null) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Get farm holder's personal acceptances
  Future<Map<String, dynamic>> getFarmAcceptances() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_farmAcceptancesKey);
    if (data == null) return {};
    
    return Map<String, dynamic>.from(jsonDecode(data));
  }

  // Get notifications for farm holder (waste that needs acceptance)
  Future<List<Map<String, dynamic>>> getFarmHolderNotifications() async {
    final wasteData = await getWasteManagementData();
    final farmAcceptances = await getFarmAcceptances();
    
    // Return waste items that are pending or partially accepted
    return wasteData.where((item) {
      final status = item['status'] ?? 'pending';
      final wasteId = item['timestamp'];
      final alreadyAccepted = farmAcceptances.containsKey(wasteId);
      
      return (status == 'pending' || status == 'partially_accepted') && !alreadyAccepted;
    }).toList();
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wasteManagementDataKey);
    await prefs.remove(_farmAcceptancesKey);
  }

  Future<void> deleteCompostedRecord(String wasteId) async {}
}