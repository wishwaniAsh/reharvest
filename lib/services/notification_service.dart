// notification_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Keys for SharedPreferences
  static const String _farmHolderDataKey = 'farm_holder_notifications';
  static const String _wasteManagementDataKey = 'waste_management_data';
  static const String _compostDataKey = 'compost_data';

  // Send data to farm holders
  Future<void> sendToFarmHolders(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = await getFarmHolderNotifications();
    
    final notificationData = {
      ...data,
      'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      'read': false,
      'acceptedWaste': 0.0, // Initially no waste accepted
      'remainingWaste': data['predictedWaste'] ?? 0.0, // Initially all waste remains
      'status': 'pending', // pending, partially_accepted, fully_accepted, composted
    };
    
    currentData.insert(0, notificationData);
    await prefs.setString(_farmHolderDataKey, jsonEncode(currentData));
  }

  // Send data to waste management
  Future<void> sendToWasteManagement(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = await getWasteManagementData();
    
    final wasteData = {
      ...data,
      'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      'acceptedWaste': 0.0,
      'remainingWaste': data['predictedWaste'] ?? 0.0,
      'status': 'pending',
    };
    
    currentData.insert(0, wasteData);
    await prefs.setString(_wasteManagementDataKey, jsonEncode(currentData));
  }

  // Farm holder accepts waste
  Future<void> acceptWaste(int index, double acceptedAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getFarmHolderNotifications();
    
    if (index < notifications.length) {
      final predictedWaste = notifications[index]['predictedWaste'] ?? 0.0;
      final remaining = predictedWaste - acceptedAmount;
      
      notifications[index]['acceptedWaste'] = acceptedAmount;
      notifications[index]['remainingWaste'] = remaining > 0 ? remaining : 0;
      notifications[index]['status'] = remaining > 0 ? 'partially_accepted' : 'fully_accepted';
      notifications[index]['read'] = true;
      
      await prefs.setString(_farmHolderDataKey, jsonEncode(notifications));
      
      // Also update waste management data
      final wasteData = await getWasteManagementData();
      final matchingIndex = wasteData.indexWhere((item) => 
          item['timestamp'] == notifications[index]['timestamp']);
      
      if (matchingIndex != -1) {
        wasteData[matchingIndex]['acceptedWaste'] = acceptedAmount;
        wasteData[matchingIndex]['remainingWaste'] = remaining > 0 ? remaining : 0;
        wasteData[matchingIndex]['status'] = remaining > 0 ? 'partially_accepted' : 'fully_accepted';
        await prefs.setString(_wasteManagementDataKey, jsonEncode(wasteData));
      }
    }
  }

  // Admin sends remaining waste to compost
  Future<void> sendToCompost(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final wasteData = await getWasteManagementData();
    
    if (index < wasteData.length) {
      wasteData[index]['status'] = 'composted';
      wasteData[index]['compostedAt'] = DateTime.now().toIso8601String();
      
      await prefs.setString(_wasteManagementDataKey, jsonEncode(wasteData));
      
      // Add to compost history
      final compostData = await getCompostData();
      compostData.add(wasteData[index]);
      await prefs.setString(_compostDataKey, jsonEncode(compostData));
    }
  }

  // Admin deletes composted record
  Future<void> deleteCompostedRecord(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final wasteData = await getWasteManagementData();
    
    if (index < wasteData.length && wasteData[index]['status'] == 'composted') {
      wasteData.removeAt(index);
      await prefs.setString(_wasteManagementDataKey, jsonEncode(wasteData));
    }
  }

  // Get farm holder notifications
  Future<List<Map<String, dynamic>>> getFarmHolderNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_farmHolderDataKey);
    if (data == null) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Get waste management data
  Future<List<Map<String, dynamic>>> getWasteManagementData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_wasteManagementDataKey);
    if (data == null) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Get compost data
  Future<List<Map<String, dynamic>>> getCompostData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_compostDataKey);
    if (data == null) return [];
    
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Mark notification as read
  Future<void> markAsRead(int index) async {
    final notifications = await getFarmHolderNotifications();
    if (index < notifications.length) {
      notifications[index]['read'] = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_farmHolderDataKey, jsonEncode(notifications));
    }
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_farmHolderDataKey);
    await prefs.remove(_wasteManagementDataKey);
    await prefs.remove(_compostDataKey);
  }
}