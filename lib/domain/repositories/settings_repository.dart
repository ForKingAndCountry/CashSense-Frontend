import '../entities/app_settings_entity.dart';

abstract class SettingsRepository {
  Future<AppSettingsEntity> load();
  Future<void> save(AppSettingsEntity settings);
}

