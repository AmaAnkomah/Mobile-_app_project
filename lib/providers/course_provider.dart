import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/course.dart';

class CourseProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _api.fetchCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enroll(String userId, String courseId) async {
    try {
      final response = await _api.enroll(userId, courseId);
      if (response['success']) {
        await fetchCourses(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addCourse(Map<String, dynamic> courseData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final courseId = await _api.addCourse(courseData);
      if (courseId != null) {
        await fetchCourses(); // Refresh list to include new course
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> seedData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.seedDemoCourses();
      await _api.seedDemoQuizzes();
      await fetchCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
