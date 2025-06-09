import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart'; // Make sure this file is created in your project

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
      body: Stack(
        children: [
          // Curved header
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFBFBF6E),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'Hello, Admin',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Back icon (optional)
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Main content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 160, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/reharvest_logo.png',
                    height: 250,
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 30),

                  // Dashboard Buttons
                  _buildDashboardButton(context, 'Upload Data', '/upload'),
                  const SizedBox(height: 12),
                  _buildDashboardButton(context, 'View Data', '/view_data'),
                  const SizedBox(height: 12),
                  _buildDashboardButton(context, 'View Predictions', '/predictions'),
                  const SizedBox(height: 12),
                  _buildDashboardButton(context, 'Waste Management', '/waste'),
                  const SizedBox(height: 12),
                  _buildDashboardButton(context, 'Logout', '/'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String text, String route) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (route == '/') {
            // Logout: clear backstack and go to login
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A3B2A), // Dark brown
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: const Color(0xFFFFF3DC), // Light text
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
