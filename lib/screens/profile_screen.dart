import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'personal_info_screen.dart';
import 'learning_history_screen.dart';
import 'notifications_screen.dart';
import 'security_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ApiService _api = ApiService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userEmail = auth.userEmail ?? 'Not logged in';
    final userName = userEmail.split('@')[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _api.getUserStats(auth.userId ?? ''),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {'enrolled': 0, 'completed': 0};
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF6366F1),
                          child: Text(
                            userName.isNotEmpty ? userName[0] : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'Enrolled',
                        isLoading ? '...' : stats['enrolled'].toString(),
                        Icons.book_outlined,
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Completed',
                        isLoading ? '...' : stats['completed'].toString(),
                        Icons.workspace_premium_outlined,
                        Colors.amber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Menu Options
                _buildMenuItem(
                  Icons.person_outline,
                  'Personal Information',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PersonalInfoScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  Icons.history_outlined,
                  'Learning History',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LearningHistoryScreen()),
                    );
                  },
                ),
                _buildMenuItem(Icons.notifications_none, 'Notifications', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsScreen()),
                  );
                }),
                _buildMenuItem(Icons.security_outlined, 'Security', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecurityScreen()),
                  );
                }),
                const Divider(height: 40, indent: 20, endIndent: 20),
                _buildMenuItem(
                  Icons.logout,
                  'Sign Out',
                  () async {
                    await auth.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  },
                  isDestructive: true,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF64748B)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : const Color(0xFF1E293B),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCBD5E1)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
