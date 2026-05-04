import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String courseId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final Timestamp timestamp;

  Review({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory Review.fromJson(Map<String, dynamic> json, String docId) {
    return Review(
      id: docId,
      courseId: json['course_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? 'Anonymous',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      timestamp: json['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}
