import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/subscription_entity.dart';
import '../domain/subscription_status.dart';

abstract class SubscriptionLocalRepository {
  Future<SubscriptionEntity?> load();
  Future<void> save(SubscriptionEntity subscription);
}

class SubscriptionLocalRepositoryHive implements SubscriptionLocalRepository {
  SubscriptionLocalRepositoryHive(this._box);

  final Box<Map> _box;

  static const _key = 'subscription';

  factory SubscriptionLocalRepositoryHive.open() {
    return SubscriptionLocalRepositoryHive(Hive.box<Map>(AppBoxes.subscription));
  }

  @override
  Future<SubscriptionEntity?> load() async {
    final map = _box.get(_key);
    if (map == null) return null;

    final statusRaw = (map['subscription_status'] as String?)?.toLowerCase();
    final isActive = (map['is_active'] as bool?) ?? false;

    final lastVerifiedMs = map['last_verified'] as int?;
    final expiryDateMs = map['expiry_date'] as int?;
    final lastVerified = lastVerifiedMs == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(lastVerifiedMs);
    final expiryDate = expiryDateMs == null ? null : DateTime.fromMillisecondsSinceEpoch(expiryDateMs);

    final status = switch (statusRaw) {
      'trial' => SubscriptionStatus.trial,
      'active' => SubscriptionStatus.active,
      'grace' => SubscriptionStatus.grace,
      'expired' => SubscriptionStatus.expired,
      _ => (expiryDate != null && DateTime.now().isAfter(expiryDate)) ? SubscriptionStatus.expired : SubscriptionStatus.active,
    };

    // When reading local cache, preserve the stored status as-is.
    final isActiveNow = status == SubscriptionStatus.trial || status == SubscriptionStatus.active || status == SubscriptionStatus.grace
        ? true
        : isActive;

    return SubscriptionEntity(
      status: status,
      isActiveNow: isActiveNow,
      lastVerified: lastVerified,
      expiryDate: expiryDate,
      remoteIsActive: map['remote_is_active'] as bool?,
    );
  }

  @override
  Future<void> save(SubscriptionEntity subscription) async {
    final statusRaw = switch (subscription.status) {
      SubscriptionStatus.trial => 'trial',
      SubscriptionStatus.active => 'active',
      SubscriptionStatus.expired => 'expired',
      SubscriptionStatus.grace => 'grace',
    };

    await _box.put(_key, {
      'subscription_status': statusRaw,
      'is_active': subscription.isActiveNow,
      'remote_is_active': subscription.remoteIsActive,
      'last_verified': subscription.lastVerified.millisecondsSinceEpoch,
      'expiry_date': subscription.expiryDate?.millisecondsSinceEpoch,
    });
  }
}

