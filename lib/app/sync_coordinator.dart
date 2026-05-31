import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/debts/presentation/providers/debts_provider.dart';
import '../features/transactions/presentation/providers/transactions_provider.dart';
import '../features/wallets/presentation/providers/wallets_provider.dart';
import '../features/buffers/presentation/providers/buffers_provider.dart';
import '../features/allocation/presentation/providers/allocation_plan_provider.dart';
import 'providers.dart';

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) => SyncCoordinator(ref));

class SyncCoordinator {
  SyncCoordinator(this._ref);

  final Ref _ref;

  Future<void> runFullSync() async {
    try {
      await _ref.read(syncManagerProvider).sync();
    } catch (_) {}
    await _ref.read(transactionsProvider.notifier).refresh();
    await _ref.read(debtsProvider.notifier).refresh();
    await _ref.read(walletsProvider.notifier).refresh();
    await _ref.read(buffersProvider.notifier).refresh();
    await _ref.read(allocationPlanProvider.notifier).refresh();
  }
}
