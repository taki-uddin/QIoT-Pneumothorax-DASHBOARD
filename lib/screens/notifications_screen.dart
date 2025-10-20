import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications data - replace with API call
  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'title': 'Critical Alert: Patient ID 001',
      'message': 'Drainage rate exceeds normal threshold',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'type': 'critical',
      'read': false,
    },
    {
      'id': '2',
      'title': 'New Patient Registered',
      'message': 'Patient John Doe has been added to the system',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'type': 'info',
      'read': false,
    },
    {
      'id': '3',
      'title': 'Warning: Patient ID 003',
      'message': 'Respiratory rate elevated - monitoring required',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'type': 'warning',
      'read': true,
    },
    {
      'id': '4',
      'title': 'System Update',
      'message': 'Dashboard maintenance scheduled for tomorrow',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'info',
      'read': true,
    },
    {
      'id': '5',
      'title': 'Patient Discharged',
      'message': 'Patient ID 005 successfully discharged',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'success',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: Column(
        children: [
          // Header
          Container(
            width: screenSize.width,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004283).withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF004283),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${notifications.where((n) => !n['read']).length} unread',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      for (var notification in notifications) {
                        notification['read'] = true;
                      }
                    });
                  },
                  icon: const Icon(Icons.done_all, size: 18),
                  label: Text(
                    'Mark all read',
                    style: TextStyle(fontSize: isMobile ? 13 : 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF004283),
                  ),
                ),
              ],
            ),
          ),
          // Notifications List
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: isMobile ? 64 : 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 16,
                      vertical: 8,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        notifications[index],
                        isMobile,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, bool isMobile) {
    Color typeColor;
    IconData typeIcon;

    switch (notification['type']) {
      case 'critical':
        typeColor = const Color(0xFFFD4646);
        typeIcon = Icons.warning_rounded;
        break;
      case 'warning':
        typeColor = const Color(0xFFFF8500);
        typeIcon = Icons.error_outline;
        break;
      case 'success':
        typeColor = const Color(0xFF27AE60);
        typeIcon = Icons.check_circle_outline;
        break;
      default:
        typeColor = const Color(0xFF004283);
        typeIcon = Icons.info_outline;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 6,
        horizontal: isMobile ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color:
            notification['read'] ? Colors.white : typeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['read']
              ? Colors.grey.withOpacity(0.2)
              : typeColor.withOpacity(0.3),
          width: notification['read'] ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004283).withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            typeIcon,
            color: typeColor,
            size: isMobile ? 20 : 24,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight:
                notification['read'] ? FontWeight.normal : FontWeight.bold,
            color: const Color(0xFF004283),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: !notification['read']
            ? Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}
