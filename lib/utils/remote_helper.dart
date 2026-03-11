// lib/utils/remote_helper.dart
import 'package:dio/dio.dart';

class RemoteHelper {
  static Dio? _dio;

  static Dio getDio() {
    return _dio ??= Dio(BaseOptions(
      baseUrl: "http://localhost:8080/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ));
  }
}
