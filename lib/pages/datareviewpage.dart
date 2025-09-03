import 'package:ReHarvest/services/database_service.dart';
import 'package:ReHarvest/services/notification_service.dart';
import 'package:ReHarvest/services/prediction_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';
import 'datapage.dart';

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
  late TextEditingController dateTimeController;
  
  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    truckIdController = TextEditingController(text: widget.data['truckId']);
    vegetableController = TextEditingController(text: widget.data['vegetable']);
    quantityController = TextEditingController(text: widget.data['quantity']);

    final date = widget.data['date'] ?? '';
    final time = widget.data['time'] ?? '';
    final dateTimeText = (date.isNotEmpty && time.isNotEmpty)
        ? "$date $time"
        : date.isNotEmpty
            ? date
            : time;

    dateTimeController = TextEditingController(text: dateTimeText);
  }

  @override
  void dispose() {
    truckIdController.dispose();
    vegetableController.dispose();
    quantityController.dispose();
    dateTimeController.dispose();
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
        ),
      ),
    );
  }

  String _extractMonthFromDateTime(String dateTime) {
    try {
      final parts = dateTime.split(' ');
      if (parts.isNotEmpty) {
        final datePart = parts[0];
        final dt = DateTime.parse(datePart);
        return months[dt.month - 1];
      }
    } catch (e) {
      debugPrint("Error extracting month: $e");
    }
    return 'January';
  }

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
                'Review',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
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
              onPressed: () => Navigator.pop(context),
            ),
          ),

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
                  
                  // Input fields with labels
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Truck ID:',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildEditableBox(truckIdController),
                  const SizedBox(height: 12),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Vegetable:',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildEditableBox(vegetableController),
                  const SizedBox(height: 12),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quantity (kg):',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildEditableBox(quantityController),
                  const SizedBox(height: 12),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Date & Time:',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildEditableBox(dateTimeController),
                  const SizedBox(height: 24),

                  // Confirm & Cancel buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4A3B2A),
                              ),
                            ),
                          );

                          try {
                            // Get prediction
                            final predictionService = PredictionService();
                            double predictedWaste = 0;
                            
                            try {
                              predictedWaste = await predictionService.getPrediction(
                                vegetableController.text,
                                _extractMonthFromDateTime(dateTimeController.text),
                                double.parse(quantityController.text.replaceAll(RegExp(r'[^0-9.]'), '')),
                              ).timeout(const Duration(seconds: 10));
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Prediction service unavailable. Please try again later.'),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 5),
                                ),
                              );
                              return;
                            }

                            // Prepare data for database
                            final dataToSave = {
                              'truckId': truckIdController.text,
                              'vegetable': vegetableController.text,
                              'quantity': quantityController.text,
                              'dateTime': dateTimeController.text,
                              'predictedWaste': predictedWaste,
                              'timestamp': DateTime.now().toIso8601String(),
                            };

                            // Save to database
                            await DatabaseService.saveHarvestData(dataToSave);

                            // Send notification
                            final notificationService = NotificationService();
                            await notificationService.sendToWasteManagement(dataToSave);

                            // Navigate to DataPage
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DataPage(
                                  allData: [
                                    {
                                      'truckId': truckIdController.text,
                                      'vegetable': vegetableController.text,
                                      'quantity': quantityController.text,
                                      'dateTime': dateTimeController.text,
                                    },
                                  ],
                                ),
                              ),
                            );
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Data submitted successfully! Waste prediction: ${predictedWaste.toStringAsFixed(1)}kg'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: Failed to submit data. $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFBF6E),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
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