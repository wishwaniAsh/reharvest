import 'package:ReHarvest/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'top_curve_clipper.dart';

class FarmHolderDashboard extends StatefulWidget {
  const FarmHolderDashboard({super.key});

  @override
  State<FarmHolderDashboard> createState() => _FarmHolderDashboardState();
}

class _FarmHolderDashboardState extends State<FarmHolderDashboard> {
  List<Map<String, dynamic>> _notifications = [];
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

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
    return _notifications.where((n) => n['read'] == false).length;
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
                                    'Delivery Overview',
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
                                        'Total',
                                        _notifications.length.toString(),
                                        Icons.local_shipping,
                                      ),
                                      _buildStatItem(
                                        'Pending',
                                        _notifications.where((n) => n['status'] == 'pending').length.toString(),
                                        Icons.pending,
                                        color: Colors.orange,
                                      ),
                                      _buildStatItem(
                                        'Accepted',
                                        _notifications.where((n) => n['status'] != 'pending').length.toString(),
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Recent deliveries
                          if (_notifications.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Deliveries',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._notifications.take(3).map((notification) => 
                                  _buildDeliveryPreview(notification)
                                ).toList(),
                                if (_notifications.length > 3)
                                  TextButton(
                                    onPressed: _showNotifications,
                                    child: Text(
                                      'View all deliveries →',
                                      style: GoogleFonts.montserrat(
                                        color: const Color(0xFF4A3B2A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
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
                                  'No deliveries yet',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'New deliveries will appear here',
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
    final isRead = notification['read'] == true;
    final vegetable = notification['vegetable'] ?? 'Unknown';
    final truckId = notification['truckId'] ?? 'N/A';
    final quantity = notification['quantity'] ?? '0';
    final predictedWaste = notification['predictedWaste'] ?? 0;
    final acceptedWaste = notification['acceptedWaste'] ?? 0;
    final status = notification['status'] ?? 'pending';
    final dateTime = notification['dateTime'] ?? '';

    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending;
    String statusText = 'Pending';

    if (status == 'partially_accepted') {
      statusColor = Colors.blue;
      statusIcon = Icons.check_circle_outline;
      statusText = 'Partially Accepted';
    } else if (status == 'fully_accepted') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Fully Accepted';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead ? Colors.grey[100] : const Color(0xFFE8F5E8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.local_shipping,
          color: isRead ? Colors.grey : const Color(0xFF4A3B2A),
        ),
        title: Text(
          '$vegetable Delivery',
          style: GoogleFonts.montserrat(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? Colors.grey[600] : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Truck $truckId • $quantity kg',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: isRead ? Colors.grey[500] : Colors.black87,
              ),
            ),
            if (predictedWaste > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Predicted: ${predictedWaste.toStringAsFixed(1)}kg • Accepted: ${acceptedWaste.toStringAsFixed(1)}kg',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
        trailing: isRead ? null : const Icon(Icons.fiber_new, color: Colors.green),
        onTap: () => _showNotificationDetails(notification),
      ),
    );
  }

  int _getThisMonthCount() {
    final now = DateTime.now();
    return _notifications.where((n) {
      try {
        final timestamp = n['timestamp'];
        if (timestamp != null) {
          final date = DateTime.parse(timestamp);
          return date.year == now.year && date.month == now.month;
        }
      } catch (e) {
        debugPrint("Error parsing timestamp: $e");
      }
      return false;
    }).length;
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationList(
        notifications: _notifications,
        onNotificationTap: (index) async {
          await _notificationService.markAsRead(index);
          await _loadNotifications();
          Navigator.pop(context);
        },
        onAcceptWaste: (index, amount) async {
          await _notificationService.acceptWaste(index, amount);
          await _loadNotifications();
          Navigator.pop(context);
        },
        onRefresh: _loadNotifications,
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => NotificationDetailsDialog(
        notification: notification,
        onMarkAsRead: () async {
          final index = _notifications.indexWhere((n) => n['timestamp'] == notification['timestamp']);
          if (index != -1) {
            await _notificationService.markAsRead(index);
            await _loadNotifications();
          }
          Navigator.pop(context);
        },
        onAcceptWaste: (amount) async {
          final index = _notifications.indexWhere((n) => n['timestamp'] == notification['timestamp']);
          if (index != -1) {
            await _notificationService.acceptWaste(index, amount);
            await _loadNotifications();
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ============ Notification List ============
class NotificationList extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(int) onNotificationTap;
  final Function(int, double) onAcceptWaste;
  final VoidCallback onRefresh;

  const NotificationList({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
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
                'Delivery Notifications',
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
                          'No notifications yet',
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
                      final isRead = notification['read'] == true;
                      final status = notification['status'] ?? 'pending';
                      final predictedWaste = notification['predictedWaste'] ?? 0;
                      final acceptedWaste = notification['acceptedWaste'] ?? 0;
                      
                      return ListTile(
                        leading: Icon(
                          Icons.local_shipping,
                          color: isRead ? Colors.grey : const Color(0xFF4A3B2A),
                        ),
                        title: Text(
                          '${notification['vegetable']} Delivery',
                          style: GoogleFonts.montserrat(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Truck ${notification['truckId']} • ${notification['quantity']}kg',
                              style: GoogleFonts.montserrat(),
                            ),
                            if (predictedWaste > 0)
                              Text(
                                'Waste: ${predictedWaste.toStringAsFixed(1)}kg (Accepted: ${acceptedWaste.toStringAsFixed(1)}kg)',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status == 'pending')
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _showAcceptDialog(context, index, predictedWaste),
                              ),
                            if (isRead) 
                              const Icon(Icons.check_circle, color: Colors.green, size: 16)
                            else
                              const Icon(Icons.fiber_new, color: Colors.green),
                          ],
                        ),
                        onTap: () => onNotificationTap(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, int index, double predictedWaste) {
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
              'Predicted waste: ${predictedWaste.toStringAsFixed(1)}kg\nHow much can you accept?',
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
              if (amount > 0 && amount <= predictedWaste) {
                onAcceptWaste(index, amount);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount between 0 and $predictedWaste kg'),
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

// ============ Notification Details Dialog ============
class NotificationDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onMarkAsRead;
  final Function(double) onAcceptWaste;

  const NotificationDetailsDialog({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onAcceptWaste,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['read'] == true;
    final vegetable = notification['vegetable'] ?? 'Unknown';
    final truckId = notification['truckId'] ?? 'N/A';
    final quantity = notification['quantity'] ?? '0';
    final predictedWaste = notification['predictedWaste'] ?? 0;
    final acceptedWaste = notification['acceptedWaste'] ?? 0;
    final remainingWaste = notification['remainingWaste'] ?? predictedWaste;
    final status = notification['status'] ?? 'pending';
    final dateTime = notification['dateTime'] ?? '';
    final timestamp = notification['timestamp'] ?? '';

    Color statusColor = Colors.orange;
    String statusText = 'Pending Acceptance';

    if (status == 'partially_accepted') {
      statusColor = Colors.blue;
      statusText = 'Partially Accepted';
    } else if (status == 'fully_accepted') {
      statusColor = Colors.green;
      statusText = 'Fully Accepted';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Details',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isRead)
                  IconButton(
                    icon: const Icon(Icons.mark_email_read, color: Colors.green),
                    onPressed: onMarkAsRead,
                    tooltip: 'Mark as read',
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            _buildDetailRow('Vegetable', vegetable),
            _buildDetailRow('Truck ID', truckId),
            _buildDetailRow('Quantity', '$quantity kg'),
            _buildDetailRow('Date & Time', dateTime),
            _buildDetailRow(
              'Predicted Waste',
              '${predictedWaste.toStringAsFixed(1)} kg',
              valueColor: Colors.red,
            ),
            _buildDetailRow(
              'Accepted Waste',
              '${acceptedWaste.toStringAsFixed(1)} kg',
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
            
            const SizedBox(height: 20),
            
            if (status == 'pending')
              Center(
                child: ElevatedButton(
                  onPressed: () => _showAcceptDialog(context, predictedWaste),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3B2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Accept Waste',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
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

  void _showAcceptDialog(BuildContext context, double predictedWaste) {
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
              'Predicted waste: ${predictedWaste.toStringAsFixed(1)}kg\nHow much can you accept?',
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
              if (amount > 0 && amount <= predictedWaste) {
                onAcceptWaste(amount);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount between 0 and $predictedWaste kg'),
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