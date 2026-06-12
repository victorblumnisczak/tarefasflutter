import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';

class SessionController {
  static final SessionController instance = SessionController._();
  SessionController._();

  static const String _kStorageKey = 'auth_user';

  AuthUser? _user;

  AuthUser? get user => _user;
  String? get token => _user?.accessToken;
  bool get isLoggedIn => _user != null;

  Future<void> login(AuthUser user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kStorageKey);
  }

  Future<bool> tryRestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kStorageKey);
      if (stored == null) return false;
      _user = AuthUser.fromStoredJson(
        jsonDecode(stored) as Map<String, dynamic>,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
