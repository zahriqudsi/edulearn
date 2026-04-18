import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  late Dio _dio;
  static const String baseUrl = 'https://api.novixtech.lk/api';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('🌐 [API REQUEST]: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ [API RESPONSE]: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            '❌ [API ERROR]: ${e.requestOptions.path} [${e.response?.statusCode}]',
          );
          print('❌ [ERROR DATA]: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  /// Extracts the most human-readable error message from an API exception.
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return "Server unreachable. Please check your network or if the server is running.";
      }

      if (error.type == DioExceptionType.connectionError) {
        return "Connection failed. Please ensure your device and server are on the same network.";
      }

      if (error.response?.data != null) {
        final data = error.response!.data;

        // Handle Laravel validation errors (422)
        if (data is Map && data['errors'] != null) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List) return firstError.first.toString();
          return firstError.toString();
        }

        // Handle standard Laravel message field
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
      }

      return "Something went wrong. [${error.response?.statusCode ?? 'Network Error'}]";
    }
    return error.toString();
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
