// lib/repositories/equipment_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/remote/api_result.dart';
import '../models/remote/equipment_response.dart';
import '../models/remote/equipment_category_response.dart';

class EquipmentRepository {
  final Dio dio;

  EquipmentRepository(this.dio);

  // ── CATEGORIES ──────────────────────────────────────────

  Future<ApiResult<List<EquipmentCategoryResponse>>> getCategoryList() async {
    try {
      var result = await dio.get("api/categories");
      var list = (result.data["data"] as List<dynamic>)
          .map((e) => EquipmentCategoryResponse.fromJson(e))
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

  Future<ApiResult<EquipmentCategoryResponse>> createCategory(
      Map<String, dynamic> category) async {
    try {
      var result = await dio.post("api/categories", data: category);
      return ApiResult(
          data: EquipmentCategoryResponse.fromJson(result.data["data"]));
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<EquipmentCategoryResponse>> updateCategory(
      String id, Map<String, dynamic> category) async {
    try {
      var result = await dio.put("api/categories/$id", data: category);
      return ApiResult(
          data: EquipmentCategoryResponse.fromJson(result.data["data"]));
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult> deleteCategory(String id) async {
    try {
      await dio.delete("api/categories/$id");
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

  // ── EQUIPMENTS ──────────────────────────────────────────

  Future<ApiResult<List<EquipmentResponse>>> getEquipmentList() async {
    try {
      var result = await dio.get("api/equipments");
      var list = (result.data["data"] as List<dynamic>)
          .map((e) => EquipmentResponse.fromJson(e))
          .toList();
      return ApiResult(data: list);
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<EquipmentResponse>> createEquipment(
      Map<String, dynamic> equipment) async {
    try {
      var result = await dio.post("api/equipments", data: equipment);
      return ApiResult(
          data: EquipmentResponse.fromJson(result.data["data"]));
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<EquipmentResponse>> updateEquipment(
      String id, Map<String, dynamic> equipment) async {
    try {
      var result = await dio.put("api/equipments/$id", data: equipment);
      return ApiResult(
          data: EquipmentResponse.fromJson(result.data["data"]));
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult> deleteEquipment(String id) async {
    try {
      await dio.delete("api/equipments/$id");
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
