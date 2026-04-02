import 'package:dio/dio.dart';
import 'shared_preference_helper.dart';

class RemoteHelper {
  static Dio? _dio;

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue:
        'http://localhost:8080/', // Ganti dengan URL default jika tidak ada di environment
  );

  static Dio getDio() {
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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
