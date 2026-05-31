import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/allocation_plan_model.dart';

abstract class AllocationPlansLocalDataSource {
  Future<AllocationPlanModel?> getDefault();
  Future<void> upsert(AllocationPlanModel model);
  Future<void> clear();
}

class AllocationPlansLocalDataSourceHive implements AllocationPlansLocalDataSource {
  AllocationPlansLocalDataSourceHive(this._box);

  final Box<Map> _box;
  static const _defaultKey = 'default_plan';

  factory AllocationPlansLocalDataSourceHive.open() {
    return AllocationPlansLocalDataSourceHive(Hive.box<Map>(AppBoxes.allocationPlans));
  }

  @override
  Future<AllocationPlanModel?> getDefault() async {
    final map = _box.get(_defaultKey);
    if (map is! Map) return null;
    return AllocationPlanModel.fromMap(map);
  }

  @override
  Future<void> upsert(AllocationPlanModel model) async {
    await _box.put(_defaultKey, model.toMap());
  }

  @override
  Future<void> clear() async {
    await _box.delete(_defaultKey);
  }
}
