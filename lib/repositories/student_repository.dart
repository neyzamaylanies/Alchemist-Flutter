// lib/repositories/student_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/remote/api_result.dart';
import '../models/remote/student_response.dart';

class StudentRepository {
  final Dio dio;

  StudentRepository(this.dio);

  Future<ApiResult<List<StudentResponse>>> getStudentList() async {
    try {
      var result = await dio.get("api/students");
      var list = (result.data["data"] as List<dynamic>)
          .map((e) => StudentResponse.fromJson(e))
          .toList();
      return ApiResult(data: list);
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      debugPrint("Error: $e");
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<StudentResponse>> createStudent(
      Map<String, dynamic> student) async {
    try {
      var result = await dio.post("api/students", data: student);
      return ApiResult(data: StudentResponse.fromJson(result.data["data"]));
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<StudentResponse>> updateStudent(
      String id, Map<String, dynamic> student) async {
    try {
      var result = await dio.put("api/students/$id", data: student);
      return ApiResult(data: StudentResponse.fromJson(result.data["data"]));
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult> deleteStudent(String id) async {
    try {
      await dio.delete("api/students/$id");
      return ApiResult();
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }
}
