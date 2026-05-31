import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../domain/entities/currency.dart';
import '../../../../domain/entities/wallet_entity.dart';
import '../../../../domain/repositories/wallets_repository.dart';
import '../../../../data/repositories/wallets_repository_impl.dart';

final walletsRepositoryProvider = Provider<WalletsRepository>((ref) {
  return WalletsRepositoryImpl(ref.read(walletsLocalProvider), ref.read(syncQueueProvider));
});

final walletsProvider = AsyncNotifierProvider<WalletsNotifier, List<WalletEntity>>(WalletsNotifier.new);

class WalletsNotifier extends AsyncNotifier<List<WalletEntity>> {
  @override
  Future<List<WalletEntity>> build() async {
    final repo = ref.read(walletsRepositoryProvider);
    var list = await repo.getAll();
    if (list.isEmpty) {
      final now = DateTime.now();
      await repo.upsert(
        WalletEntity(
          id: const Uuid().v4(),
          name: 'Cash (LRD)',
          currency: Currency.lrd,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repo.upsert(
        WalletEntity(
          id: const Uuid().v4(),
          name: 'Cash (USD)',
          currency: Currency.usd,
          createdAt: now,
          updatedAt: now,
        ),
      );
      list = await repo.getAll();
    }
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(walletsRepositoryProvider).getAll());
  }

  Future<void> addWallet({required String name, required Currency currency}) async {
    final now = DateTime.now();
    await ref.read(walletsRepositoryProvider).upsert(
          WalletEntity(
            id: const Uuid().v4(),
            name: name.trim().isEmpty ? 'Wallet' : name.trim(),
            currency: currency,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await refresh();
  }

  Future<void> deleteWallet(String id) async {
    await ref.read(walletsRepositoryProvider).delete(id);
    await refresh();
  }
}
