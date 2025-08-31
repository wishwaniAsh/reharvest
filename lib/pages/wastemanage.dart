import 'package:ReHarvest/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';

class WasteManagementPage extends StatefulWidget {
  const WasteManagementPage({super.key});

  @override
  State<WasteManagementPage> createState() => _WasteManagementPageState();
}

class _WasteManagementPageState extends State<WasteManagementPage> {
  List<Map<String, dynamic>> _wasteData = [];
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  String _selectedFilter = 'all'; // 'all', 'this_month', 'high_waste'

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    setState(() {
      _isLoading = true;
    });
    
    final data = await _notificationService.getWasteManagementData();
    setState(() {
      _wasteData = data;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredData {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'this_month':
        return _wasteData.where((item) {
          try {
            final timestamp = item['timestamp'];
            if (timestamp != null) {
              final date = DateTime.parse(timestamp);
              return date.year == now.year && date.month == now.month;
            }
          } catch (e) {
            debugPrint("Error parsing timestamp: $e");
          }
          return false;
        }).toList();
      
      case 'high_waste':
        return _wasteData.where((item) {
          final waste = item['predictedWaste'] ?? 0;
          final quantity = double.tryParse(item['quantity']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
          final wastePercentage = quantity > 0 ? (waste / quantity) * 100 : 0;
          return wastePercentage > 20; // More than 20% waste
        }).toList();
      
      default:
        return _wasteData;
    }
  }

  double _calculateTotalPredictedWaste() {
    return _filteredData.fold(0.0, (sum, item) {
      final waste = item['predictedWaste'] ?? 0;
      return sum + (waste is double ? waste : double.parse(waste.toString()));
    });
  }

  double _calculateTotalQuantity() {
    return _filteredData.fold(0.0, (sum, item) {
      final quantity = item['quantity'] ?? '0';
      final cleanQuantity = double.tryParse(quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return sum + cleanQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredData;
    final totalWaste = _calculateTotalPredictedWaste();
    final totalQuantity = _calculateTotalQuantity();
    final wastePercentage = totalQuantity > 0 ? (totalWaste / totalQuantity) * 100 : 0;

    return WillPopScope(
      onWillPop: () async {
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
        body: Column(
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

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                child: Column(
                  children: [
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('This Month', 'this_month'),
                          const SizedBox(width: 8),
                          _buildFilterChip('High Waste', 'high_waste'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistics card
                    Card(
                      color: const Color(0xFF4A3B2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Waste Management Overview',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Total Deliveries',
                                  filteredData.length.toString(),
                                  Icons.local_shipping,
                                ),
                                _buildStatItem(
                                  'Total Waste',
                                  '${totalWaste.toStringAsFixed(1)}kg',
                                  Icons.warning,
                                  color: Colors.orange,
                                ),
                                _buildStatItem(
                                  'Waste %',
                                  '${wastePercentage.toStringAsFixed(1)}%',
                                  Icons.analytics,
                                  color: wastePercentage > 20 ? Colors.red : Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Data list or loading/empty state
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4A3B2A),
                              ),
                            )
                          : filteredData.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No waste data available',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'Data will appear here when deliveries are confirmed',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredData.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredData[index];
                                    return _buildWasteItem(item);
                                  },
                                ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showWasteAnalysis,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A3B2A),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Waste Analysis',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loadWasteData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBFBF6E),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Refresh',
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF4A3B2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF4A3B2A) : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWasteItem(Map<String, dynamic> item) {
    final vegetable = item['vegetable'] ?? 'Unknown';
    final truckId = item['truckId'] ?? 'N/A';
    final quantity = item['quantity'] ?? '0';
    final predictedWaste = item['predictedWaste'] ?? 0;
    final dateTime = item['dateTime'] ?? '';
    final timestamp = item['timestamp'] ?? '';

    final cleanQuantity = double.tryParse(quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final wastePercentage = cleanQuantity > 0 ? (predictedWaste / cleanQuantity) * 100 : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF4A3B2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.local_shipping,
          color: Colors.white,
          size: 32,
        ),
        title: Text(
          '$vegetable • Truck $truckId',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$quantity kg delivered • ${_formatDate(dateTime)}',
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: wastePercentage > 20 ? Colors.orange : Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${predictedWaste.toStringAsFixed(1)}kg waste (${wastePercentage.toStringAsFixed(1)}%)',
                  style: GoogleFonts.montserrat(
                    color: wastePercentage > 20 ? Colors.orange : Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => _showItemDetails(item),
        ),
      ),
    );
  }

  String _formatDate(String dateTime) {
    try {
      final parts = dateTime.split(' ');
      if (parts.isNotEmpty) {
        return parts[0]; // Return just the date part
      }
    } catch (e) {
      debugPrint("Error formatting date: $e");
    }
    return dateTime;
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => WasteItemDetailsDialog(item: item),
    );
  }

  void _showWasteAnalysis() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WasteAnalysisSheet(wasteData: _wasteData),
    );
  }
}

class WasteItemDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> item;

  const WasteItemDetailsDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final vegetable = item['vegetable'] ?? 'Unknown';
    final truckId = item['truckId'] ?? 'N/A';
    final quantity = item['quantity'] ?? '0';
    final predictedWaste = item['predictedWaste'] ?? 0;
    final dateTime = item['dateTime'] ?? '';
    final timestamp = item['timestamp'] ?? '';

    final cleanQuantity = double.tryParse(quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final wastePercentage = cleanQuantity > 0 ? (predictedWaste / cleanQuantity) * 100 : 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Details',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            _buildDetailRow('Vegetable', vegetable),
            _buildDetailRow('Truck ID', truckId),
            _buildDetailRow('Quantity', '$quantity kg'),
            _buildDetailRow('Delivery Date', dateTime),
            _buildDetailRow(
              'Predicted Waste',
              '${predictedWaste.toStringAsFixed(1)} kg',
              valueColor: Colors.red,
            ),
            _buildDetailRow(
              'Waste Percentage',
              '${wastePercentage.toStringAsFixed(1)}%',
              valueColor: wastePercentage > 20 ? Colors.orange : Colors.green,
            ),
            
            if (timestamp.isNotEmpty)
              _buildDetailRow(
                'Recorded',
                _formatTimestamp(timestamp),
                valueColor: Colors.grey,
              ),
            
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3B2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class WasteAnalysisSheet extends StatelessWidget {
  final List<Map<String, dynamic>> wasteData;

  const WasteAnalysisSheet({super.key, required this.wasteData});

  @override
  Widget build(BuildContext context) {
    final totalWaste = wasteData.fold(0.0, (sum, item) {
      final waste = item['predictedWaste'] ?? 0;
      return sum + (waste is double ? waste : double.parse(waste.toString()));
    });

    final totalQuantity = wasteData.fold(0.0, (sum, item) {
      final quantity = item['quantity'] ?? '0';
      final cleanQuantity = double.tryParse(quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return sum + cleanQuantity;
    });

    final wastePercentage = totalQuantity > 0 ? (totalWaste / totalQuantity) * 100 : 0;

    // Group by vegetable
    final vegetableStats = <String, Map<String, double>>{};
    for (var item in wasteData) {
      final vegetable = item['vegetable'] ?? 'Unknown';
      final waste = item['predictedWaste'] ?? 0;
      final quantity = double.tryParse((item['quantity'] ?? '0').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      
      if (!vegetableStats.containsKey(vegetable)) {
        vegetableStats[vegetable] = {'waste': 0.0, 'quantity': 0.0};
      }
      
      vegetableStats[vegetable]!['waste'] = vegetableStats[vegetable]!['waste']! + waste;
      vegetableStats[vegetable]!['quantity'] = vegetableStats[vegetable]!['quantity']! + quantity;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Waste Analysis',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Overall statistics
          Card(
            color: const Color(0xFF4A3B2A),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Overall Statistics',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnalysisStat('Total Deliveries', wasteData.length.toString()),
                      _buildAnalysisStat('Total Quantity', '${totalQuantity.toStringAsFixed(1)}kg'),
                      _buildAnalysisStat('Total Waste', '${totalWaste.toStringAsFixed(1)}kg'),
                      _buildAnalysisStat('Waste %', '${wastePercentage.toStringAsFixed(1)}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Vegetable breakdown
          Text(
            'By Vegetable Type',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: vegetableStats.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: vegetableStats.length,
                    itemBuilder: (context, index) {
                      final vegetable = vegetableStats.keys.elementAt(index);
                      final stats = vegetableStats[vegetable]!;
                      final vegWastePercentage = stats['quantity']! > 0 
                          ? (stats['waste']! / stats['quantity']!) * 100 
                          : 0;
                      
                      return ListTile(
                        leading: const Icon(Icons.eco, color: Colors.green),
                        title: Text(vegetable),
                        subtitle: Text(
                          '${stats['waste']!.toStringAsFixed(1)}kg waste (${vegWastePercentage.toStringAsFixed(1)}%)',
                        ),
                        trailing: Text(
                          '${stats['quantity']!.toStringAsFixed(1)}kg',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}