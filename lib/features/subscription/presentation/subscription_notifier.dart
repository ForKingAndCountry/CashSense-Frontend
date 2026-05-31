import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/subscription_service.dart';
import '../data/subscription_local_repository.dart';
import '../domain/subscription_entity.dart';
import '../domain/subscription_status.dart';

class SubscriptionNotifier extends StateNotifier<SubscriptionEntity?> {
  SubscriptionNotifier({
    required this.localRepo,
    required this.service,
    required this.connectivity,
  }) : super(null) {
    // Bootstrap in background; UI listens via provider.
    unawaited(bootstrap());
  }

  final SubscriptionLocalRepository localRepo;
  final SubscriptionService service;
  final Connectivity connectivity;

  bool get canWriteNow => state?.isActiveNow ?? true;

  Future<void> bootstrap() async {
    final local = await localRepo.load();
    final initial = local ?? SubscriptionEntity.trial();

    // If we already have a cached status, apply offline grace rules immediately.
    state = local == null ? initial : service.applyOfflineGrace(local: initial);

    final isOnline = await _isOnline();
    if (!isOnline) return;

    final userId = await _ensureUserId();
    if (userId == null) return;

    SubscriptionEntity? remote;
    try {
      remote = await service.fetchRemoteStatus(userId);
    } catch (_) {
      remote = null;
    }
    if (remote == null) return;

    // When online: trust the Next.js subscription API.
    await localRepo.save(remote);
    state = remote;
  }

  Future<void> verifyPayment() async {
    final isOnline = await _isOnline();
    if (!isOnline) return;

    final userId = await _ensureUserId();
    if (userId == null) return;

    SubscriptionEntity? remote;
    try {
      remote = await service.fetchRemoteStatus(userId);
    } catch (_) {
      remote = null;
    }
    if (remote == null) return;

    await localRepo.save(remote);
    state = remote;
  }

  Future<bool> _isOnline() async {
    try {
      final res = await connectivity.checkConnectivity();
      return res.isNotEmpty && res.first != ConnectivityResult.none;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _ensureUserId() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_jwt_token');
      if (token != null && token.isNotEmpty) {
        return 'authenticated_user';
      }
    } catch (_) {}
    return null;
  }

  // Used by UI to display the correct message.
  bool get shouldPromptUpgrade {
    if (state == null) return false;
    return state!.status == SubscriptionStatus.expired && !state!.isActiveNow;
  }
}

void unawaited(Future<void> f) {}

