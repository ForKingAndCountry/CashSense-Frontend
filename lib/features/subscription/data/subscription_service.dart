import '../domain/subscription_entity.dart';
import '../domain/subscription_status.dart';
import 'subscription_remote_service.dart';

class SubscriptionService {
  SubscriptionService(this._remote);

  final SubscriptionRemoteService _remote;

  Future<SubscriptionEntity?> fetchRemoteStatus(String userId) {
    return _remote.fetchRemoteStatus(userId);
  }

  bool isExpired(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate);
  }

  bool isWithinGrace(DateTime lastVerified) {
    final diff = DateTime.now().difference(lastVerified).inDays;
    return diff <= 3; // 3-day offline grace
  }

  bool looksLikeDeviceTimeCheating({required DateTime lastVerified}) {
    // If the server says we verified in the future, consider it suspicious.
    return lastVerified.isAfter(DateTime.now().add(const Duration(hours: 1)));
  }

  SubscriptionEntity applyOfflineGrace({
    required SubscriptionEntity local,
  }) {
    if (looksLikeDeviceTimeCheating(lastVerified: local.lastVerified)) {
      // If server verification looks "from the future", lock down to prevent time cheating.
      return SubscriptionEntity.expired(
        verifiedAt: local.lastVerified,
        expiryDate: local.expiryDate,
        remoteIsActive: local.remoteIsActive,
      );
    }

    if (local.status == SubscriptionStatus.trial || local.status == SubscriptionStatus.active) {
      return local;
    }

    // If locally expired but still within grace, allow writes with a warning.
    if (isWithinGrace(local.lastVerified)) {
      return SubscriptionEntity.grace(
        verifiedAt: local.lastVerified,
        expiryDate: local.expiryDate,
        remoteIsActive: local.remoteIsActive,
      );
    }

    return local;
  }
}

