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
        'status': data['status'] ?? 'pending',
        'totalAccepted': data['totalAccepted'] ?? 0.0,
        'remainingWaste': data['remainingWaste'] ?? data['predictedWaste'] ?? 0.0,
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
              result.add({
                ...Map<String, dynamic>.from(value),
                'id': key, // Add the Firebase ID
              });
            }
          });
          
          // Sort by timestamp descending (newest first)
          result.sort((a, b) {
            final aTime = DateTime.parse(a['timestamp'] ?? a['createdAt'] ?? '2000-01-01');
            final bTime = DateTime.parse(b['timestamp'] ?? b['createdAt'] ?? '2000-01-01');
            return bTime.compareTo(aTime);
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
          return {
            ...Map<String, dynamic>.from(data),
            'id': id,
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting data by ID: $e');
      rethrow;
    }
  }

  // Update waste status in Firebase
  static Future<void> updateWasteStatus(String id, Map<String, dynamic> updates) async {
    try {
      await _databaseRef.child('harvest_data').child(id).update(updates);
      print('Data updated successfully for ID: $id');
    } catch (e) {
      print('Error updating data: $e');
      rethrow;
    }
  }

  // Delete waste record from Firebase
  static Future<void> deleteWasteRecord(String id) async {
    try {
      await _databaseRef.child('harvest_data').child(id).remove();
      print('Data deleted successfully for ID: $id');
    } catch (e) {
      print('Error deleting data: $e');
      rethrow;
    }
  }
}