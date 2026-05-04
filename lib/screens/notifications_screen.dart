import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Course Available!',
      'message': 'Advanced Flutter State Management is now available. Click to enroll now.',
      'type': 'course',
      'time': '2 hours ago',
      'unread': true,
    },
    {
      'title': 'Achievement Unlocked',
      'message': 'Congratulations! You scored 100% on the Design quiz.',
      'type': 'achievement',
      'time': '1 day ago',
      'unread': true,
    },
    {
      'title': 'Welcome to Lumina',
      'message': 'We are excited to have you on board! Start learning today.',
      'type': 'system',
      'time': '3 days ago',
      'unread': false,
    },
    {
      'title': 'System Update',
      'message': 'Our video player has been upgraded for a better web experience!',
      'type': 'system',
      'time': '1 week ago',
      'unread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              setState(() {
                for (var element in _notifications) {
                  element['unread'] = false;
                }
              });
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return _buildNotificationCard(notif, index);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, int index) {
    IconData icon;
    Color iconColor;

    switch (notif['type']) {
      case 'course':
        icon = Icons.menu_book;
        iconColor = Colors.blue;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = const Color(0xFF6366F1);
    }

    return Dismissible(
      key: Key(notif['title'] + index.toString()),
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          _notifications.removeAt(index);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: notif['unread'] ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: notif['unread'] ? const Color(0xFF86EFAC) : Colors.transparent,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notif['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (notif['unread'])
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                notif['message'],
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                notif['time'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
