import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ReHarvest/services/database_service.dart';
import 'top_curve_clipper.dart';
import 'detailpage.dart';

class ViewDataPage extends StatefulWidget {
  final List<Map<String, String>> allData;
  const ViewDataPage({super.key, required this.allData});

  @override
  State<ViewDataPage> createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<ViewDataPage> {
  List<Map<String, dynamic>> filteredData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDataFromFirebase();
  }

  Future<void> _loadDataFromFirebase() async {
    try {
      final data = await DatabaseService.getHarvestData();
      setState(() {
        filteredData = data;
      });
    } catch (e) {
      debugPrint('Error loading data from Firebase: $e');
      // Fallback to passed data if Firebase fails
      setState(() {
        filteredData = widget.allData.map((e) => e as Map<String, dynamic>).toList();
      });
    }
  }

  void _filterData(String query) {
    final data = filteredData.where((entry) {
      final truckId = entry['truckId']?.toString().toLowerCase() ?? '';
      final vegetable = entry['vegetable']?.toString().toLowerCase() ?? '';
      final dateTime = entry['dateTime']?.toString().toLowerCase() ?? '';
      final q = query.toLowerCase();
      return truckId.contains(q) || vegetable.contains(q) || dateTime.contains(q);
    }).toList();

    setState(() {
      filteredData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
      body: Stack(
        children: [
          Column(
            children: [
              ClipPath(
                clipper: TopCurveClipper(),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: const Color(0xFFBFBF6E),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
                  child: Text(
                    'View Data',
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  onChanged: _filterData,
                  decoration: InputDecoration(
                    hintText: 'Search by truck, vegetable, or date',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: filteredData.isEmpty
                    ? Center(
                        child: Text(
                          'No data found',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final entry = filteredData[index];
                          final truckId = entry['truckId']?.toString() ?? 'N/A';
                          final dateTime = entry['dateTime']?.toString() ?? 'N/A';
                          final vegetable = entry['vegetable']?.toString() ?? 'N/A';
                          final quantity = entry['quantity']?.toString() ?? 'N/A';
                          final predictedWaste = entry['predictedWaste']?.toString() ?? 'N/A';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(data: {
                                    'truckId': truckId,
                                    'vegetable': vegetable,
                                    'quantity': quantity,
                                    'dateTime': dateTime,
                                    'predictedWaste': predictedWaste,
                                  }),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A3B2A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Truck ID $truckId arrives at $dateTime',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Vegetable: $vegetable, Quantity: $quantity kg',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (predictedWaste != 'N/A')
                                    Text(
                                      'Predicted Waste: ${double.parse(predictedWaste).toStringAsFixed(1)} kg',
                                      style: GoogleFonts.montserrat(
                                        color: Colors.amber,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}