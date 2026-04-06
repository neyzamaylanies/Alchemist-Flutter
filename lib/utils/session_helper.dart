// lib/utils/session_helper.dart
// Simple in-memory session untuk web (tanpa flutter_secure_storage)

class SessionHelper {
  static String _userId = '';
  static String _userName = '';
  static String _userEmail = '';
  static String _userRole = 'PETUGAS';

  static String get currentId => _userId;
  static String get currentName => _userName;
  static String get currentEmail => _userEmail;
  static String get currentRole => _userRole;
  static bool get isAdmin => _userRole == 'ADMIN';
  static bool get isLoggedIn => _userId.isNotEmpty;
  static bool get isGuest => _userRole == 'GUEST';

  static void setSession({
    required String id,
    required String name,
    required String email,
    required String role,
  }) {
    _userId = id;
    _userName = name;
    _userEmail = email;
    _userRole = role;
  }

  static void clearSession() {
    _userId = '';
    _userName = '';
    _userEmail = '';
    _userRole = 'PETUGAS';
  }

  // Untuk demo/testing tanpa login
  static void setDemoSession() {
    _userId = 'ADM001';
    _userName = 'Admin';
    _userEmail = 'admin@alchemist.com';
    _userRole = 'ADMIN';
  }
}