import 'package:ReHarvest/services/database_service.dart';
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
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final data = await DatabaseService.getHarvestData();
      setState(() {
        _wasteData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading waste data from Firebase: $e');
      // Fallback to notification service if Firebase fails
      try {
        final notificationData = await NotificationService().getWasteManagementData();
        setState(() {
          _wasteData = notificationData;
          _isLoading = false;
        });
      } catch (e2) {
        print('Error loading from notification service: $e2');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredData {
    switch (_selectedFilter) {
      case 'pending':
        return _wasteData.where((item) => item['status'] == 'pending').toList();
      case 'accepted':
        return _wasteData.where((item) => 
          item['status'] == 'partially_accepted' || item['status'] == 'fully_accepted').toList();
      case 'composted':
        return _wasteData.where((item) => item['status'] == 'composted').toList();
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

  double _calculateTotalAcceptedWaste() {
    return _filteredData.fold(0.0, (sum, item) {
      final waste = item['totalAccepted'] ?? 0;
      return sum + (waste is double ? waste : double.parse(waste.toString()));
    });
  }

  double _calculateTotalRemainingWaste() {
    return _filteredData.fold(0.0, (sum, item) {
      final waste = item['remainingWaste'] ?? 0;
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

  Future<void> _sendToCompost(String wasteId) async {
    try {
      await DatabaseService.updateWasteStatus(wasteId, {
        'status': 'composted',
        'compostedAt': DateTime.now().toIso8601String(),
      });
      await _loadWasteData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Remaining waste sent to compost successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending to compost: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteComposted(String wasteId) async {
    try {
      await DatabaseService.deleteWasteRecord(wasteId);
      await _loadWasteData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Composted record deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _filteredData;
    final totalPredicted = _calculateTotalPredictedWaste();
    final totalAccepted = _calculateTotalAcceptedWaste();
    final totalRemaining = _calculateTotalRemainingWaste();
    final totalQuantity = _calculateTotalQuantity();
    final wastePercentage = totalQuantity > 0 ? (totalPredicted / totalQuantity) * 100 : 0;

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

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  children: [
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Pending', 'pending'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Accepted', 'accepted'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Composted', 'composted'),
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
                                  'Total',
                                  filteredData.length.toString(),
                                  Icons.list,
                                ),
                                _buildStatItem(
                                  'Predicted',
                                  '${totalPredicted.toStringAsFixed(1)}kg',
                                  Icons.warning,
                                  color: Colors.orange,
                                ),
                                _buildStatItem(
                                  'Accepted',
                                  '${totalAccepted.toStringAsFixed(1)}kg',
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                _buildStatItem(
                                  'Remaining',
                                  '${totalRemaining.toStringAsFixed(1)}kg',
                                  Icons.recycling,
                                  color: Colors.blue,
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
    final totalAccepted = item['totalAccepted'] ?? 0;
    final remainingWaste = item['remainingWaste'] ?? predictedWaste;
    final status = item['status'] ?? 'pending';
    final dateTime = item['dateTime'] ?? '';
    final wasteId = item['id'] ?? '';

    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;
    String statusText = 'Pending Acceptance';

    if (status == 'partially_accepted') {
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle_outline;
      statusText = 'Partially Accepted';
    } else if (status == 'fully_accepted') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Fully Accepted';
    } else if (status == 'composted') {
      statusColor = Colors.purple;
      statusIcon = Icons.recycling;
      statusText = 'Composted';
    }

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
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: GoogleFonts.montserrat(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              'Predicted: ${predictedWaste.toStringAsFixed(1)}kg • '
              'Accepted: ${totalAccepted.toStringAsFixed(1)}kg • '
              'Remaining: ${remainingWaste.toStringAsFixed(1)}kg',
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status != 'composted' && remainingWaste > 0)
              IconButton(
                icon: const Icon(Icons.recycling, color: Colors.green, size: 24),
                onPressed: () => _showCompostConfirmation(wasteId),
                tooltip: 'Send to compost',
              ),
            if (status == 'composted')
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                onPressed: () => _showDeleteConfirmation(wasteId),
                tooltip: 'Delete composted record',
              ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
              onPressed: () => _showItemDetails(item),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateTime) {
    try {
      final parts = dateTime.split(' ');
      if (parts.isNotEmpty) {
        return parts[0];
      }
    } catch (e) {
      debugPrint("Error formatting date: $e");
    }
    return dateTime;
  }

  void _showCompostConfirmation(String wasteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Send to Compost',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to send the remaining waste to compost?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.montserrat()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _sendToCompost(wasteId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A3B2A),
            ),
            child: Text('Confirm', style: GoogleFonts.montserrat(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String wasteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Record',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this composted record? This action cannot be undone.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.montserrat()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteComposted(wasteId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete', style: GoogleFonts.montserrat(color: Colors.white)),
          ),
        ],
      ),
    );
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
    final totalAccepted = item['totalAccepted'] ?? 0;
    final remainingWaste = item['remainingWaste'] ?? predictedWaste;
    final status = item['status'] ?? 'pending';
    final dateTime = item['dateTime'] ?? '';
    final timestamp = item['timestamp'] ?? '';
    final compostedAt = item['compostedAt'] ?? '';

    Color statusColor = Colors.orange;
    String statusText = 'Pending Acceptance';

    if (status == 'partially_accepted') {
      statusColor = Colors.blue;
      statusText = 'Partially Accepted';
    } else if (status == 'fully_accepted') {
      statusColor = Colors.green;
      statusText = 'Fully Accepted';
    } else if (status == 'composted') {
      statusColor = Colors.purple;
      statusText = 'Composted';
    }

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
              'Accepted Waste',
              '${totalAccepted.toStringAsFixed(1)} kg',
              valueColor: Colors.green,
            ),
            _buildDetailRow(
              'Remaining Waste',
              '${remainingWaste.toStringAsFixed(1)} kg',
              valueColor: Colors.orange,
            ),
            _buildDetailRow(
              'Status',
              statusText,
              valueColor: statusColor,
            ),
            
            if (timestamp.isNotEmpty)
              _buildDetailRow(
                'Received',
                _formatTimestamp(timestamp),
                valueColor: Colors.grey,
              ),
            
            if (compostedAt.isNotEmpty)
              _buildDetailRow(
                'Composted At',
                _formatTimestamp(compostedAt),
                valueColor: Colors.purple,
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
    final totalPredicted = wasteData.fold(0.0, (sum, item) {
      final waste = item['predictedWaste'] ?? 0;
      return sum + (waste is double ? waste : double.parse(waste.toString()));
    });

    final totalAccepted = wasteData.fold(0.0, (sum, item) {
      final waste = item['totalAccepted'] ?? 0;
      return sum + (waste is double ? waste : double.parse(waste.toString()));
    });

    final totalRemaining = wasteData.fold(0.0, (sum, item) {
      final waste = item['remainingWaste'] ?? 0;
      return sum + (waste is double ? waste : double.parse(waste.toString()));
    });

    final totalQuantity = wasteData.fold(0.0, (sum, item) {
      final quantity = item['quantity'] ?? '0';
      final cleanQuantity = double.tryParse(quantity.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return sum + cleanQuantity;
    });

    final wastePercentage = totalQuantity > 0 ? (totalPredicted / totalQuantity) * 100 : 0;
    final acceptanceRate = totalPredicted > 0 ? (totalAccepted / totalPredicted) * 100 : 0;

    // Group by vegetable
    final vegetableStats = <String, Map<String, double>>{};
    for (var item in wasteData) {
      final vegetable = item['vegetable'] ?? 'Unknown';
      final predicted = item['predictedWaste'] ?? 0;
      final accepted = item['totalAccepted'] ?? 0;
      final remaining = item['remainingWaste'] ?? 0;
      
      if (!vegetableStats.containsKey(vegetable)) {
        vegetableStats[vegetable] = {'predicted': 0.0, 'accepted': 0.0, 'remaining': 0.0};
      }
      
      vegetableStats[vegetable]!['predicted'] = vegetableStats[vegetable]!['predicted']! + predicted;
      vegetableStats[vegetable]!['accepted'] = vegetableStats[vegetable]!['accepted']! + accepted;
      vegetableStats[vegetable]!['remaining'] = vegetableStats[vegetable]!['remaining']! + remaining;
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
                      _buildAnalysisStat('Total', wasteData.length.toString()),
                      _buildAnalysisStat('Predicted', '${totalPredicted.toStringAsFixed(1)}kg'),
                      _buildAnalysisStat('Accepted', '${totalAccepted.toStringAsFixed(1)}kg'),
                      _buildAnalysisStat('Remaining', '${totalRemaining.toStringAsFixed(1)}kg'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnalysisStat('Waste %', '${wastePercentage.toStringAsFixed(1)}%'),
                      _buildAnalysisStat('Acceptance', '${acceptanceRate.toStringAsFixed(1)}%'),
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
                      final acceptanceRate = stats['predicted']! > 0 
                          ? (stats['accepted']! / stats['predicted']!) * 100 
                          : 0;
                      
                      return ListTile(
                        leading: const Icon(Icons.eco, color: Colors.green),
                        title: Text(vegetable),
                        subtitle: Text(
                          'Predicted: ${stats['predicted']!.toStringAsFixed(1)}kg • '
                          'Accepted: ${stats['accepted']!.toStringAsFixed(1)}kg • '
                          'Remaining: ${stats['remaining']!.toStringAsFixed(1)}kg',
                          style: GoogleFonts.montserrat(fontSize: 12),
                        ),
                        trailing: Text(
                          '${acceptanceRate.toStringAsFixed(0)}%',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: acceptanceRate > 50 ? Colors.green : Colors.orange,
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
            fontSize: 12,
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