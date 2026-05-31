import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_data_source.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local);

  final SettingsLocalDataSource _local;

  @override
  Future<AppSettingsEntity> load() async {
    final model = await _local.load();
    return (model ?? SettingsModel.fromEntity(AppSettingsEntity.defaults)).toEntity();
  }

  @override
  Future<void> save(AppSettingsEntity settings) {
    return _local.save(SettingsModel.fromEntity(settings));
  }
}

