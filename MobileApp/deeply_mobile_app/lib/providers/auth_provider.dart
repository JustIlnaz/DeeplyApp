import 'dart:convert';
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
  int? userId;
  String userName = '';
  String userEmail = '';

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
      debugPrint('[AuthProvider] register response: ${r.data}');
      final auth = AuthModel.fromJson(r.data);

      if (auth.isValid) {
        await SecureStorage.saveTokens(auth.accessToken, auth.refreshToken);
        _parseToken(auth.accessToken);
        isAuthenticated = true;
        error = null;
        return true;
      }

      debugPrint('[AuthProvider] register did not return tokens, trying login...');
      return login(email: email, password: password);
    } on DioException catch (e) {
      debugPrint('[AuthProvider] register error: ${e.response?.data}');
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
      debugPrint('[AuthProvider] login response: ${r.data}');
      final auth = AuthModel.fromJson(r.data);
      if (!auth.isValid) {
        error = 'Сервер не вернул токены';
        return false;
      }
      await SecureStorage.saveTokens(auth.accessToken, auth.refreshToken);
      _parseToken(auth.accessToken);
      debugPrint('[AuthProvider] tokens saved OK, userId=$userId');
      isAuthenticated = true;
      error = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint('[AuthProvider] login error: ${e.response?.data}');
      error = e.response?.data?['message'] ?? 'Неверный email или пароль';
      return false;
    } finally { _load(false); }
  }

  Future<void> logout() async {
    await SecureStorage.clear();
    isAuthenticated = false;
    userId = null;
    userName = '';
    userEmail = '';
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await SecureStorage.getAccessToken();
    isAuthenticated = token != null;
    if (token != null) _parseToken(token);
    notifyListeners();
  }

  /// Alias for checkAuth — refreshes userId/userName from stored token.
  Future<void> fetchProfile() => checkAuth();

  void _parseToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded) as Map<String, dynamic>;
      userId = int.tryParse(map['userId']?.toString() ?? '');
      final nameVal = map['name'] ?? map['unique_name'] ?? map['given_name'];
      if (nameVal != null) userName = nameVal.toString();
      final emailVal = map['email'] ?? map['sub'];
      if (emailVal != null && emailVal.toString().contains('@')) userEmail = emailVal.toString();
    } catch (_) {}
  }

  void _load(bool v) { isLoading = v; notifyListeners(); }
}
