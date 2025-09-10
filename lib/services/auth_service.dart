import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database;

  // Hardcoded super admin credentials
  static const String superAdminEmail = 'superadmin@gmail.com';
  static const String superAdminPassword = 'superadmin';

  AuthService() : _database = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: 'https://reharvest-efbda-default-rtdb.asia-southeast1.firebasedatabase.app'
        ).ref();

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
    String role,
  ) async {
    try {
      print('Attempting to register user: $email');
      
      // Check if registering as super admin (should not be allowed)
      if (email == superAdminEmail) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Cannot register with super admin email',
        );
      }

      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        print('User created successfully: ${user.uid}');
        
        // Save user data to Realtime Database with approval status
        await _saveUserDataToRealtimeDatabase(user.uid, email, username, role);
        
        // Update user profile with display name
        await user.updateDisplayName(username);
        
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('General Error during registration: $e');
      // Even if there's an error, check if user was created
      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == email) {
        // Try to save user data even if there was an error
        try {
          await _saveUserDataToRealtimeDatabase(currentUser.uid, email, username, role);
          await currentUser.updateDisplayName(username);
        } catch (dbError) {
          print('Error saving user data after registration: $dbError');
        }
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
      
      // Auto-approve non-admin roles, require approval for admins
      bool isApproved = role != 'Admin';
      
      // Use set() instead of update() to ensure all data is written
      await _database.child('users').child(uid).set({
        'uid': uid,
        'email': email,
        'username': username,
        'role': role,
        'approved': isApproved,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      print('User data saved to Realtime Database successfully');
      
      // Verify the data was saved
      final snapshot = await _database.child('users').child(uid).get();
      if (snapshot.exists) {
        print('Data verification successful: ${snapshot.value}');
      } else {
        print('Data verification failed: No data found');
        throw Exception('User data not saved to database');
      }
      
    } catch (e) {
      print('Realtime Database error: $e');
      print('Error type: ${e.runtimeType}');
      // Re-throw to handle in the UI
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Login with email and password - UPDATED FOR SUPER ADMIN
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      // Handle super admin login
      if (email == superAdminEmail && password == superAdminPassword) {
        try {
          // Try to sign in with Firebase
          UserCredential result = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          // Ensure super admin data exists in database
          await _ensureSuperAdminDataExists(result.user!);
          
          return result.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            // Super admin doesn't exist in auth, create it
            print('Super admin not found in auth, creating...');
            return await _createSuperAdminAccount();
          } else {
            // Re-throw other auth errors
            rethrow;
          }
        }
      } else {
        // Regular user login
        UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        return result.user;
      }
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

  // Create super admin account
  Future<User?> _createSuperAdminAccount() async {
    try {
      // Create super admin user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: superAdminEmail,
        password: superAdminPassword,
      );
      
      // Save super admin data to database
      await _database.child('users').child(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': superAdminEmail,
        'username': 'Super Admin',
        'role': 'Super Admin',
        'approved': true,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      print('Super admin account created successfully');
      return result.user;
    } catch (e) {
      print('Error creating super admin account: $e');
      rethrow;
    }
  }

  // Ensure super admin data exists in database
  Future<void> _ensureSuperAdminDataExists(User user) async {
    try {
      final snapshot = await _database.child('users').child(user.uid).get();
      
      if (!snapshot.exists) {
        print('Super admin data not found in database, creating it...');
        // Create super admin data
        await _database.child('users').child(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'username': 'Super Admin',
          'role': 'Super Admin',
          'approved': true,
          'createdAt': DateTime.now().toIso8601String(),
        });
        print('Super admin data created successfully');
      }
    } catch (e) {
      print('Error ensuring super admin data exists: $e');
      rethrow;
    }
  }

  // Get user data from Realtime Database
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _database.child('users').child(uid).get();
      
      if (snapshot.exists) {
        final data = snapshot.value;
        
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        } else {
          print('User data is not in expected Map format: $data');
          return null;
        }
      } else {
        print('No user data found for UID: $uid');
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      print('Full error: ${e.toString()}');
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

  // Check if user is approved
  Future<bool> isUserApproved(String uid) async {
    try {
      final userData = await getUserData(uid);
      return userData?['approved'] ?? false;
    } catch (e) {
      print('Error checking user approval status: $e');
      return false;
    }
  }

  // NEW: Check if user exists in database and create default data if missing
  Future<void> ensureUserDataExists(User user, {String defaultRole = 'Farmer'}) async {
    try {
      final snapshot = await _database.child('users').child(user.uid).get();
      
      if (!snapshot.exists) {
        print('User data not found in database, creating default data...');
        // Create default user data
        await _database.child('users').child(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'username': user.displayName ?? user.email!.split('@')[0],
          'role': defaultRole,
          'approved': defaultRole != 'Admin', // Auto-approve non-admins
          'createdAt': DateTime.now().toIso8601String(),
        });
        print('Default user data created successfully');
      }
    } catch (e) {
      print('Error ensuring user data exists: $e');
      rethrow;
    }
  }

  // Get all users (for super admin)
  Stream<DatabaseEvent> getAllUsers() {
    return _database.child('users').onValue;
  }

  // Approve admin user
  Future<void> approveAdmin(String uid) async {
    try {
      await _database.child('users').child(uid).update({
        'approved': true,
        'approvedAt': DateTime.now().toIso8601String(),
      });
      print('Admin $uid approved successfully');
    } catch (e) {
      print('Error approving admin: $e');
      rethrow;
    }
  }

  // Reject admin user (delete from database and auth)
  Future<void> rejectAdmin(String uid) async {
    try {
      // Delete from database
      await _database.child('users').child(uid).remove();
      print('Admin $uid rejected and removed from database');
      
      // Also delete the auth account if possible
      // Note: This requires recent authentication, might not always work
      try {
        User? userToDelete = _auth.currentUser;
        if (userToDelete != null && userToDelete.uid == uid) {
          await userToDelete.delete();
          print('Admin $uid also deleted from authentication');
        }
      } catch (e) {
        print('Could not delete admin from authentication: $e');
        // This is expected if we're not the currently logged in user
      }
    } catch (e) {
      print('Error rejecting admin: $e');
      rethrow;
    }
  }

  // Add this method to your AuthService class
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      
      // Handle specific error cases
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email address');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid');
      } else {
        throw Exception('Failed to send password reset email: ${e.message}');
      }
    } catch (e) {
      print('Error sending password reset email: $e');
      throw Exception('Failed to send password reset email');
    }
  }
}