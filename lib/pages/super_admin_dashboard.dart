import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'top_curve_clipper.dart';
import '../services/auth_service.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final AuthService _authService = AuthService();
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://reharvest-efbda-default-rtdb.asia-southeast1.firebasedatabase.app'
  ).ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
      body: Stack(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFBFBF6E),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'Super Admin Dashboard',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 160, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Admin Approvals',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildPendingAdminsList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _authService.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A3B2A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: const Color(0xFFFFF3DC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAdminsList() {
    return StreamBuilder<DatabaseEvent>(
      stream: _dbRef.child('users').onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return Center(
            child: Text(
              'No users found',
              style: GoogleFonts.montserrat(),
            ),
          );
        }

        // Extract data from snapshot
        final usersData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
        
        if (usersData == null) {
          return Center(
            child: Text(
              'No users found',
              style: GoogleFonts.montserrat(),
            ),
          );
        }

        // Convert to list and filter for unapproved admin users
        final pendingAdmins = usersData.entries.where((entry) {
          final userData = entry.value as Map<dynamic, dynamic>;
          final role = userData['role']?.toString();
          final approved = userData['approved'];
          
          return role == 'Admin' && (approved == false || approved == null);
        }).toList();

        if (pendingAdmins.isEmpty) {
          return Center(
            child: Text(
              'No pending approvals',
              style: GoogleFonts.montserrat(),
            ),
          );
        }

        return ListView.builder(
          itemCount: pendingAdmins.length,
          itemBuilder: (context, index) {
            final userEntry = pendingAdmins[index];
            final userData = userEntry.value as Map<dynamic, dynamic>;
            final userId = userEntry.key as String;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  userData['username']?.toString() ?? 'No name',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  userData['email']?.toString() ?? 'No email',
                  style: GoogleFonts.montserrat(),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _approveAdmin(userId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _rejectAdmin(userId),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _approveAdmin(String uid) async {
    try {
      await _authService.approveAdmin(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin approved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving admin: $e')),
      );
    }
  }

  void _rejectAdmin(String uid) async {
    try {
      await _authService.rejectAdmin(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin rejected successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting admin: $e')),
      );
    }
  }
}