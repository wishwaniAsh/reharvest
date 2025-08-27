import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final ModalRoute? currentRoute = ModalRoute.of(context);
    final bool fromLogin = currentRoute?.settings.arguments == 'from_login';

    return WillPopScope(
      onWillPop: () async {
        if (fromLogin) {
          Navigator.pop(context); // Go back to login with filled form
        } else {
          Navigator.pop(context); // Go back to signup with filled form
        }
        return false;
      },
      child: Scaffold(
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
                  'Hello, Farmer',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Back icon
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (fromLogin) {
                    Navigator.pop(context); // back to login
                  } else {
                    Navigator.pop(context); // back to signup
                  }
                },
              ),
            ),

            // Main content (scrollable)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 160, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/reharvest_logo.png',
                        height: 220,
                      ),
                      const SizedBox(height: 30),

                      
                      const SizedBox(height: 12),
                      _buildDashboardButton(context, 'View Predictions', '/predictions'),
                      const SizedBox(height: 12),
                      _buildDashboardButton(context, 'Logout', '/login'),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context, String text, String route) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (route == '/login') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (Route<dynamic> route) => false,
              arguments: 'logout',
            );
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A3B2A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            color: const Color(0xFFFFF3DC),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
