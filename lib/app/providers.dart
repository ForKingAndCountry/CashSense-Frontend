import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'auth_refresh.dart';

import '../core/services/currency_service.dart';
import '../data/datasources/local/allocation_plans_local_data_source.dart';
import '../data/datasources/local/buffers_local_data_source.dart';
import '../data/datasources/local/debts_local_data_source.dart';
import '../data/datasources/local/settings_local_data_source.dart';
import '../data/datasources/local/transactions_local_data_source.dart';
import '../data/datasources/local/wallets_local_data_source.dart';
import '../data/repositories/debts_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../data/repositories/transactions_repository_impl.dart';
import '../domain/entities/app_settings_entity.dart';
import '../domain/repositories/debts_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/transactions_repository.dart';
import '../domain/usecases/transactions/add_transaction.dart';
import '../domain/usecases/transactions/get_transactions.dart';
import '../sync/sync_manager.dart';
import '../sync/sync_queue.dart';

import '../features/subscription/data/subscription_local_repository.dart';
import '../features/subscription/data/subscription_remote_service.dart';
import '../features/subscription/data/subscription_service.dart';
import '../features/subscription/domain/subscription_entity.dart';
import '../features/subscription/presentation/subscription_notifier.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

final authRefreshListenableProvider = Provider<AuthRefreshListenable>((ref) {
  final n = AuthRefreshListenable();
  ref.onDispose(n.dispose);
  return n;
});

final syncQueueProvider = Provider<SyncQueue>((ref) => HiveSyncQueue.open());

final transactionsLocalProvider =
    Provider<TransactionsLocalDataSource>((ref) => TransactionsLocalDataSourceHive.open());
final debtsLocalProvider =
    Provider<DebtsLocalDataSource>((ref) => DebtsLocalDataSourceHive.open());
final walletsLocalProvider =
    Provider<WalletsLocalDataSource>((ref) => WalletsLocalDataSourceHive.open());
final buffersLocalProvider =
    Provider<BuffersLocalDataSource>((ref) => BuffersLocalDataSourceHive.open());
final allocationPlansLocalProvider =
    Provider<AllocationPlansLocalDataSource>((ref) => AllocationPlansLocalDataSourceHive.open());
final settingsLocalProvider =
    Provider<SettingsLocalDataSource>((ref) => SettingsLocalDataSourceHive.open());

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepositoryImpl(ref.read(transactionsLocalProvider), ref.read(syncQueueProvider));
});

final debtsRepositoryProvider = Provider<DebtsRepository>((ref) {
  return DebtsRepositoryImpl(ref.read(debtsLocalProvider), ref.read(syncQueueProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.read(settingsLocalProvider));
});

final addTransactionUseCaseProvider =
    Provider<AddTransaction>((ref) => AddTransaction(ref.read(transactionsRepositoryProvider)));
final getTransactionsUseCaseProvider =
    Provider<GetTransactions>((ref) => GetTransactions(ref.read(transactionsRepositoryProvider)));

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettingsEntity>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<AppSettingsEntity> {
  @override
  Future<AppSettingsEntity> build() async {
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> setSettings(AppSettingsEntity next) async {
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }
}

final currencyServiceProvider = Provider<CurrencyService>((ref) {
  final settings = ref.watch(settingsProvider).value ?? AppSettingsEntity.defaults;
  return CurrencyService(settings);
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager(
    queue: ref.read(syncQueueProvider),
    transactionsLocal: ref.read(transactionsLocalProvider),
    debtsLocal: ref.read(debtsLocalProvider),
    walletsLocal: ref.read(walletsLocalProvider),
    buffersLocal: ref.read(buffersLocalProvider),
    allocationPlansLocal: ref.read(allocationPlansLocalProvider),
  );
});

// ----------------------------
// Subscription (soft lock)
// ----------------------------

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final subscriptionLocalRepositoryProvider =
    Provider<SubscriptionLocalRepository>((ref) => SubscriptionLocalRepositoryHive.open());

final subscriptionRemoteServiceProvider = Provider<SubscriptionRemoteService>(
  (ref) => SubscriptionRemoteService(),
);

final subscriptionServiceProvider = Provider<SubscriptionService>(
  (ref) => SubscriptionService(ref.read(subscriptionRemoteServiceProvider)),
);

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionEntity?>((ref) {
  return SubscriptionNotifier(
    localRepo: ref.read(subscriptionLocalRepositoryProvider),
    service: ref.read(subscriptionServiceProvider),
    connectivity: ref.read(connectivityProvider),
  );
});

final canWriteProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider)?.isActiveNow ?? true;
});

/// Avoids showing the trial-ended upgrade dialog more than once per app session.
final upgradeModalShownThisSessionProvider = StateProvider<bool>((ref) => false);


