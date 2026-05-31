import 'subscription_status.dart';

class SubscriptionEntity {
  const SubscriptionEntity({
    required this.status,
    required this.isActiveNow,
    required this.lastVerified,
    required this.expiryDate,
    this.remoteIsActive,
    this.trialStartDate,
    this.trialEndDate,
    this.lastPaymentDate,
  });

  final SubscriptionStatus status;

  /// Whether the app should currently allow write actions.
  final bool isActiveNow;

  final DateTime lastVerified;
  final DateTime? expiryDate;

  /// Raw server `is_active` if known.
  final bool? remoteIsActive;

  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? lastPaymentDate;

  bool get isSoftLocked => !isActiveNow && status == SubscriptionStatus.expired;

  static SubscriptionEntity trial({
    DateTime? verifiedAt,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
  }) {
    final now = verifiedAt ?? DateTime.now();
    return SubscriptionEntity(
      status: SubscriptionStatus.trial,
      isActiveNow: true,
      lastVerified: now,
      expiryDate: null,
      remoteIsActive: true,
      trialStartDate: trialStartDate,
      trialEndDate: trialEndDate,
    );
  }

  static SubscriptionEntity expired({
    DateTime? verifiedAt,
    DateTime? expiryDate,
    bool? remoteIsActive,
    DateTime? lastPaymentDate,
  }) {
    return SubscriptionEntity(
      status: SubscriptionStatus.expired,
      isActiveNow: false,
      lastVerified: verifiedAt ?? DateTime.now(),
      expiryDate: expiryDate,
      remoteIsActive: remoteIsActive,
      lastPaymentDate: lastPaymentDate,
    );
  }

  static SubscriptionEntity grace({
    required DateTime verifiedAt,
    DateTime? expiryDate,
    bool? remoteIsActive,
  }) {
    return SubscriptionEntity(
      status: SubscriptionStatus.grace,
      isActiveNow: true,
      lastVerified: verifiedAt,
      expiryDate: expiryDate,
      remoteIsActive: remoteIsActive,
    );
  }
}

