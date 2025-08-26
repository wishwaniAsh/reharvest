import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'top_curve_clipper.dart';
import 'detailpage.dart';

class ViewDataPage extends StatefulWidget {
  final List<Map<String, String>> allData;
  const ViewDataPage({super.key, required this.allData});

  @override
  State<ViewDataPage> createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<ViewDataPage> {
  List<Map<String, String>> filteredData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAndMergeData();
  }

  // Load saved data and merge with new data
  Future<void> _loadAndMergeData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved data
    final savedData = prefs.getString('allData');
    List<Map<String, String>> storedData = [];
    if (savedData != null) {
      final List<dynamic> decoded = jsonDecode(savedData);
      storedData = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    // Merge with new data passed from DataPage
    final allMerged = [...storedData, ...widget.allData];

    // Remove duplicates using truckId + dateTime as key
    final uniqueData = {for (var e in allMerged) '${e['truckId']}_${e['dateTime']}': e}.values.toList();

    // Save merged data permanently
    await prefs.setString('allData', jsonEncode(uniqueData));

    setState(() {
      filteredData = uniqueData;
    });
  }

  // Filter data based on search query
  void _filterData(String query) {
    final data = filteredData.where((entry) {
      final truckId = entry['truckId']?.toLowerCase() ?? '';
      final vegetable = entry['vegetable']?.toLowerCase() ?? '';
      final dateTime = entry['dateTime']?.toLowerCase() ?? '';
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
              // Top curved header
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

              // Search bar
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

              // Data list
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
                          final truckId = entry['truckId'] ?? 'N/A';
                          final dateTime = entry['dateTime'] ?? 'N/A';
                          final vegetable = entry['vegetable'] ?? 'N/A';
                          final quantity = entry['quantity'] ?? 'N/A';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(data: entry),
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
                              child: Text(
                                'Truck ID $truckId arrives at $dateTime with $vegetable $quantity kg.',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
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
        ],
      ),
    );
  }
}
