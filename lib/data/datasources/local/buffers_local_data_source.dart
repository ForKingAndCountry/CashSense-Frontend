import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/buffer_model.dart';

abstract class BuffersLocalDataSource {
  Future<List<BufferModel>> getAll();
  Future<BufferModel?> getById(String id);
  Future<void> upsert(BufferModel model);
  Future<void> delete(String id);
  Future<void> clear();
}

class BuffersLocalDataSourceHive implements BuffersLocalDataSource {
  BuffersLocalDataSourceHive(this._box);

  final Box<Map> _box;

  factory BuffersLocalDataSourceHive.open() {
    return BuffersLocalDataSourceHive(Hive.box<Map>(AppBoxes.buffers));
  }

  @override
  Future<List<BufferModel>> getAll() async {
    final items = _box.values
        .whereType<Map>()
        .map(BufferModel.fromMap)
        .where((m) => !m.deleted)
        .toList();
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  @override
  Future<BufferModel?> getById(String id) async {
    final map = _box.get(id);
    if (map is! Map) return null;
    return BufferModel.fromMap(map);
  }

  @override
  Future<void> upsert(BufferModel model) async {
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
