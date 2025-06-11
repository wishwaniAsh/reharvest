import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController arrivalTimeController = TextEditingController();
  final List<String> vegetables = [
    'Cucumber', 'Leeks', 'Pumpkin', 'Eggplant', 'Yardlong bean', 'Potato', 'Onion',
    'Tomato', 'Cooking melons', 'Beetroot', 'Cabbage', 'Radish', 'Carrot', 'Green beans',
    'Okra', 'Garlic'
  ];

  String? selectedVegetable;
  List<String> filteredVegetables = [];

  @override
  void initState() {
    super.initState();
    filteredVegetables = vegetables;
  }

  void filterVegetables(String query) {
    setState(() {
      filteredVegetables = vegetables
          .where((veg) => veg.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                'Upload Data',
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/reharvest_logo.png',
                      height: 250,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(truckIdController, 'Truck ID'),
                    const SizedBox(height: 12),

                    // Vegetable Dropdown
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return vegetables;
                        }
                        return vegetables.where((String option) =>
                            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        selectedVegetable = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: _inputDecoration('Vegetable type'),
                          style: GoogleFonts.montserrat(color: Colors.white),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please select a vegetable' : null,
                          onChanged: (val) => filterVegetables(val),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Material(
                          color: const Color(0xFFFFF3DC),
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFBFBF6E)),
                            itemBuilder: (context, index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(option, style: GoogleFonts.montserrat(color: Colors.black)),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    _buildInputField(quantityController, 'Quantity'),
                    const SizedBox(height: 12),
                    _buildInputField(arrivalTimeController, 'Arrival time'),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data submitted successfully!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFBF6E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.montserrat(color: Colors.white),
      decoration: _inputDecoration(hint),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $hint' : null,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
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
}
