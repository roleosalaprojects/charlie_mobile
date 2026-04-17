import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const String _defaultUrl = 'http://10.0.2.2:81/api/v1';
  static const storage = FlutterSecureStorage();

  static String? _cachedBaseUrl;

  static Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    _cachedBaseUrl = await storage.read(key: 'api_base_url') ?? _defaultUrl;
    return _cachedBaseUrl!;
  }

  static Future<void> setBaseUrl(String url) async {
    // Ensure it ends with /api/v1
    url = url.trimRight();
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    if (!url.endsWith('/api/v1')) url = '$url/api/v1';
    _cachedBaseUrl = url;
    await storage.write(key: 'api_base_url', value: url);
  }

  static Future<bool> hasBaseUrl() async {
    return await storage.read(key: 'api_base_url') != null;
  }

  static Dio createDio({String? baseUrl}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? _cachedBaseUrl ?? _defaultUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ensure base URL is current
        final currentBase = await getBaseUrl();
        if (options.baseUrl != currentBase) {
          options.baseUrl = currentBase;
        }
        final token = await storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ));
    }

    return dio;
  }

  static Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  static Future<void> clearToken() async {
    await storage.delete(key: 'auth_token');
  }
}
