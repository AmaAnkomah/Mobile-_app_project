import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/quiz.dart';

class ApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'uid': userCredential.user?.uid};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return {'success': true, 'uid': userCredential.user?.uid};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<List<Course>> fetchCourses() async {
    QuerySnapshot snapshot = await _db.collection('courses').get();
    return snapshot.docs.map((doc) {
      return Course.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> seedDemoCourses() async {
    final courses = [
      {
        'title': 'Flutter Mastery 2024',
        'description': 'Build beautiful mobile apps from scratch.',
        'long_description':
            'This comprehensive course covers everything from Dart basics to advanced Flutter architecture...',
        'instructor_id': 'demo_instructor',
        'category': 'Programming',
        'thumbnail_url':
            'https://storage.googleapis.com/cms-storage-bucket/707c3aab0516536772d7.png',
        'video_url':
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      },
      {
        'title': 'UI/UX Design Principles',
        'description': 'Master the art of user-centric design.',
        'long_description':
            'Learn how to create stunning interfaces that users love...',
        'instructor_id': 'design_pro',
        'category': 'Design',
        'thumbnail_url':
            'https://images.unsplash.com/photo-1541462608141-ad511aaeeeec',
        'video_url':
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      },
    ];

    for (var course in courses) {
      await _db.collection('courses').add(course);
    }
  }

  Future<String?> addCourse(Map<String, dynamic> courseData) async {
    try {
      DocumentReference docRef = await _db
          .collection('courses')
          .add(courseData);
      return docRef.id;
    } catch (e) {
      print("Error adding course: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> enroll(String userId, String courseId) async {
    try {
      await _db.collection('enrollments').add({
        'user_id': userId,
        'course_id': courseId,
        'enrolled_at': FieldValue.serverTimestamp(),
      });
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Quiz?> fetchQuiz(String courseId) async {
    QuerySnapshot snapshot = await _db
        .collection('quizzes')
        .where('course_id', isEqualTo: courseId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return Quiz.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  Future<void> submitScore(String userId, String courseId, int score) async {
    await _db.collection('user_progress').doc('${userId}_$courseId').set({
      'user_id': userId,
      'course_id': courseId,
      'quiz_score': score,
      'completed_at': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserProgress(
    String userId,
    String courseId,
  ) async {
    DocumentSnapshot doc = await _db
        .collection('user_progress')
        .doc('${userId}_$courseId')
        .get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> seedDemoQuizzes() async {
    // We'll call this after seeding courses to get real IDs or just use title matching
    final courses = await fetchCourses();
    if (courses.isEmpty) return;

    for (var course in courses) {
      final quizData = {
        'course_id': course.id,
        'questions': [
          {
            'text':
                'What is the primary programming language for ${course.title}?',
            'options': ['Java', 'Swift', 'Dart', 'Javascript'],
            'correct_option_index': 2,
          },
          {
            'text': 'Which widget is used for immutable layouts in Flutter?',
            'options': [
              'StatefulWidget',
              'StatelessWidget',
              'InheritedWidget',
              'Provider',
            ],
            'correct_option_index': 1,
          },
        ],
      };
      await _db.collection('quizzes').add(quizData);
    }
  }
}
