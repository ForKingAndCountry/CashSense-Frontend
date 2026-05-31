import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../data/repositories/allocation_plans_repository_impl.dart';
import '../../../../domain/entities/allocation_plan_entity.dart';
import '../../../../domain/repositories/allocation_plans_repository.dart';

final allocationPlansRepositoryProvider = Provider<AllocationPlansRepository>((ref) {
  return AllocationPlansRepositoryImpl(
    ref.read(allocationPlansLocalProvider),
    ref.read(syncQueueProvider),
  );
});

final allocationPlanProvider =
    AsyncNotifierProvider<AllocationPlanNotifier, AllocationPlanEntity>(AllocationPlanNotifier.new);

class AllocationPlanNotifier extends AsyncNotifier<AllocationPlanEntity> {
  @override
  Future<AllocationPlanEntity> build() async {
    return ref.read(allocationPlansRepositoryProvider).getDefault();
  }

  Future<void> save(AllocationPlanEntity plan) async {
    await ref.read(allocationPlansRepositoryProvider).save(plan);
    state = AsyncData(await ref.read(allocationPlansRepositoryProvider).getDefault());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(allocationPlansRepositoryProvider).getDefault());
  }
}
