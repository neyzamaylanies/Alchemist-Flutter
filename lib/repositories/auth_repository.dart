import 'package:dio/dio.dart';
import '../models/remote/auth_response.dart';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      'api/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    try {
      await _dio.post('api/auth/logout');
    } catch (_) {}
  }
}
