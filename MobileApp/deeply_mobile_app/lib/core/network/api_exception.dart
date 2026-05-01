import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  factory ApiException.fromDioException(DioException error) {
    String message = 'Unknown error occurred';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        if (responseData is Map && responseData.containsKey('message')) {
          message = responseData['message'] as String;
        } else {
          message = 'Server error: $statusCode';
        }
        break;
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.unknown:
        message = error.message ?? 'Unknown error occurred';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      originalError: error.error,
      stackTrace: error.stackTrace,
    );
  }

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
