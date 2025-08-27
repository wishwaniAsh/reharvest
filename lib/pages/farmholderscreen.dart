import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';

class FarmHolderDashboard extends StatelessWidget {
  const FarmHolderDashboard({super.key});

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
                'Hello, Farm Holder',
                style: GoogleFonts.montserrat(
                  fontSize: 23,
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
      // Replace current screen with login
       Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

                    // Welcome message
                    Text(
                      'We appreciate your contribution in\ncaring for animals with reharvested food.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Maybe a subtle motivational tagline
                    Text(
                      '"Turning waste into care for your animals."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.brown.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}