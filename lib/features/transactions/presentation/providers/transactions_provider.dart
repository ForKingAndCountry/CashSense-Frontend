import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../domain/entities/currency.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/wallet_entity.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionEntity>>(TransactionsNotifier.new);

WalletEntity _pickWallet(List<WalletEntity> wallets, Currency c) {
  final m = wallets.where((w) => w.currency == c).toList();
  if (m.isNotEmpty) return m.first;
  return wallets.first;
}

class TransactionsNotifier extends AsyncNotifier<List<TransactionEntity>> {
  @override
  Future<List<TransactionEntity>> build() async {
    final wallets = await ref.watch(walletsProvider.future);
    var list = await ref.read(getTransactionsUseCaseProvider).call();
    final needs = list.where((t) => t.walletId == null).toList();
    if (needs.isNotEmpty) {
      for (final t in needs) {
        final w = _pickWallet(wallets, t.currency);
        await ref.read(addTransactionUseCaseProvider).call(t.copyWith(walletId: w.id));
      }
      list = await ref.read(getTransactionsUseCaseProvider).call();
    }
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(getTransactionsUseCaseProvider).call());
  }

  Future<void> add({
    required TransactionType type,
    required double amount,
    required Currency currency,
    required String walletId,
    required String category,
    required String note,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    final tx = TransactionEntity(
      id: const Uuid().v4(),
      type: type,
      amount: amount,
      currency: currency,
      category: category,
      date: date,
      note: note,
      synced: false,
      createdAt: now,
      updatedAt: now,
      walletId: walletId,
    );

    await ref.read(addTransactionUseCaseProvider).call(tx);

    final current = state.value ?? const <TransactionEntity>[];
    state = AsyncData([tx, ...current]);
  }
}
