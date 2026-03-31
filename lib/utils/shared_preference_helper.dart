import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedPreferenceHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _keyToken = 'jwt_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);

  static Future<String?> getToken() => _storage.read(key: _keyToken);

  static Future<void> deleteToken() => _storage.delete(key: _keyToken);

  static Future<void> saveUserInfo({
    required String id,
    required String name,
    required String email,
    required String role,
  }) async {
    await _storage.write(key: _keyUserId, value: id);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserRole, value: role);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    return {
      'id': await _storage.read(key: _keyUserId),
      'name': await _storage.read(key: _keyUserName),
      'email': await _storage.read(key: _keyUserEmail),
      'role': await _storage.read(key: _keyUserRole),
    };
  }

  static Future<void> clearAll() => _storage.deleteAll();
}
