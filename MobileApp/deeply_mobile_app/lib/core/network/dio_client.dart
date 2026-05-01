import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class DioClient {
  static const String baseUrl = 'http://localhost:5190'; // Backend API URL
  static const Duration timeoutDuration = Duration(seconds: 30);

  final Dio dio;
  final Logger logger;

  DioClient({Dio? dio, Logger? logger})
    : dio = dio ?? _createDio(),
      logger = logger ?? Logger();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeoutDuration,
        receiveTimeout: timeoutDuration,
        sendTimeout: timeoutDuration,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Логирование запросов и ответов
    dio.interceptors.add(LoggingInterceptor());

    // Retry интерцептор для автоматических повторов при ошибках сети
    dio.interceptors.add(RetryInterceptor(dio));

    return dio;
  }

  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

class LoggingInterceptor extends Interceptor {
  final logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('Request: ${options.method} ${options.path}');
    logger.d('Headers: ${options.headers}');
    logger.d('Query Parameters: ${options.queryParameters}');
    if (options.data != null) {
      logger.d('Data: ${options.data}');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i(
      'Response: ${response.statusCode} ${response.requestOptions.path}',
    );
    logger.d('Data: ${response.data}');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      'Error: ${err.message}',
      error: err.error,
      stackTrace: err.stackTrace,
    );
    return handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final logger = Logger();
  static const int _maxRetries = 3;

  RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Не повторяем POST запросы
    if (requestOptions.method == 'POST') {
      return handler.next(err);
    }

    // Проверяем, что это ошибка сети или timeout
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      final retriesCount = _getRetriesCount(requestOptions);

      if (retriesCount < _maxRetries) {
        logger.w(
          'Retrying request: ${requestOptions.path} (attempt $retriesCount)',
        );
        _incrementRetriesCount(requestOptions);

        try {
          final response = await _dio.request<dynamic>(
            requestOptions.path,
            cancelToken: requestOptions.cancelToken,
            data: requestOptions.data,
            onReceiveProgress: requestOptions.onReceiveProgress,
            onSendProgress: requestOptions.onSendProgress,
            queryParameters: requestOptions.queryParameters,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            ),
          );
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }

  int _getRetriesCount(RequestOptions options) {
    return (options.extra['retries'] as int?) ?? 0;
  }

  void _incrementRetriesCount(RequestOptions options) {
    options.extra['retries'] = _getRetriesCount(options) + 1;
  }
}
