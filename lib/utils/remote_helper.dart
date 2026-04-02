import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'shared_preference_helper.dart';

class RemoteHelper {
  static Dio? _dio;

  // URL dinamis menyesuaikan environment saat ini
  static String get baseUrl {
    if (kIsWeb) {
      // Jika dijalankan di Web (Chrome/Edge dll)
      return 'http://localhost:8080/';
    } else if (Platform.isAndroid) {
      // Jika dijalankan di Emulator Android - bisa diubah kalau mau dijalanin di handphone sendiri (ganti pake ipv4, dan portnya tetap)
      return 'http://10.0.2.2:8080/';
    } else {
      // Jika dijalankan di Windows, iOS Simulator, macOS, dll
      return 'http://localhost:8080/';
    }
  }

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
