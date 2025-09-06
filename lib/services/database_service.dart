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
                'id': key,
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

  // Get waste data for farm holders (pending and partially accepted)
  static Future<List<Map<String, dynamic>>> getAvailableWasteForFarmHolders() async {
    try {
      final snapshot = await _databaseRef.child('harvest_data').get();
      
      if (snapshot.exists) {
        final data = snapshot.value;
        
        if (data is Map) {
          List<Map<String, dynamic>> result = [];
          
          data.forEach((key, value) {
            if (value is Map) {
              final wasteData = Map<String, dynamic>.from(value);
              final status = wasteData['status'] ?? 'pending';
              
              // Only include pending or partially accepted waste
              if (status == 'pending' || status == 'partially_accepted') {
                final remainingWaste = wasteData['remainingWaste'] ?? wasteData['predictedWaste'] ?? 0;
                
                // Only include if there's remaining waste
                if (remainingWaste > 0) {
                  result.add({
                    ...wasteData,
                    'id': key,
                  });
                }
              }
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
      print('Error loading available waste: $e');
      rethrow;
    }
  }

  // Get accepted waste for a specific farm holder
  static Future<List<Map<String, dynamic>>> getAcceptedWasteForFarmHolder(String farmHolderId) async {
    try {
      final snapshot = await _databaseRef.child('farm_acceptances')
          .orderByChild('farmHolderId')
          .equalTo(farmHolderId)
          .get();
      
      if (snapshot.exists) {
        final data = snapshot.value;
        
        if (data is Map) {
          List<Map<String, dynamic>> result = [];
          
          data.forEach((key, value) {
            if (value is Map) {
              result.add({
                ...Map<String, dynamic>.from(value),
                'acceptanceId': key,
              });
            }
          });
          
          // Sort by timestamp descending (newest first)
          result.sort((a, b) {
            final aTime = DateTime.parse(a['timestamp'] ?? '2000-01-01');
            final bTime = DateTime.parse(b['timestamp'] ?? '2000-01-01');
            return bTime.compareTo(aTime);
          });
          
          return result;
        }
      }
      return [];
    } catch (e) {
      print('Error loading accepted waste: $e');
      rethrow;
    }
  }

  // Record farm holder acceptance
  static Future<void> recordFarmAcceptance(
    String wasteId, 
    String farmHolderId, 
    String farmHolderName,
    double acceptedAmount
  ) async {
    try {
      // Create a new acceptance record
      final newAcceptanceRef = _databaseRef.child('farm_acceptances').push();
      await newAcceptanceRef.set({
        'wasteId': wasteId,
        'farmHolderId': farmHolderId,
        'farmHolderName': farmHolderName,
        'acceptedAmount': acceptedAmount,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Update the waste record
      final wasteSnapshot = await _databaseRef.child('harvest_data').child(wasteId).get();
      
      if (wasteSnapshot.exists) {
        final wasteData = Map<String, dynamic>.from(wasteSnapshot.value as Map);
        final currentTotalAccepted = (wasteData['totalAccepted'] ?? 0).toDouble();
        final predictedWaste = (wasteData['predictedWaste'] ?? 0).toDouble();
        
        final newTotalAccepted = currentTotalAccepted + acceptedAmount;
        final remainingWaste = predictedWaste - newTotalAccepted;
        
        String newStatus = 'partially_accepted';
        if (remainingWaste <= 0) {
          newStatus = 'fully_accepted';
        }
        
        await _databaseRef.child('harvest_data').child(wasteId).update({
          'totalAccepted': newTotalAccepted,
          'remainingWaste': remainingWaste > 0 ? remainingWaste : 0,
          'status': newStatus,
        });
      }
      
      print('Farm acceptance recorded successfully');
    } catch (e) {
      print('Error recording farm acceptance: $e');
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

  // Get farm acceptances for a specific waste item
  static Future<List<Map<String, dynamic>>> getFarmAcceptancesForWaste(String wasteId) async {
    try {
      final snapshot = await _databaseRef.child('farm_acceptances')
          .orderByChild('wasteId')
          .equalTo(wasteId)
          .get();
      
      if (snapshot.exists) {
        final data = snapshot.value;
        List<Map<String, dynamic>> acceptances = [];
        
        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              acceptances.add(Map<String, dynamic>.from(value));
            }
          });
        }
        
        return acceptances;
      }
      return [];
    } catch (e) {
      print('Error loading farm acceptances: $e');
      rethrow;
    }
  }
}