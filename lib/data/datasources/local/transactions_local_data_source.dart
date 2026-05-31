import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';

abstract class TransactionsLocalDataSource {
  Future<List<TransactionModel>> getAll();
  Future<TransactionModel?> getById(String id);
  Future<void> upsert(TransactionModel model);
  Future<void> delete(String id);
}

class TransactionsLocalDataSourceHive implements TransactionsLocalDataSource {
  TransactionsLocalDataSourceHive(this._box);

  final Box<Map> _box;

  factory TransactionsLocalDataSourceHive.open() {
    return TransactionsLocalDataSourceHive(Hive.box<Map>(AppBoxes.transactions));
  }

  @override
  Future<TransactionModel?> getById(String id) async {
    final map = _box.get(id);
    if (map == null) return null;
    return TransactionModel.fromMap(map);
  }

  @override
  Future<List<TransactionModel>> getAll() async {
    final items = _box.values
        .whereType<Map>()
        .map((m) => TransactionModel.fromMap(m))
        .toList();
    items.sort((a, b) => b.dateMs.compareTo(a.dateMs));
    return items;
  }

  @override
  Future<void> upsert(TransactionModel model) async {
    await _box.put(model.id, model.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}

