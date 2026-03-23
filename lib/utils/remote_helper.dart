import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'shared_preference_helper.dart';

class RemoteHelper {
  static Dio? _dio;

  static Dio getDio() {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? 'http://192.168.1.7:8080/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SharedPreferenceHelper.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await SharedPreferenceHelper.clearAll();
          }
          handler.next(error);
        },
      ),
    );

    return _dio!;
  }

  static void resetDio() => _dio = null;
}
