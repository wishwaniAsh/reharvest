import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';
import 'datapage.dart'; // Import your DataPage here

class ReviewPage extends StatefulWidget {
  final Map<String, String> data;
  const ReviewPage({super.key, required this.data});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late TextEditingController truckIdController;
  late TextEditingController vegetableController;
  late TextEditingController quantityController;
  late TextEditingController timeController;

  @override
  void initState() {
    super.initState();
    truckIdController = TextEditingController(text: widget.data['truckId']);
    vegetableController = TextEditingController(text: widget.data['vegetable']);
    quantityController = TextEditingController(text: widget.data['quantity']);
    timeController = TextEditingController(text: widget.data['time']);
  }

  @override
  void dispose() {
    truckIdController.dispose();
    vegetableController.dispose();
    quantityController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Widget _buildEditableBox(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.montserrat(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF4A3B2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                'Review',
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
              padding: const EdgeInsets.fromLTRB(24, 180, 24, 24),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/reharvest_logo.png',
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  _buildEditableBox(truckIdController),
                  const SizedBox(height: 12),
                  _buildEditableBox(vegetableController),
                  const SizedBox(height: 12),
                  _buildEditableBox(quantityController),
                  const SizedBox(height: 12),
                  _buildEditableBox(timeController),
                  const SizedBox(height: 24),

                  // Confirm & Cancel buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to DataPage with current data as a list
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataPage(
                                allData: [
                                  {
                                    'truckId': truckIdController.text,
                                    'vegetable': vegetableController.text,
                                    'quantity': quantityController.text,
                                    'time': timeController.text,
                                  },
                                ],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFBF6E),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A3B2A),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFBF6E),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A3B2A),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
