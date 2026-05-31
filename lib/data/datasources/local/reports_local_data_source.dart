import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/report_entity.dart';

class ReportsLocalDataSource {
  Box<Map> get _box => Hive.box<Map>(AppBoxes.reports);

  List<ReportEntity> loadAll() {
    final items = <ReportEntity>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        items.add(ReportEntity.fromMap(Map<String, dynamic>.from(raw)));
      }
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> save(ReportEntity report) async {
    await _box.put(report.id, report.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
