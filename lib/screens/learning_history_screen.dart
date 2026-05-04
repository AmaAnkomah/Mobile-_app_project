import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class LearningHistoryScreen extends StatefulWidget {
  @override
  _LearningHistoryScreenState createState() => _LearningHistoryScreenState();
}

class _LearningHistoryScreenState extends State<LearningHistoryScreen> {
  final ApiService _api = ApiService();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<AuthProvider>(context, listen: false).userId ?? '';
    _historyFuture = _api.getUserLearningHistory(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Learning History'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(history[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 20),
          const Text(
            'No courses completed yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your finished courses will appear here.',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final title = item['title'] ?? 'Unknown Course';
    final score = item['quiz_score'] ?? 0;
    
    // Parse timestamp if available
    String dateStr = 'Unknown Date';
    if (item['completed_at'] != null) {
      DateTime dt = item['completed_at'].toDate();
      dateStr = '${dt.day}/${dt.month}/${dt.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.workspace_premium, color: Color(0xFF6366F1), size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(dateStr, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text('Score: $score', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ),
      ),
    );
  }
}
