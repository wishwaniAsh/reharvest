import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';

class WasteManagementPage extends StatelessWidget {
  const WasteManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Always navigate back to Admin Dashboard
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin_dashboard',
          (Route<dynamic> route) => false,
          arguments: 'back',
        );
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
                  'Waste Management',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/admin_dashboard',
                    (Route<dynamic> route) => false,
                    arguments: 'back',
                  );
                },
              ),
            ),

            // Page content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 160, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/reharvest_logo.png',
                        height: 180,
                      ),
                      const SizedBox(height: 30),

                      // Example cards for waste management actions
                      _buildCard(
                        title: "Track Waste",
                        description: "Monitor vegetable waste generated daily.",
                        icon: Icons.analytics,
                      ),
                      const SizedBox(height: 16),

                      _buildCard(
                        title: "Recycle / Compost",
                        description: "Send unusable waste to compost centers.",
                        icon: Icons.recycling,
                      ),
                      const SizedBox(height: 16),

                      _buildCard(
                        title: "Farmholder Distribution",
                        description: "Assign waste for farmholders as pig food.",
                        icon: Icons.agriculture,
                      ),
                      const SizedBox(height: 16),

                      _buildCard(
                        title: "Reports",
                        description: "View waste management history and reports.",
                        icon: Icons.insert_chart,
                      ),
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

  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF4A3B2A),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFFFF3DC), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFF3DC),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: const Color(0xFFFFF3DC),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
