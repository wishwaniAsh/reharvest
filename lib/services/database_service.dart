import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  static final DatabaseReference _databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://reharvest-efbda-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  // Save data to Firebase
  static Future<void> saveHarvestData(Map<String, dynamic> data) async {
    try {
      final newEntryRef = _databaseRef.child('harvest_data').push();
      await newEntryRef.set({
        ...data,
        'id': newEntryRef.key,
        'createdAt': DateTime.now().toIso8601String(),
      });
      print('Data saved successfully with ID: ${newEntryRef.key}');
    } catch (e) {
      print('Error saving data: $e');
      rethrow;
    }
  }

  // Get all data from Firebase
  static Future<List<Map<String, dynamic>>> getHarvestData() async {
    try {
      final snapshot = await _databaseRef.child('harvest_data').get();
      
      if (snapshot.exists) {
        final data = snapshot.value;
        
        if (data is Map) {
          List<Map<String, dynamic>> result = [];
          
          data.forEach((key, value) {
            if (value is Map) {
              result.add(Map<String, dynamic>.from(value));
            }
          });
          
          return result;
        }
      }
      return [];
    } catch (e) {
      print('Error loading data: $e');
      rethrow;
    }
  }

  // Get data by ID
  static Future<Map<String, dynamic>?> getDataById(String id) async {
    try {
      final snapshot = await _databaseRef.child('harvest_data').child(id).get();
      
      if (snapshot.exists) {
        final data = snapshot.value;
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } catch (e) {
      print('Error getting data by ID: $e');
      rethrow;
    }
  }
}