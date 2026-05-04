import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

typedef AuthErrorCallback = void Function();

class DioClient {
  static Dio? _instance;
  static AuthErrorCallback? onAuthError;

  static Dio get instance {
    _instance ??= _create();
    return _instance!;
  }

  static void reset() {
    _instance?.close();
    _instance = null;
  }

  static Dio _create() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = token;
        }
        debugPrint('[DioClient] --> ${options.method} ${options.uri}');
        debugPrint('[DioClient]     headers: ${options.headers}');
        debugPrint('[DioClient]     body: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[DioClient] <-- ${response.statusCode} ${response.requestOptions.uri}');
        debugPrint('[DioClient]     data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint('[DioClient] ERR ${error.type} ${error.response?.statusCode} ${error.requestOptions.uri}');
        debugPrint('[DioClient]     response: ${error.response?.data}');
        debugPrint('[DioClient]     message: ${error.message}');
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh(dio);
          if (refreshed) {
            final token = await SecureStorage.getAccessToken();
            error.requestOptions.headers['Authorization'] = token;
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } else {
            await SecureStorage.clear();
            DioClient.reset();
            onAuthError?.call();
            return handler.next(error);
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  static Future<bool> _tryRefresh(Dio dio) async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      final access = response.data['accessToken'];
      final refresh = response.data['refreshToken'];
      if (access != null && refresh != null) {
        await SecureStorage.saveTokens(access, refresh);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
