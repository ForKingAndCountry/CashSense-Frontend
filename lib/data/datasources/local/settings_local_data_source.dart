import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel?> load();
  Future<void> save(SettingsModel model);
}

class SettingsLocalDataSourceHive implements SettingsLocalDataSource {
  SettingsLocalDataSourceHive(this._box);

  final Box<Map> _box;

  static const _key = 'settings';

  factory SettingsLocalDataSourceHive.open() {
    return SettingsLocalDataSourceHive(Hive.box<Map>(AppBoxes.settings));
  }

  @override
  Future<SettingsModel?> load() async {
    final map = _box.get(_key);
    if (map == null) return null;
    return SettingsModel.fromMap(map);
  }

  @override
  Future<void> save(SettingsModel model) async {
    await _box.put(_key, model.toMap());
  }
}

