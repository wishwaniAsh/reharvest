import 'package:ReHarvest/pages/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'datareviewpage.dart';
import 'top_curve_clipper.dart';

class UploadDataPage extends StatefulWidget {
  const UploadDataPage({super.key});

  @override
  State<UploadDataPage> createState() => _UploadDataPageState();
}

class _UploadDataPageState extends State<UploadDataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController truckIdController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final List<String> vegetables = [
    'Cucumber', 'Leeks', 'Pumpkin', 'Eggplant', 'Yardlong bean', 'Potato',
    'Onion', 'Tomato', 'Cooking melons', 'Beetroot', 'Cabbage', 'Radish',
    'Carrot', 'Green beans', 'Okra', 'Garlic'
  ];
  String? selectedVegetable;

  // --- Helpers for Date/Time ---
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  String get formattedDate =>
      selectedDate == null
          ? "Select date"
          : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

  String get formattedTime =>
      selectedTime == null
          ? "Select time"
          : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

  // --- Widget build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
      body: Stack(
        children: [
          // Header
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFBFBF6E),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'Upload Data',
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Back button (pop route)
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          

          // Form content
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 180, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/reharvest_logo.png', height: 250),
                    const SizedBox(height: 16),

                    _buildInputField(truckIdController, 'Truck ID'),
                    const SizedBox(height: 12),

                    // Vegetable Autocomplete
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue value) {
                        if (value.text.isEmpty) return vegetables;
                        return vegetables.where((v) =>
                            v.toLowerCase().contains(value.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          selectedVegetable = selection;
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, _) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          style: GoogleFonts.montserrat(color: Colors.white),
                          decoration: _inputDecoration('Vegetable type'),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please select a vegetable'
                              : null,
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Material(
                          color: const Color(0xFFFFF3DC),
                          borderRadius: BorderRadius.circular(8),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: Color(0xFFBFBF6E)),
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(option,
                                    style: GoogleFonts.montserrat(
                                        color: Colors.black)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Quantity with limit validation
                    TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(color: Colors.white),
                      decoration: _inputDecoration('Quantity in kg (Must be 150-20000kg)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        final num? qty = num.tryParse(value);
                        if (qty == null) return 'Enter a valid number';
                        if (qty < 150 || qty > 20000) {
                          return 'Quantity must be 150–20000 kg';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Arrival Date
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration("Arrival Date").copyWith(
                            suffixIcon:
                                const Icon(Icons.calendar_today, color: Colors.white),
                          ),
                          controller: TextEditingController(text: formattedDate),
                          style: GoogleFonts.montserrat(color: Colors.white),
                          validator: (_) =>
                              selectedDate == null ? "Please select arrival date" : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Arrival Time
                    GestureDetector(
                      onTap: _pickTime,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _inputDecoration("Arrival Time").copyWith(
                            suffixIcon:
                                const Icon(Icons.access_time, color: Colors.white),
                          ),
                          controller: TextEditingController(text: formattedTime),
                          style: GoogleFonts.montserrat(color: Colors.white),
                          validator: (_) =>
                              selectedTime == null ? "Please select arrival time" : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFBF6E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              selectedVegetable != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewPage(data: {
                                  'truckId': truckIdController.text,
                                  'vegetable': selectedVegetable!,
                                  'quantity': quantityController.text,
                                  'date': formattedDate,
                                  'time': formattedTime,
                                }),
                              ),
                            );
                          } else if (selectedVegetable == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a vegetable')),
                            );
                          }
                        },
                        child: Text(
                          'Submit',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A3B2A),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- Reusable Input Decoration ---
  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.montserrat(color: Colors.white),
      decoration: _inputDecoration(hint),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $hint' : null,
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF4A3B2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}