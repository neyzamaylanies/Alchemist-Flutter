// lib/repositories/transaction_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/remote/api_result.dart';
import '../models/remote/transaction_response.dart';

class TransactionRepository {
  final Dio dio;

  TransactionRepository(this.dio);

  Future<ApiResult<List<TransactionResponse>>> getTransactionList() async {
    try {
      var result = await dio.get("api/transactions");
      var list = (result.data["data"] as List<dynamic>)
          .map((e) => TransactionResponse.fromJson(e))
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

  Future<ApiResult<List<TransactionResponse>>> getActiveBorrowings() async {
    try {
      var result = await dio.get("api/transactions/active-borrowings");
      var list = (result.data["data"] as List<dynamic>)
          .map((e) => TransactionResponse.fromJson(e))
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

  Future<ApiResult<TransactionResponse>> createTransaction(
      Map<String, dynamic> transaction) async {
    try {
      var result = await dio.post("api/transactions", data: transaction);
      return ApiResult(
          data: TransactionResponse.fromJson(result.data["data"]));
    } on DioException catch (e) {
      return ApiResult(
        isSuccess: false,
        message: (e.response?.data as Map<String, dynamic>?)?["message"] ?? "",
      );
    } on Exception catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult> deleteTransaction(String id) async {
    try {
      await dio.delete("api/transactions/$id");
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
