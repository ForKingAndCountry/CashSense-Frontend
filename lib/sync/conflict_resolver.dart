import '../data/models/debt_model.dart';
import '../data/models/transaction_model.dart';

/// Client-side last-write-wins using `updated_at` (ms), per PRD MVP.
class ConflictResolver {
  const ConflictResolver();

  TransactionModel mergeTransaction(TransactionModel? local, TransactionModel remote) {
    if (local == null) return remote.copyWith(synced: true);
    if (local.updatedAtMs >= remote.updatedAtMs) return local;
    return remote.copyWith(synced: true);
  }

  DebtModel mergeDebt(DebtModel? local, DebtModel remote) {
    if (local == null) return remote.copyWith(synced: true);
    if (local.updatedAtMs >= remote.updatedAtMs) return local;
    return remote.copyWith(synced: true);
  }
}

