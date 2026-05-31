import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/api_config.dart';
import '../domain/subscription_entity.dart';
import '../domain/subscription_status.dart';

class SubscriptionRemoteService {
  SubscriptionRemoteService({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  })  : _dio = dio ??
            Dio(BaseOptions(baseUrl: ApiConfig.baseUrl, connectTimeout: const Duration(seconds: 10))),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  Future<SubscriptionEntity?> fetchRemoteStatus(String userId) async {
    try {
      final token = await _secureStorage.read(key: 'auth_jwt_token');
      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await _dio.get(
        '/api/subscription/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['subscription'] as Map<String, dynamic>;
        final statusRaw = (data['status'] as String?)?.toLowerCase() ?? 'trial';
        final endsAtStr = data['endsAt'] as String?;

        final expiryDate = endsAtStr != null ? DateTime.parse(endsAtStr) : null;
        final now = DateTime.now();
        final autoExpired = expiryDate != null && now.isAfter(expiryDate);

        final status = switch (statusRaw) {
          'trial' => SubscriptionStatus.trial,
          'active' => autoExpired ? SubscriptionStatus.expired : SubscriptionStatus.active,
          'expired' => SubscriptionStatus.expired,
          'grace' => SubscriptionStatus.grace,
          _ => autoExpired ? SubscriptionStatus.expired : SubscriptionStatus.active,
        };

        final isActiveNow = status == SubscriptionStatus.trial || status == SubscriptionStatus.active;

        return SubscriptionEntity(
          status: status,
          isActiveNow: isActiveNow,
          lastVerified: DateTime.now(),
          expiryDate: expiryDate,
          remoteIsActive: isActiveNow,
          trialStartDate: DateTime.now().subtract(const Duration(days: 10)),
          trialEndDate: expiryDate,
          lastPaymentDate: DateTime.now(),
        );
      }
    } catch (e) {
      print('SubscriptionRemoteService failed to fetch status: $e');
    }
    return null;
  }
}


