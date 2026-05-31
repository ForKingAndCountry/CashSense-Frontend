import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../core/constants/app_constants.dart';
import '../domain/entities/auth_user_entity.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/debts/presentation/providers/debts_provider.dart';
import '../features/transactions/presentation/providers/transactions_provider.dart';
import '../features/wallets/presentation/providers/wallets_provider.dart';
import '../features/buffers/presentation/providers/buffers_provider.dart';
import '../features/allocation/presentation/providers/allocation_plan_provider.dart';
import 'providers.dart';
import 'sync_coordinator.dart';

/// Triggers sync on app start and when connectivity returns (non-blocking).
class SyncLifecycleScope extends ConsumerStatefulWidget {
  const SyncLifecycleScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncLifecycleScope> createState() => _SyncLifecycleScopeState();
}

class _SyncLifecycleScopeState extends ConsumerState<SyncLifecycleScope> {
  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<void> _clearUserScopedLocalCaches() async {
    await Hive.box<Map>(AppBoxes.transactions).clear();
    await Hive.box<Map>(AppBoxes.debts).clear();
    await Hive.box<Map>(AppBoxes.syncQueue).clear();
    await Hive.box<Map>(AppBoxes.subscription).clear();
    await Hive.box<Map>(AppBoxes.wallets).clear();
    await Hive.box<Map>(AppBoxes.buffers).clear();
    await Hive.box<Map>(AppBoxes.allocationPlans).clear();

    ref.invalidate(transactionsProvider);
    ref.invalidate(debtsProvider);
    ref.invalidate(subscriptionProvider);
    ref.invalidate(walletsProvider);
    ref.invalidate(buffersProvider);
    ref.invalidate(allocationPlanProvider);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncIfLoggedIn();
    });
    _sub = ref.read(connectivityProvider).onConnectivityChanged.listen((_) {
      _syncIfLoggedIn();
    });
  }

  void _syncIfLoggedIn() {
    if (ref.read(authSessionProvider) != null) {
      unawaited(ref.read(syncCoordinatorProvider).runFullSync());
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthUserEntity?>(authSessionProvider, (prev, next) {
      final prevId = prev?.id;
      final nextId = next?.id;

      if (prevId != null && nextId != prevId) {
        unawaited(_clearUserScopedLocalCaches());
      }

      if (nextId != null) {
        unawaited(ref.read(syncCoordinatorProvider).runFullSync());
      }
    });

    return widget.child;
  }
}
