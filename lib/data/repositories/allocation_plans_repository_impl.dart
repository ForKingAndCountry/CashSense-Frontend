import 'package:uuid/uuid.dart';

import '../../domain/entities/allocation_plan_entity.dart';
import '../../domain/repositories/allocation_plans_repository.dart';
import '../../sync/sync_queue.dart';
import '../datasources/local/allocation_plans_local_data_source.dart';
import '../models/allocation_plan_model.dart';

class AllocationPlansRepositoryImpl implements AllocationPlansRepository {
  AllocationPlansRepositoryImpl(this._local, this._syncQueue);

  final AllocationPlansLocalDataSource _local;
  final SyncQueue _syncQueue;

  @override
  Future<AllocationPlanEntity> getDefault() async {
    final model = await _local.getDefault();
    if (model != null) return model.toEntity();
    final now = DateTime.now();
    final defaults = AllocationPlanEntity.defaults(id: const Uuid().v4(), now: now);
    await _local.upsert(AllocationPlanModel.fromEntity(defaults));
    return defaults;
  }

  @override
  Future<void> save(AllocationPlanEntity plan) async {
    final now = DateTime.now();
    final model = AllocationPlanModel.fromEntity(
      plan.copyWith(updatedAt: now, synced: false),
    );
    await _local.upsert(model);
    await _syncQueue.enqueue(SyncQueueItem.allocationPlanUpsert(planId: model.id));
  }

  @override
  Future<void> clear() => _local.clear();
}
