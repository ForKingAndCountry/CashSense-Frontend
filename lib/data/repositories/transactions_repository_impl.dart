import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../../sync/sync_queue.dart';
import '../datasources/local/transactions_local_data_source.dart';
import '../models/transaction_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._local, this._syncQueue);

  final TransactionsLocalDataSource _local;
  final SyncQueue _syncQueue;

  @override
  Future<void> add(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _local.upsert(model);
    await _syncQueue.enqueue(
      SyncQueueItem.transactionUpsert(transactionId: model.id),
    );
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    await _syncQueue.enqueue(SyncQueueItem.transactionDelete(transactionId: id));
  }

  @override
  Future<List<TransactionEntity>> getAll() async {
    final models = await _local.getAll();
    return models.map((m) => m.toEntity()).toList();
  }
}

