import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? userId;
  final ApiService _api = ApiService();
  bool _isLoading = false;

  AuthProvider() {
    _checkPersistence();
  }

  void _checkPersistence() {
    final user = _api.currentUser;
    if (user != null) {
      userId = user.uid;
      debugPrint("AuthPersistence: Recovered session for ${user.email} (UID: ${user.uid})");
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  String? get currentUserId => userId;
  String? get userEmail => _api.currentUser?.email;

  Future<bool> signup(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.signup(email, password);
      debugPrint("AuthSignup: Response: $res");
      if (res['success']) {
        userId = res['uid'];
        debugPrint("AuthSignup: Set userId to $userId");
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("AuthSignup: Error: $e");
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
      debugPrint("AuthLogin: Response: $res");
      if (res['success']) {
        userId = res['uid'];
        debugPrint("AuthLogin: Set userId to $userId");
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("AuthLogin: Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.logout();
    userId = null;
    notifyListeners();
  }
}
