import 'package:ReHarvest/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'top_curve_clipper.dart';

class FarmHolderDashboard extends StatefulWidget {
  final String farmHolderId;

  const FarmHolderDashboard({super.key, required this.farmHolderId});

  @override
  State<FarmHolderDashboard> createState() => _FarmHolderDashboardState();
}

class _FarmHolderDashboardState extends State<FarmHolderDashboard> {
  List<Map<String, dynamic>> _notifications = [];
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  final String _farmHolderId = Uuid().v4(); // Unique ID for this farm holder

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications = await _notificationService.getFarmHolderNotifications();
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  int get _unreadCount {
    return _notifications.length;
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
                'Hello, Farm Holder',
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

          // Notification badge
          Positioned(
            top: 40,
            right: 20,
            child: _unreadCount > 0
                ? Badge(
                    label: Text(
                      _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.black, size: 28),
                      onPressed: _showNotifications,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black, size: 28),
                    onPressed: _showNotifications,
                  ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 160, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/reharvest_logo.png',
                      height: 180,
                    ),
                    const SizedBox(height: 20),

                    // Welcome message
                    Text(
                      'We appreciate your contribution in\ncaring for animals with reharvested food.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Loading indicator or stats
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4A3B2A),
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Quick stats card
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
                                    'Available Waste',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem(
                                        'Available',
                                        _notifications.length.toString(),
                                        Icons.local_shipping,
                                      ),
                                      _buildStatItem(
                                        'Total Waste',
                                        '${_calculateTotalWaste().toStringAsFixed(1)}kg',
                                        Icons.warning,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Available waste deliveries
                          if (_notifications.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Waste Deliveries',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._notifications.map((notification) => 
                                  _buildDeliveryPreview(notification)
                                ).toList(),
                              ],
                            )
                          else
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                Icon(
                                  Icons.inbox,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No waste available',
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
                        ],
                      ),

                    const SizedBox(height: 20),

                    // View accepted waste button
                    ElevatedButton(
                      onPressed: _showAcceptedWaste,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A3B2A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View My Accepted Waste',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Motivational tagline
                    Text(
                      '"Turning waste into care for your animals."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.brown.shade700,
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

  double _calculateTotalWaste() {
    return _notifications.fold(0.0, (sum, item) {
      final waste = item['predictedWaste'] ?? 0;
      return sum + (waste is double ? waste : double.parse(waste.toString()));
    });
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryPreview(Map<String, dynamic> notification) {
    final vegetable = notification['vegetable'] ?? 'Unknown';
    final truckId = notification['truckId'] ?? 'N/A';
    final quantity = notification['quantity'] ?? '0';
    final predictedWaste = notification['predictedWaste'] ?? 0;
    final totalAccepted = notification['totalAccepted'] ?? 0;
    final remainingWaste = notification['remainingWaste'] ?? predictedWaste;
    final dateTime = notification['dateTime'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFE8F5E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.local_shipping,
          color: const Color(0xFF4A3B2A),
          size: 32,
        ),
        title: Text(
          '$vegetable Delivery',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Truck $truckId • $quantity kg',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            if (predictedWaste > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available waste: ${remainingWaste.toStringAsFixed(1)}kg',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (totalAccepted > 0)
                    Text(
                      'Already accepted by others: ${totalAccepted.toStringAsFixed(1)}kg',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: () => _showAcceptDialog(notification),
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationList(
        notifications: _notifications,
        onAcceptWaste: (notification, amount) async {
          await _notificationService.acceptWaste(
            notification['timestamp'],
            _farmHolderId,
            amount,
          );
          await _loadNotifications();
          Navigator.pop(context);
        },
        onRefresh: _loadNotifications,
      ),
    );
  }

  void _showAcceptDialog(Map<String, dynamic> notification) {
    final predictedWaste = notification['predictedWaste'] ?? 0;
    final remainingWaste = notification['remainingWaste'] ?? predictedWaste;
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
            onPressed: () async {
              final amount = double.tryParse(quantityController.text) ?? 0;
              if (amount > 0 && amount <= remainingWaste) {
                await _notificationService.acceptWaste(
                  notification['timestamp'],
                  _farmHolderId,
                  amount,
                );
                await _loadNotifications();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully accepted ${amount.toStringAsFixed(1)}kg of waste'),
                    backgroundColor: Colors.green,
                  ),
                );
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

  void _showAcceptedWaste() async {
    final farmAcceptances = await _notificationService.getFarmAcceptances();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AcceptedWasteSheet(
        acceptances: farmAcceptances,
      ),
    );
  }
}

// ============ Notification List ============
class NotificationList extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(Map<String, dynamic>, double) onAcceptWaste;
  final VoidCallback onRefresh;

  const NotificationList({
    super.key,
    required this.notifications,
    required this.onAcceptWaste,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Waste',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No waste available',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final predictedWaste = notification['predictedWaste'] ?? 0;
                      final remainingWaste = notification['remainingWaste'] ?? predictedWaste;
                      
                      return ListTile(
                        leading: Icon(
                          Icons.local_shipping,
                          color: const Color(0xFF4A3B2A),
                        ),
                        title: Text(
                          '${notification['vegetable']} Delivery',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Truck ${notification['truckId']} • Available: ${remainingWaste.toStringAsFixed(1)}kg',
                          style: GoogleFonts.montserrat(),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () => _showAcceptDialog(context, notification, remainingWaste),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, Map<String, dynamic> notification, double remainingWaste) {
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
                onAcceptWaste(notification, amount);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount between 0 and ${remainingWaste.toStringAsFixed(1)} kg'),
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
}

// ============ Accepted Waste Sheet ============
class AcceptedWasteSheet extends StatelessWidget {
  final Map<String, dynamic> acceptances;

  const AcceptedWasteSheet({super.key, required this.acceptances});

  @override
  Widget build(BuildContext context) {
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
            'My Accepted Waste',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: acceptances.isEmpty
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
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: acceptances.length,
                    itemBuilder: (context, index) {
                      final wasteId = acceptances.keys.elementAt(index);
                      final acceptance = acceptances[wasteId];
                      final wasteData = acceptance['wasteData'];
                      final acceptedAmount = acceptance['acceptedAmount'] ?? 0;
                      
                      return ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(
                          '${wasteData['vegetable']} • Truck ${wasteData['truckId']}',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Accepted: ${acceptedAmount.toStringAsFixed(1)}kg',
                          style: GoogleFonts.montserrat(),
                        ),
                        trailing: Text(
                          _formatDate(wasteData['dateTime'] ?? ''),
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey,
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
}