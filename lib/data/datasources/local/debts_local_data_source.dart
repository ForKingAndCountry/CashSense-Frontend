import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/debt_model.dart';

abstract class DebtsLocalDataSource {
  Future<List<DebtModel>> getAll();
  Future<DebtModel?> getById(String id);
  Future<void> upsert(DebtModel model);
}

class DebtsLocalDataSourceHive implements DebtsLocalDataSource {
  DebtsLocalDataSourceHive(this._box);

  final Box<Map> _box;

  factory DebtsLocalDataSourceHive.open() {
    return DebtsLocalDataSourceHive(Hive.box<Map>(AppBoxes.debts));
  }

  @override
  Future<List<DebtModel>> getAll() async {
    final items = _box.values.whereType<Map>().map(DebtModel.fromMap).toList();
    items.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return items;
  }

  @override
  Future<DebtModel?> getById(String id) async {
    final map = _box.get(id);
    if (map == null) return null;
    return DebtModel.fromMap(map);
  }

  @override
  Future<void> upsert(DebtModel model) async {
    await _box.put(model.id, model.toMap());
  }
}

