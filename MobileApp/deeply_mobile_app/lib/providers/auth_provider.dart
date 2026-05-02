import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import '../data/models/auth_model.dart';

class AuthProvider extends ChangeNotifier {
  final _dio = DioClient.instance;
  bool isLoading = false;
  String? error;
  bool isAuthenticated = false;

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String gender,
  }) async {
    _load(true);
    try {
      final r = await _dio.post(ApiEndpoints.register, data: {
        'email': email,
        'password': password,
        'name': name,
        'gender': gender,
      });
      final auth = AuthModel.fromJson(r.data);
      await SecureStorage.saveTokens(auth.accessToken, auth.refreshToken);
      isAuthenticated = true;
      error = null;
      return true;
    } on DioException catch (e) {
      error = e.response?.data?['message'] ?? 'Ошибка регистрации';
      return false;
    } finally { _load(false); }
  }

  Future<bool> login({required String email, required String password}) async {
    _load(true);
    try {
      final r = await _dio.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });
      final auth = AuthModel.fromJson(r.data);
      await SecureStorage.saveTokens(auth.accessToken, auth.refreshToken);
      isAuthenticated = true;
      error = null;
      return true;
    } on DioException catch (e) {
      error = e.response?.data?['message'] ?? 'Неверный email или пароль';
      return false;
    } finally { _load(false); }
  }

  Future<void> logout() async {
    await SecureStorage.clear();
    isAuthenticated = false;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await SecureStorage.getAccessToken();
    isAuthenticated = token != null;
    notifyListeners();
  }

  void _load(bool v) { isLoading = v; notifyListeners(); }
}
