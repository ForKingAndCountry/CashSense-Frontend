import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../domain/entities/currency.dart';
import '../../../../domain/entities/debt_entity.dart';

final debtsProvider = AsyncNotifierProvider<DebtsNotifier, List<DebtEntity>>(DebtsNotifier.new);

class DebtsNotifier extends AsyncNotifier<List<DebtEntity>> {
  @override
  Future<List<DebtEntity>> build() async {
    return ref.read(debtsRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(debtsRepositoryProvider).getAll());
  }

  Future<void> add({
    required DebtType type,
    required String personName,
    required double amount,
    required Currency currency,
  }) async {
    final now = DateTime.now();
    final debt = DebtEntity(
      id: const Uuid().v4(),
      personName: personName,
      amount: amount,
      currency: currency,
      type: type,
      status: DebtStatus.pending,
      dueDate: null,
      synced: false,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(debtsRepositoryProvider).add(debt);
    state = AsyncData([debt, ...(state.value ?? const <DebtEntity>[])]);
  }

  Future<void> markPaid(DebtEntity debt, bool paid) async {
    final updated = DebtEntity(
      id: debt.id,
      personName: debt.personName,
      amount: debt.amount,
      currency: debt.currency,
      type: debt.type,
      status: paid ? DebtStatus.paid : DebtStatus.pending,
      dueDate: debt.dueDate,
      synced: false,
      createdAt: debt.createdAt,
      updatedAt: DateTime.now(),
    );

    await ref.read(debtsRepositoryProvider).update(updated);
    final list = [...(state.value ?? const <DebtEntity>[])];
    final idx = list.indexWhere((d) => d.id == debt.id);
    if (idx >= 0) list[idx] = updated;
    state = AsyncData(list);
  }
}

