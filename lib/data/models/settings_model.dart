import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/currency.dart';

class SettingsModel {
  const SettingsModel({
    required this.baseCurrencyCode,
    required this.exchangeRateUsdToLrd,
    required this.lastBackupAtMs,
    this.ratesToBase = const {},
  });

  final String baseCurrencyCode;
  final double exchangeRateUsdToLrd;
  final int? lastBackupAtMs;

  /// Keys: currency codes (`USD`, `NGN`, …). Values: base units per 1 unit of that currency.
  final Map<String, double> ratesToBase;

  Map<String, Object?> toMap() => {
        'base_currency': baseCurrencyCode,
        'exchange_rate': exchangeRateUsdToLrd,
        'last_backup_at': lastBackupAtMs,
        'rates_to_base': ratesToBase,
      };

  static Map<String, double> _parseRates(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, double>{};
    for (final e in raw.entries) {
      final k = e.key;
      final v = e.value;
      if (k is String && v is num) {
        out[k.toUpperCase()] = v.toDouble();
      }
    }
    return out;
  }

  static SettingsModel fromMap(Map<dynamic, dynamic> map) {
    final base = (map['base_currency'] as String?) ?? 'LRD';
    final usdToLrd = ((map['exchange_rate'] as num?) ?? 192).toDouble();
    final rates = _parseRates(map['rates_to_base']);
    return SettingsModel(
      baseCurrencyCode: base,
      exchangeRateUsdToLrd: usdToLrd,
      lastBackupAtMs: map['last_backup_at'] as int?,
      ratesToBase: rates,
    );
  }

  AppSettingsEntity toEntity() {
    final base = Currency.fromCode(baseCurrencyCode);
    var rates = Map<String, double>.from(ratesToBase);
    // If legacy USD→LRD exists but map has no USD entry, seed it for LRD base.
    if (base == Currency.lrd && !rates.containsKey(Currency.usd.code)) {
      rates[Currency.usd.code] = exchangeRateUsdToLrd;
    }
    if (base == Currency.usd && !rates.containsKey(Currency.lrd.code)) {
      rates[Currency.lrd.code] = exchangeRateUsdToLrd > 0 ? 1 / exchangeRateUsdToLrd : 0;
    }
    return AppSettingsEntity(
      baseCurrency: base,
      exchangeRateUsdToLrd: exchangeRateUsdToLrd,
      lastBackupAt: lastBackupAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(lastBackupAtMs!),
      ratesToBase: rates,
    );
  }

  static SettingsModel fromEntity(AppSettingsEntity e) {
    return SettingsModel(
      baseCurrencyCode: e.baseCurrency.code,
      exchangeRateUsdToLrd: e.exchangeRateUsdToLrd,
      lastBackupAtMs: e.lastBackupAt?.millisecondsSinceEpoch,
      ratesToBase: Map<String, double>.from(e.ratesToBase),
    );
  }
}
