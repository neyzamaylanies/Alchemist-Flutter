// lib/utils/shared_preference_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPreferenceHelper {
  static FlutterSecureStorage? _storage;
  static const String keyActiveUserId = "active_user_id";
  static const String keyActiveUserName = "active_user_name";
  static const String keyActiveUserRole = "active_user_role";

  static FlutterSecureStorage getInstance() {
    _storage ??= const FlutterSecureStorage();
    return _storage!;
  }
}
