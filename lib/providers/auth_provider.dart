import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? userId;
  final ApiService _api = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get currentUserId => userId;

  Future<bool> signup(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.signup(email, password);
      if (res['success']) {
        userId = res['user_id'];
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.login(email, password);
      if (res['success']) {
        userId = res['user_id'];
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
