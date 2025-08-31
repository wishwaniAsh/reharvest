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

  // Send data to farm holders
  Future<void> sendToFarmHolders(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = await getFarmHolderNotifications();
    
    // Add timestamp
    final notificationData = {
      ...data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    };
    
    currentData.insert(0, notificationData); // Add to beginning of list
    
    await prefs.setString(_farmHolderDataKey, jsonEncode(currentData));
  }

  // Send data to waste management
  Future<void> sendToWasteManagement(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentData = await getWasteManagementData();
    
    currentData.insert(0, data); // Add to beginning of list
    
    await prefs.setString(_wasteManagementDataKey, jsonEncode(currentData));
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
  }
}