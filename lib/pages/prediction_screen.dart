import 'package:ReHarvest/services/prediction_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'top_curve_clipper.dart';

class PredictionScreen extends StatefulWidget {
  final Map<String, String>? initialData;

  const PredictionScreen({super.key, this.initialData});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final PredictionService _service = PredictionService();

  final List<String> vegetables = [
    'Cucumber',
    'Leeks',
    'Pumpkin',
    'Eggplant',
    'Yardlong bean',
    'Potato',
    'Onion',
    'Tomato',
    'Cooking melons',
    'Beetroot',
    'Cabbage',
    'Radish',
    'Carrot',
    'Green beans',
    'Okra',
    'Garlic'
  ];

  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  String? _selectedVegetable;
  String? _selectedMonth;

  final TextEditingController _quantityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  double? _predictedWaste;
  final List<Map<String, dynamic>> _trendData = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _selectedVegetable = data['vegetable'];
      _quantityController.text =
          data['quantity']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '';
      if (data['dateTime'] != null && data['dateTime']!.isNotEmpty) {
        try {
          final datePart = data['dateTime']!.split(" ")[0];
          final dt = DateTime.parse(datePart);
          _selectedMonth = months[dt.month - 1];
        } catch (_) {}
      }
    }
  }

  Future<void> _predictWaste() async {
    // Validate range first
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVegetable == null || _selectedMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select vegetable and month")),
      );
      return;
    }

    try {
      final qty = double.parse(_quantityController.text);
      final prediction =
          await _service.getPrediction(_selectedVegetable!, _selectedMonth!, qty);
      setState(() => _predictedWaste = prediction);
    } catch (e) {
      setState(() => _predictedWaste = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
      body: Stack(
        children: [
          /// header
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFBFBF6E),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                "Waste Prediction",
                style: GoogleFonts.montserrat(
                    fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),

          /// back
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/predict.png', height: 200),

                    _buildAutocomplete(
                      label: "Vegetable type",
                      options: vegetables,
                      initialValue: _selectedVegetable,
                      onSelected: (v) => setState(() => _selectedVegetable = v),
                    ),
                    const SizedBox(height: 16),

                    _buildAutocomplete(
                      label: "Select month",
                      options: months,
                      initialValue: _selectedMonth,
                      onSelected: (v) => setState(() => _selectedMonth = v),
                    ),
                    const SizedBox(height: 16),

                    /// quantity with validator
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.montserrat(color: Colors.white),
                      decoration:
                          _inputDecoration("Supply Quantity in kg (150–20000)"),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Enter quantity";
                        }
                        final num? n = num.tryParse(val);
                        if (n == null) return "Enter a valid number";
                        if (n < 150 || n > 20000) {
                          return "Quantity must be 150–20000 kg";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A3B2A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _predictWaste,
                      child: Text(
                        "Predict",
                        style: GoogleFonts.montserrat(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_predictedWaste != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF4A3B2A),
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          "Predicted Waste: ${_predictedWaste!.toStringAsFixed(2)} kg",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    const SizedBox(height: 24),

                    if (_trendData.isNotEmpty)
                      SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < _trendData.length) {
                                      return Text(
                                        _trendData[value.toInt()]['month']
                                            .substring(0, 3),
                                        style: GoogleFonts.montserrat(fontSize: 10),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _trendData.asMap().entries.map((e) {
                                  return FlSpot(e.key.toDouble(),
                                      e.value['waste'].toDouble());
                                }).toList(),
                                isCurved: true,
                                color: const Color(0xFF4A3B2A),
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
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

  /// shared autocomplete
  Widget _buildAutocomplete({
    required String label,
    required List<String> options,
    String? initialValue,
    required ValueChanged<String> onSelected,
  }) {
    final textController = TextEditingController(text: initialValue);
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initialValue ?? ""),
      optionsBuilder: (value) {
        if (value.text.isEmpty) return options;
        return options
            .where((opt) => opt.toLowerCase().contains(value.text.toLowerCase()));
      },
      onSelected: onSelected,
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
        fieldController.text = textController.text;
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          style: GoogleFonts.montserrat(color: Colors.white),
          decoration: _inputDecoration(label),
        );
      },
      optionsViewBuilder: (context, onSel, opts) {
        return Material(
          color: const Color(0xFFFFF3DC),
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: opts.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFBFBF6E)),
            itemBuilder: (context, i) {
              final option = opts.elementAt(i);
              return ListTile(
                title:
                    Text(option, style: GoogleFonts.montserrat(color: Colors.black)),
                onTap: () => onSel(option),
              );
            },
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF4A3B2A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );
}
