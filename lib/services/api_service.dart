import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/course.dart';
import '../models/quiz.dart';
import '../models/review.dart';

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

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Update password
        await user.updatePassword(newPassword);
        return {'success': true};
      } else {
        return {'success': false, 'message': 'No user logged in'};
      }
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? e.toString()};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> seedDemoCourses() async {
    final courses = [
      {
        'title': 'Flutter Mastery 2024',
        'description': 'Build beautiful mobile apps from scratch.',
        'long_description':
            'This comprehensive course covers everything from Dart basics to advanced Flutter architecture. You will learn how to build production-ready apps with professional state management and clean architecture.',
        'instructor_id': 'demo_instructor_1',
        'category': 'Programming',
        'thumbnail_url':
            'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
        // Flutter/Dart programming video
        'video_url':
            'https://www.youtube.com/watch?v=x0U1DEUEdWg',
      },
      {
        'title': 'UI/UX Design Principles',
        'description': 'Master the art of user-centric design.',
        'long_description':
            'Learn how to create stunning interfaces that users love. We cover typography, color theory, spacing, and how to create interactive prototypes using Figma and Adobe XD.',
        'instructor_id': 'design_pro_2',
        'category': 'Design',
        'thumbnail_url':
            'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800',
        // Design video
        'video_url':
            'https://www.youtube.com/watch?v=ODpB9-MCa5s',
      },
      {
        'title': 'Digital Marketing Strategies',
        'description': 'Grow your business online effectively.',
        'long_description':
            'Master SEO, SEM, and social media marketing. Learn how to run successful campaigns on Google Ads and Facebook to drive conversions.',
        'instructor_id': 'marketing_guru_3',
        'category': 'Marketing',
        'thumbnail_url':
            'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
        // Marketing video
        'video_url':
            'https://www.youtube.com/watch?v=YhK_PGhdPe8',
      },
      {
        'title': 'Business Management 101',
        'description': 'Core fundamentals for modern leaders.',
        'long_description':
            'Develop leadership skills, understand financial statements, and learn strategic planning to manage successful teams and organizations.',
        'instructor_id': 'business_exec_4',
        'category': 'Business',
        'thumbnail_url':
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800',
        // Business video
        'video_url':
            'https://www.youtube.com/watch?v=mqSxgzRg7fw',
      },
      {
        'title': 'Health & Wellness Coach',
        'description': 'Live a balanced and healthy lifestyle.',
        'long_description':
            'Learn about nutrition, exercise science, and mental well-being to achieve your personal health goals or help others on their journey.',
        'instructor_id': 'fitness_expert_5',
        'category': 'Health',
        'thumbnail_url':
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
        // Health video
        'video_url':
            'https://www.youtube.com/watch?v=l73KZJI8UVs',
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

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      // For a school project, ImgBB is a great free alternative to Firebase Storage.
      // You can get a free API key at https://api.imgbb.com/
      const String apiKey = '1a5f05dc4f3b8a47d9a2948f2d9e8c3a'; 
      
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'));
      
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
      ));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(respStr);
        return jsonResponse['data']['url'];
      }
      return null;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final enrollments = await _db
          .collection('enrollments')
          .where('userId', isEqualTo: userId)
          .get();
      
      final completed = await _db
          .collection('user_progress')
          .where('user_id', isEqualTo: userId)
          .get();

      return {
        'enrolled': enrollments.docs.length,
        'completed': completed.docs.length,
      };
    } catch (e) {
      print("Error fetching user stats: $e");
      return {'enrolled': 0, 'completed': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getUserLearningHistory(String userId) async {
    try {
      final progressSnap = await _db
          .collection('user_progress')
          .where('user_id', isEqualTo: userId)
          .get();

      if (progressSnap.docs.isEmpty) return [];

      List<Map<String, dynamic>> history = [];
      for (var doc in progressSnap.docs) {
        final data = doc.data();
        final courseId = data['course_id'] as String;
        
        final courseDoc = await _db.collection('courses').doc(courseId).get();
        if (courseDoc.exists) {
          final courseData = courseDoc.data() as Map<String, dynamic>;
          history.add({
            'course_id': courseId,
            'title': courseData['title'] ?? 'Unknown Course',
            'thumbnail_url': courseData['thumbnail_url'] ?? '',
            'quiz_score': data['quiz_score'] ?? 0,
            'completed_at': data['completed_at'],
          });
        }
      }
      return history;
    } catch (e) {
      debugPrint("Error fetching learning history: \$e");
      return [];
    }
  }

  Future<List<Course>> fetchEnrolledCourses(String userId) async {
    try {
      final enrollmentSnap = await _db
          .collection('enrollments')
          .where('userId', isEqualTo: userId)
          .get();
      
      if (enrollmentSnap.docs.isEmpty) return [];

      List<Course> enrolled = [];
      for (var doc in enrollmentSnap.docs) {
        final courseId = doc.data()['courseId'] as String;
        final courseDoc = await _db.collection('courses').doc(courseId).get();
        if (courseDoc.exists) {
          enrolled.add(Course.fromJson(courseDoc.data() as Map<String, dynamic>, courseDoc.id));
        }
      }
      return enrolled;
    } catch (e) {
      debugPrint("Error fetching enrolled courses: $e");
      return [];
    }
  }

  Future<bool> isEnrolled(String userId, String courseId) async {
    try {
      final res = await _db
          .collection('enrollments')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .get();
      return res.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> enroll(String userId, String courseId) async {
    debugPrint("ApiService: Enrolling User: $userId in Course: $courseId");
    if (userId.isEmpty) {
      debugPrint("ApiService: ABORTING ENROLLMENT - userId is empty!");
      return {'success': false, 'error': 'Not logged in'};
    }
    try {
      await _db.collection('enrollments').add({
        'userId': userId,
        'courseId': courseId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint("ApiService: Enrollment SUCCESS");
      return {'success': true};
    } catch (e) {
      debugPrint("ApiService: Enrollment FAILED: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Quiz?> fetchQuiz(String courseId) async {
    try {
      debugPrint("ApiService: Fetching quiz for courseId: $courseId");
      QuerySnapshot snapshot = await _db
          .collection('quizzes')
          .where('course_id', isEqualTo: courseId)
          .limit(1)
          .get();
          
      if (snapshot.docs.isNotEmpty) {
        debugPrint("ApiService: Found quiz for courseId: $courseId");
        return Quiz.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>,
          snapshot.docs.first.id,
        );
      }
      debugPrint("ApiService: NO QUIZ FOUND for courseId: $courseId");
      return null;
    } catch (e) {
      debugPrint("ApiService: Error fetching quiz: $e");
      return null;
    }
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
    final courses = await fetchCourses();
    if (courses.isEmpty) return;

    // Course-specific questions keyed by course title keyword
    final Map<String, List<Map<String, dynamic>>> questionsByTitle = {
      'Flutter': [
        {
          'text': 'What programming language is Flutter built with?',
          'options': ['Java', 'Kotlin', 'Dart', 'Swift'],
          'correct_option_index': 2,
        },
        {
          'text': 'Which widget is used for layouts that DO NOT change over time?',
          'options': [
            'StatefulWidget',
            'StatelessWidget',
            'InheritedWidget',
            'FutureBuilder',
          ],
          'correct_option_index': 1,
        },
        {
          'text': 'What is the command to create a new Flutter project?',
          'options': [
            'flutter start myapp',
            'flutter create myapp',
            'flutter new myapp',
            'flutter init myapp',
          ],
          'correct_option_index': 1,
        },
        {
          'text': 'Which package is most commonly used for state management in Flutter?',
          'options': ['Redux', 'MobX', 'Provider', 'Riverpod'],
          'correct_option_index': 2,
        },
      ],
      'UI/UX': [
        {
          'text': 'What does UX stand for?',
          'options': [
            'User Execution',
            'User Experience',
            'Universal Exchange',
            'Unified Extension',
          ],
          'correct_option_index': 1,
        },
        {
          'text': 'Which tool is most commonly used for UI prototyping?',
          'options': ['Photoshop', 'Figma', 'Illustrator', 'Excel'],
          'correct_option_index': 1,
        },
        {
          'text': 'What is the "60-30-10" rule in design?',
          'options': [
            'Font size ratio',
            'A color proportion rule',
            'Grid column ratio',
            'Spacing guideline',
          ],
          'correct_option_index': 1,
        },
        {
          'text': 'What does "affordance" mean in UX design?',
          'options': [
            'The price of a design tool',
            'A visual cue suggesting how to use an element',
            'The number of screens in an app',
            'A type of animation',
          ],
          'correct_option_index': 1,
        },
      ],
      'Digital Marketing': [
        {
          'text': 'What does SEO stand for?',
          'options': [
            'Social Engagement Optimization',
            'Search Engine Optimization',
            'Sales and Earnings Output',
            'System Exchange Operations',
          ],
          'correct_option_index': 1,
        },
        {
          'text': 'Which metric measures the percentage of users who click an ad?',
          'options': ['CPM', 'ROI', 'CTR', 'CPA'],
          'correct_option_index': 2,
        },
        {
          'text': 'What platform is best known for B2B digital marketing?',
          'options': ['Instagram', 'TikTok', 'LinkedIn', 'Pinterest'],
          'correct_option_index': 2,
        },
        {
          'text': 'What is a "conversion" in digital marketing?',
          'options': [
            'Changing a logo',
            'A desired action completed by a user',
            'Switching ad platforms',
            'Translating content to another language',
          ],
          'correct_option_index': 1,
        },
      ],
      'Business Management': [
        {
          'text': 'What does SWOT analysis stand for?',
          'options': [
            'Sales, Workflow, Output, Target',
            'Strengths, Weaknesses, Opportunities, Threats',
            'Strategy, Work, Operations, Tools',
            'Systems, Wages, Output, Trends',
          ],
          'correct_option_index': 1,
        },
        {
          'text': 'Which management style involves employees in decision-making?',
          'options': [
            'Autocratic',
            'Laissez-faire',
            'Democratic',
            'Transactional',
          ],
          'correct_option_index': 2,
        },
        {
          'text': 'What does KPI stand for?',
          'options': [
            'Key Performance Indicator',
            'Key Process Integration',
            'Knowledge and Productivity Index',
            'Key Program Input',
          ],
          'correct_option_index': 0,
        },
        {
          'text': 'Which financial statement shows revenues and expenses over a period?',
          'options': [
            'Balance Sheet',
            'Cash Flow Statement',
            'Income Statement',
            'Equity Report',
          ],
          'correct_option_index': 2,
        },
      ],
      'Health': [
        {
          'text': 'How many hours of sleep are recommended for an adult per night?',
          'options': ['4-5 hours', '6-7 hours', '7-9 hours', '10-12 hours'],
          'correct_option_index': 2,
        },
        {
          'text': 'Which macronutrient is the body\'s primary source of energy?',
          'options': ['Protein', 'Fat', 'Carbohydrates', 'Vitamins'],
          'correct_option_index': 2,
        },
        {
          'text': 'What does BMI stand for?',
          'options': [
            'Body Metabolism Index',
            'Basic Muscle Intake',
            'Body Mass Index',
            'Bone Mineral Index',
          ],
          'correct_option_index': 2,
        },
        {
          'text': 'How many minutes of moderate exercise per week does WHO recommend?',
          'options': ['75 minutes', '150 minutes', '300 minutes', '60 minutes'],
          'correct_option_index': 1,
        },
      ],
    };

    for (var course in courses) {
      // Match questions by checking which key appears in the course title
      List<Map<String, dynamic>> questions = [];
      for (var key in questionsByTitle.keys) {
        if (course.title.contains(key)) {
          questions = questionsByTitle[key]!;
          break;
        }
      }

      // Fallback: generic questions if title doesn't match any key
      if (questions.isEmpty) {
        questions = [
          {
            'text': 'What is the main goal of this course: ${course.title}?',
            'options': [
              'Entertainment',
              'Professional development',
              'Gaming',
              'Social networking',
            ],
            'correct_option_index': 1,
          },
          {
            'text': 'Which skill does this course primarily develop?',
            'options': [
              course.category,
              'Cooking',
              'Music',
              'Architecture',
            ],
            'correct_option_index': 0,
          },
        ];
      }

      await _db.collection('quizzes').add({
        'course_id': course.id,
        'questions': questions,
      });
    }
  }

  /// Deletes ALL existing courses and quizzes from Firestore, then re-seeds
  /// fresh data. Call this once from the UI (e.g. a hidden admin button) to
  /// replace stale seeded data with the updated content above.
  Future<void> clearAndReseed() async {
    // Delete all courses
    final courseSnap = await _db.collection('courses').get();
    for (var doc in courseSnap.docs) {
      await doc.reference.delete();
    }

    // Delete all quizzes
    final quizSnap = await _db.collection('quizzes').get();
    for (var doc in quizSnap.docs) {
      await doc.reference.delete();
    }

    // Re-seed fresh data
    await seedDemoCourses();
    await seedDemoQuizzes();
  }

  Future<void> addReview(Review review) async {
    try {
      // If the user already reviewed, we could update it, 
      // but for simplicity we'll just add it as a new document or overwrite.
      // Easiest is to use add() for multiple reviews or set() for 1 review per user.
      // Let's enforce 1 review per user per course:
      await _db
          .collection('reviews')
          .doc('\${review.userId}_\${review.courseId}')
          .set(review.toJson());
    } catch (e) {
      debugPrint("Error adding review: \$e");
    }
  }

  Future<List<Review>> fetchReviews(String courseId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('reviews')
          .where('course_id', isEqualTo: courseId)
          .orderBy('timestamp', descending: true)
          .get();
          
      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      // NOTE: Ordering by timestamp requires a composite index if combining with 'where'.
      // If index is missing, it will throw. We'll fallback to fetching without order
      // and sort locally if needed, to prevent app crash while building the LMS locally.
      debugPrint("Error fetching reviews (likely missing index): \$e");
      
      try {
        QuerySnapshot fallbackSnap = await _db
            .collection('reviews')
            .where('course_id', isEqualTo: courseId)
            .get();
            
        final list = fallbackSnap.docs
            .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      } catch (fallbackError) {
         debugPrint("Fallback fetch failed: \$fallbackError");
         return [];
      }
    }
  }
}
