import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String baseUrlProduction = 'https://apivsignvn.social/api/v1';
  static const String baseUrlEmulator = 'http://10.0.2.2:8080/api/v1'; // Android Emulator local loopback
  
  ApiClient({Dio? customDio}) : dio = customDio ?? Dio() {
    dio.options.baseUrl = baseUrlProduction;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    
    // Add Interceptors for JWT auth & Logging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle 401 Unauthorized - Token Refresh flow
        if (e.response?.statusCode == 401) {
          final success = await _attemptTokenRefresh();
          if (success) {
            // Retry the original request
            final options = e.requestOptions;
            final token = await _secureStorage.read(key: 'accessToken');
            options.headers['Authorization'] = 'Bearer $token';
            
            try {
              final response = await dio.fetch(options);
              return handler.resolve(response);
            } catch (err) {
              return handler.reject(DioException(
                requestOptions: options,
                error: err,
              ));
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<bool> _attemptTokenRefresh() async {
    final refreshToken = await _secureStorage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    try {
      // Call token refresh endpoint
      final response = await Dio().post(
        '$baseUrlProduction/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        if (newAccessToken != null) {
          await _secureStorage.write(key: 'accessToken', value: newAccessToken);
          if (newRefreshToken != null) {
            await _secureStorage.write(key: 'refreshToken', value: newRefreshToken);
          }
          return true;
        }
      }
    } catch (e) {
      // Refresh token is invalid or expired, clear storage
      await clearAuthTokens();
    }
    return false;
  }

  Future<void> saveAuthTokens(String accessToken, String? refreshToken) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: 'refreshToken', value: refreshToken);
    }
  }

  Future<void> clearAuthTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'accessToken');
    return token != null;
  }
}
