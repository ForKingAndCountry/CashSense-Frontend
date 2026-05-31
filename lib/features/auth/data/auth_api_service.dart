import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/api_config.dart';
import '../../../domain/entities/auth_user_entity.dart';

class AuthApiException implements Exception {
  AuthApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthApiService {
  AuthApiService({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
            )),
        _storage = secureStorage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_jwt_token';
  static const _userIdKey = 'auth_user_id';
  static const _userEmailKey = 'auth_user_email';
  static const _userNameKey = 'auth_user_name';
  static const _userCurrencyKey = 'auth_user_base_currency';

  Future<AuthUserEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    return _parseAuthResponse(response.data);
  }

  Future<AuthUserEntity> register({
    required String name,
    required String email,
    required String password,
    String baseCurrency = 'LRD',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'baseCurrency': baseCurrency,
      },
    );
    return _parseAuthResponse(response.data);
  }

  Future<AuthUserEntity> _parseAuthResponse(Map<String, dynamic>? data) async {
    if (data == null || data['success'] != true) {
      throw AuthApiException(_messageFromBody(data) ?? 'Authentication failed');
    }
    final token = data['token'] as String?;
    final userMap = data['user'] as Map<String, dynamic>?;
    if (token == null || token.isEmpty || userMap == null) {
      throw AuthApiException('Invalid server response');
    }

    final user = AuthUserEntity(
      id: userMap['id']?.toString() ?? '',
      email: (userMap['email'] as String?) ?? '',
      name: (userMap['name'] as String?) ?? '',
      baseCurrency: (userMap['baseCurrency'] as String?) ?? 'LRD',
    );

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: user.id);
    await _storage.write(key: _userEmailKey, value: user.email);
    await _storage.write(key: _userNameKey, value: user.name);
    await _storage.write(key: _userCurrencyKey, value: user.baseCurrency);

    return user;
  }

  Future<AuthUserEntity?> readSession() async {
    final token = await _storage.read(key: _tokenKey);
    final id = await _storage.read(key: _userIdKey);
    final email = await _storage.read(key: _userEmailKey);
    if (token == null || token.isEmpty || id == null || email == null) return null;

    return AuthUserEntity(
      id: id,
      email: email,
      name: await _storage.read(key: _userNameKey) ?? '',
      baseCurrency: await _storage.read(key: _userCurrencyKey) ?? 'LRD',
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userCurrencyKey);
  }

  String? _messageFromBody(Map<String, dynamic>? data) {
    final err = data?['error'];
    if (err is String && err.isNotEmpty) return err;
    return null;
  }

  static String messageFromError(Object e) {
    if (e is AuthApiException) return e.message;
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) return data['error'] as String;
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Cannot reach the server. Is the API running at ${ApiConfig.baseUrl}?';
      }
      if (e.response?.statusCode == 401) return 'Email or password is incorrect.';
    }
    return 'Something went wrong. Please try again.';
  }
}
