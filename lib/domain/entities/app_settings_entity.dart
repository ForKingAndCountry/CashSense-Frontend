import 'currency.dart';

class AppSettingsEntity {
  const AppSettingsEntity({
    required this.baseCurrency,
    required this.exchangeRateUsdToLrd,
    required this.lastBackupAt,
    this.ratesToBase = const {},
  });

  final Currency baseCurrency;

  /// Legacy: 1 USD → X LRD (used when `ratesToBase` has no USD entry).
  final double exchangeRateUsdToLrd;

  /// For each non-base currency code (e.g. `"USD"`, `"NGN"`), how many **base**
  /// units equal **1** unit of that currency.
  final Map<String, double> ratesToBase;

  final DateTime? lastBackupAt;

  static const defaults = AppSettingsEntity(
    baseCurrency: Currency.lrd,
    exchangeRateUsdToLrd: 192,
    lastBackupAt: null,
    ratesToBase: {},
  );

  AppSettingsEntity copyWith({
    Currency? baseCurrency,
    double? exchangeRateUsdToLrd,
    DateTime? lastBackupAt,
    Map<String, double>? ratesToBase,
  }) {
    return AppSettingsEntity(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      exchangeRateUsdToLrd: exchangeRateUsdToLrd ?? this.exchangeRateUsdToLrd,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      ratesToBase: ratesToBase ?? this.ratesToBase,
    );
  }
}
