import '../../domain/entities/debt_entity.dart';
import '../../domain/repositories/debts_repository.dart';
import '../../sync/sync_queue.dart';
import '../datasources/local/debts_local_data_source.dart';
import '../models/debt_model.dart';

class DebtsRepositoryImpl implements DebtsRepository {
  DebtsRepositoryImpl(this._local, this._syncQueue);

  final DebtsLocalDataSource _local;
  final SyncQueue _syncQueue;

  @override
  Future<void> add(DebtEntity debt) async {
    final model = DebtModel.fromEntity(debt);
    await _local.upsert(model);
    await _syncQueue.enqueue(SyncQueueItem.debtUpsert(debtId: model.id));
  }

  @override
  Future<List<DebtEntity>> getAll() async {
    final models = await _local.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> update(DebtEntity debt) async {
    final model = DebtModel.fromEntity(debt);
    await _local.upsert(model);
    await _syncQueue.enqueue(SyncQueueItem.debtUpsert(debtId: model.id));
  }
}

