import 'package:ReHarvest/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';

class FarmHolderDashboard extends StatefulWidget {
  final String farmHolderId;
  final String farmHolderName;

  const FarmHolderDashboard({
    super.key, 
    required this.farmHolderId,
    required this.farmHolderName
  });

  @override
  State<FarmHolderDashboard> createState() => _FarmHolderDashboardState();
}

class _FarmHolderDashboardState extends State<FarmHolderDashboard> {
  List<Map<String, dynamic>> _availableWaste = [];
  List<Map<String, dynamic>> _acceptedWaste = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0; // 0 for available, 1 for accepted

  @override
  void initState() {
    super.initState();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    setState(() => _isLoading = true);
    
    try {
      final available = await DatabaseService.getAvailableWasteForFarmHolders();
      final accepted = await DatabaseService.getAcceptedWasteForFarmHolder(widget.farmHolderId);
      
      setState(() {
        _availableWaste = available;
        _acceptedWaste = accepted;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading waste data: $e');
      setState(() => _isLoading = false);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data. Please check your internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _acceptWaste(Map<String, dynamic> wasteItem, double amount) async {
    try {
      await DatabaseService.recordFarmAcceptance(
        wasteItem['id'],
        widget.farmHolderId,
        widget.farmHolderName,
        amount
      );
      
      // Reload data
      await _loadWasteData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully accepted ${amount.toStringAsFixed(1)}kg of waste'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting waste: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Hello, ${widget.farmHolderName}',
                style: GoogleFonts.montserrat(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Back icon
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 160, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/reharvest_logo.png',
                    height: 150,
                  ),
                  const SizedBox(height: 20),

                  // Tab selection
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0 
                                    ? const Color(0xFF4A3B2A) 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Available Waste',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: _selectedTabIndex == 0 
                                      ? Colors.white 
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1 
                                    ? const Color(0xFF4A3B2A) 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'My Accepted Waste',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: _selectedTabIndex == 1 
                                      ? Colors.white 
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats card
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
                            _selectedTabIndex == 0 
                                ? 'Available Waste Summary' 
                                : 'My Accepted Waste',
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
                                _selectedTabIndex == 0 
                                    ? 'Available' 
                                    : 'Accepted',
                                _selectedTabIndex == 0 
                                    ? _availableWaste.length.toString() 
                                    : _acceptedWaste.length.toString(),
                                Icons.list,
                              ),
                              _buildStatItem(
                                'Total Quantity',
                                '${_calculateTotalQuantity().toStringAsFixed(1)}kg',
                                Icons.scale,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Waste list
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4A3B2A),
                            ),
                          )
                        : _selectedTabIndex == 0
                            ? _buildAvailableWasteList()
                            : _buildAcceptedWasteList(),
                  ),

                  const SizedBox(height: 20),

                  // Refresh button
                  ElevatedButton(
                    onPressed: _loadWasteData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBFBF6E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                ],
              ),
            ),
          ),
        ],
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

  double _calculateTotalQuantity() {
    if (_selectedTabIndex == 0) {
      return _availableWaste.fold(0.0, (sum, item) {
        final waste = item['remainingWaste'] ?? item['predictedWaste'] ?? 0;
        return sum + (waste is double ? waste : double.parse(waste.toString()));
      });
    } else {
      return _acceptedWaste.fold(0.0, (sum, item) {
        final waste = item['acceptedAmount'] ?? 0;
        return sum + (waste is double ? waste : double.parse(waste.toString()));
      });
    }
  }

  Widget _buildAvailableWasteList() {
    return _availableWaste.isEmpty
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
                  'No available waste',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'New waste deliveries will appear here',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _availableWaste.length,
            itemBuilder: (context, index) {
              final wasteItem = _availableWaste[index];
              return _buildAvailableWasteItem(wasteItem);
            },
          );
  }

  Widget _buildAvailableWasteItem(Map<String, dynamic> wasteItem) {
    final vegetable = wasteItem['vegetable'] ?? 'Unknown';
    final truckId = wasteItem['truckId'] ?? 'N/A';
    final quantity = wasteItem['quantity'] ?? '0';
    final predictedWaste = wasteItem['predictedWaste'] ?? 0;
    final totalAccepted = wasteItem['totalAccepted'] ?? 0;
    final remainingWaste = wasteItem['remainingWaste'] ?? predictedWaste;
    final dateTime = wasteItem['dateTime'] ?? '';
    final status = wasteItem['status'] ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFE8F5E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$vegetable • Truck $truckId',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'pending' ? Colors.orange : Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status == 'pending' ? 'New' : 'Partially Accepted',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Delivered: $dateTime',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Quantity: $quantity kg',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Predicted Waste: ${predictedWaste.toStringAsFixed(1)}kg',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Already Accepted: ${totalAccepted.toStringAsFixed(1)}kg',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Available: ${remainingWaste.toStringAsFixed(1)}kg',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAcceptDialog(wasteItem, remainingWaste),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3B2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Accept Waste',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedWasteList() {
    return _acceptedWaste.isEmpty
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
                  'No accepted waste yet',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Accepted waste will appear here',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _acceptedWaste.length,
            itemBuilder: (context, index) {
              final acceptance = _acceptedWaste[index];
              return _buildAcceptedWasteItem(acceptance);
            },
          );
  }

  Widget _buildAcceptedWasteItem(Map<String, dynamic> acceptance) {
    final acceptedAmount = acceptance['acceptedAmount'] ?? 0;
    final timestamp = acceptance['timestamp'] ?? '';
    final wasteId = acceptance['wasteId'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFE8F5E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waste Acceptance',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Accepted: ${_formatDate(timestamp)}',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ${acceptedAmount.toStringAsFixed(1)}kg',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder(
              future: DatabaseService.getDataById(wasteId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(color: Color(0xFF4A3B2A));
                }
                
                if (snapshot.hasData && snapshot.data != null) {
                  final wasteData = snapshot.data!;
                  final vegetable = wasteData['vegetable'] ?? 'Unknown';
                  final truckId = wasteData['truckId'] ?? 'N/A';
                  
                  return Text(
                    'From: $vegetable • Truck $truckId',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  );
                }
                
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(Map<String, dynamic> wasteItem, double remainingWaste) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Accept Waste',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available: ${remainingWaste.toStringAsFixed(1)}kg\nHow much can you accept?',
              style: GoogleFonts.montserrat(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.montserrat()),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(quantityController.text) ?? 0;
              if (amount > 0 && amount <= remainingWaste) {
                _acceptWaste(wasteItem, amount);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount between 0 and ${remainingWaste.toStringAsFixed(1)} kg'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A3B2A),
            ),
            child: Text('Accept', style: GoogleFonts.montserrat(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}