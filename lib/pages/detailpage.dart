import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';
import 'prediction_screen.dart';

class DetailPage extends StatelessWidget {
  final Map<String, String> data;
  const DetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final truckId = data['truckId'] ?? 'N/A';
    final vegetable = data['vegetable'] ?? 'N/A';
    final quantity = data['quantity'] ?? 'N/A';
    final dateTime = data['dateTime'] ?? 'N/A';
    final predictedWaste = data['predictedWaste'] ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
      body: Stack(
        children: [
          // Top header
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFBFBF6E),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'Data Details',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
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
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Main content
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/reharvest_logo.png',
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3B2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Truck ID: $truckId',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arrival Time: $dateTime',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vegetable: $vegetable',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quantity: $quantity kg',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        if (predictedWaste != 'N/A') ...[
                          const SizedBox(height: 8),
                          Text(
                            'Predicted Waste: ${double.parse(predictedWaste).toStringAsFixed(1)} kg',
                            style: GoogleFonts.montserrat(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PredictionScreen(initialData: data),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBFBF6E),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View waste prediction',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A3B2A),
                        fontSize: 16,
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
}