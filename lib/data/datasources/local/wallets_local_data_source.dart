import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/wallet_model.dart';

abstract class WalletsLocalDataSource {
  Future<List<WalletModel>> getAll();
  Future<WalletModel?> getById(String id);
  Future<void> upsert(WalletModel model);
  Future<void> delete(String id);
  Future<void> clear();
}

class WalletsLocalDataSourceHive implements WalletsLocalDataSource {
  WalletsLocalDataSourceHive(this._box);

  final Box<Map> _box;

  factory WalletsLocalDataSourceHive.open() {
    return WalletsLocalDataSourceHive(Hive.box<Map>(AppBoxes.wallets));
  }

  @override
  Future<List<WalletModel>> getAll() async {
    final items = _box.values
        .whereType<Map>()
        .map(WalletModel.fromMap)
        .where((m) => !m.deleted)
        .toList();
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  @override
  Future<WalletModel?> getById(String id) async {
    final map = _box.get(id);
    if (map is! Map) return null;
    return WalletModel.fromMap(map);
  }

  @override
  Future<void> upsert(WalletModel model) async {
    await _box.put(model.id, model.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
