import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
    String role,
  ) async {
    try {
      print('Attempting to register user: $email');
      
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        print('User created successfully: ${user.uid}');
        
        // Save user data to Realtime Database
        await _saveUserDataToRealtimeDatabase(user.uid, email, username, role);
        
        // Update user profile with display name
        await user.updateDisplayName(username);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('General Error during registration: $e');
      // Even if there's an error, check if user was created
      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        return currentUser;
      }
      return null;
    }
  }

  Future<void> _saveUserDataToRealtimeDatabase(
    String uid,
    String email,
    String username,
    String role,
  ) async {
    try {
      print('Attempting to save user data to Realtime Database...');
      print('Path: users/$uid');
      print('Data: {uid: $uid, email: $email, username: $username, role: $role}');
      
      await _database.child('users').child(uid).set({
        'uid': uid,
        'email': email,
        'username': username,
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      print('User data saved to Realtime Database successfully');
      
      // Verify the data was saved
      final snapshot = await _database.child('users').child(uid).get();
      if (snapshot.exists) {
        print('Data verification successful: ${snapshot.value}');
      } else {
        print('Data verification failed: No data found');
      }
      
    } catch (e) {
      print('Realtime Database error: $e');
      print('Error type: ${e.runtimeType}');
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Login with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Add a small delay to work around the PigeonUserDetails bug
      await Future.delayed(const Duration(milliseconds: 100));
      
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Login Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      // Handle the PigeonUserDetails error specifically
      if (e.toString().contains('PigeonUserDetails')) {
        print('PigeonUserDetails error caught, but login was successful');
        // Even with this error, the user is usually logged in successfully
        return _auth.currentUser;
      }
      rethrow;
    }
  }

  // Get user data from Realtime Database
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _database.child('users').child(uid).get();
      if (snapshot.exists && snapshot.value != null) {
        // Handle cases where value might not be a Map
        if (snapshot.value is Map) {
          return Map<String, dynamic>.from(snapshot.value as Map);
        } else {
          print('User data is not in expected Map format: ${snapshot.value}');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get user role from database
  Future<String?> getUserRole(String uid) async {
    try {
      final userData = await getUserData(uid);
      return userData?['role'] as String?;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }
}