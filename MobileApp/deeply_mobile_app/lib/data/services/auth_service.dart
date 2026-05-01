import 'package:dio/dio.dart';
import '../models/dtos.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';

abstract class AuthService {
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> refresh(RefreshRequest request);
  Future<void> logout();
}

class AuthServiceImpl implements AuthService {
  final DioClient _dioClient;

  AuthServiceImpl(this._dioClient);

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AuthResponse> refresh(RefreshRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.post('/auth/logout');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
