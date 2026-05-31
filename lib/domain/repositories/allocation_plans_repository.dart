import '../../domain/entities/allocation_plan_entity.dart';

abstract class AllocationPlansRepository {
  Future<AllocationPlanEntity> getDefault();
  Future<void> save(AllocationPlanEntity plan);
  Future<void> clear();
}
