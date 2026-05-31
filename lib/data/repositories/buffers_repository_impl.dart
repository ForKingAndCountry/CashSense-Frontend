import '../../domain/entities/buffer_entity.dart';
import '../../domain/repositories/buffers_repository.dart';
import '../../sync/sync_queue.dart';
import '../datasources/local/buffers_local_data_source.dart';
import '../models/buffer_model.dart';

class BuffersRepositoryImpl implements BuffersRepository {
  BuffersRepositoryImpl(this._local, this._syncQueue);

  final BuffersLocalDataSource _local;
  final SyncQueue _syncQueue;

  @override
  Future<List<BufferEntity>> getAll() async {
    final models = await _local.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> upsert(BufferEntity buffer) async {
    final model = BufferModel.fromEntity(buffer);
    await _local.upsert(model);
    await _syncQueue.enqueue(SyncQueueItem.bufferUpsert(bufferId: model.id));
  }

  @override
  Future<void> delete(String id) async {
    final existing = await _local.getById(id);
    if (existing == null) return;
    final now = DateTime.now();
    await _local.upsert(existing.copyWith(
      deleted: true,
      synced: false,
      updatedAtMs: now.millisecondsSinceEpoch,
    ));
    await _syncQueue.enqueue(SyncQueueItem.bufferDelete(bufferId: id));
  }

  @override
  Future<void> fund(String id, double amount) async {
    final existing = await _local.getById(id);
    if (existing == null) return;
    final now = DateTime.now();
    final updated = existing.copyWith(
      currentBalance: existing.currentBalance + amount,
      synced: false,
      updatedAtMs: now.millisecondsSinceEpoch,
    );
    await _local.upsert(updated);
    await _syncQueue.enqueue(SyncQueueItem.bufferUpsert(bufferId: id));
  }

  @override
  Future<void> clear() => _local.clear();
}
