// lib/features/home/alert_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.verified_user_rounded,
      'title': 'Identity Verification Successful',
      'content': 'Your KTP Digital has been successfully verified by Bank BCA.',
      'time': '2 hours ago',
      'isRead': false,
      'type': 'success',
    },
    {
      'icon': Icons.security_rounded,
      'title': 'New Login Detected',
      'content': 'A new login was detected from Jakarta using your digital identity.',
      'time': '5 hours ago',
      'isRead': false,
      'type': 'security',
    },
    {
      'icon': Icons.update_rounded,
      'title': 'System Update Available',
      'content': 'A new version of CONNECTIDWALLET is available. Update now for better security.',
      'time': '1 day ago',
      'isRead': true,
      'type': 'info',
    },
    {
      'icon': Icons.warning_rounded,
      'title': 'Verification Failed',
      'content': 'Identity verification with Tokopedia failed. Please try again.',
      'time': '2 days ago',
      'isRead': true,
      'type': 'warning',
    },
    {
      'icon': Icons.card_membership_rounded,
      'title': 'New Credential Added',
      'content': 'NPWP Digital has been successfully added to your wallet.',
      'time': '3 days ago',
      'isRead': true,
      'type': 'success',
    },
  ];

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _deleteNotification(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _notifications.removeAt(index);
    });
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return Colors.greenAccent;
      case 'warning':
        return Colors.orangeAccent;
      case 'security':
        return Colors.blueAccent;
      case 'info':
        return Colors.cyanAccent;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // BLPID Logo Background
          Positioned(
            top: -50,
            right: -100,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/blpid_logo.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(),

                // Notifications List
                Expanded(
                  child: _notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key('notification_$index'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) => _deleteNotification(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(
                            Icons.delete_rounded,
                            color: Colors.redAccent.withOpacity(0.8),
                          ),
                        ),
                        child: _buildNotificationItem(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.8),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'Alert',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    for (var notification in _notifications) {
                      notification['isRead'] = true;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.done_all_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    final notification = _notifications[index];
    final bool isRead = notification['isRead'];
    final color = _getNotificationColor(notification['type']);

    return GestureDetector(
      onTap: () {
        _markAsRead(index);
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(isRead ? 0.08 : 0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? Colors.white.withOpacity(0.1)
                : color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      notification['icon'],
                      color: color,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['content'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification['time'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      )
          .animate()
          .fadeIn()
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
    );
  }
}