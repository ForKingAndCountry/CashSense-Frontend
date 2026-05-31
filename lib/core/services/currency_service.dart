import 'package:intl/intl.dart';

import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/currency.dart';

class CurrencyService {
  CurrencyService(this._settings);

  final AppSettingsEntity _settings;

  Currency get baseCurrency => _settings.baseCurrency;
  double get usdToLrd => _settings.exchangeRateUsdToLrd;

  /// How many **base** units equal **1** unit of [from].
  double unitsOfBasePerUnitOf(Currency from) {
    if (from == baseCurrency) return 1;
    final key = from.code;
    final map = _settings.ratesToBase;
    if (map.containsKey(key)) return map[key]!;

    // Legacy fallbacks (older settings without `rates_to_base`).
    if (baseCurrency == Currency.lrd && from == Currency.usd) return usdToLrd;
    if (baseCurrency == Currency.usd && from == Currency.lrd) {
      return usdToLrd > 0 ? 1 / usdToLrd : 1;
    }
    // Unknown pair: avoid crashing; treat as 1:1 until user sets a rate.
    return 1;
  }

  double convertToBase({required double amount, required Currency from}) {
    return amount * unitsOfBasePerUnitOf(from);
  }

  String format({required double amount, required Currency currency}) {
    final symbol = switch (currency) {
      Currency.lrd => 'L\$',
      Currency.usd => '\$',
      Currency.brl => 'R\$',
      Currency.ngn => '₦',
      Currency.xof => 'CFA',
      _ => '',
    };
    final fmt = NumberFormat.currency(
      name: currency.code,
      symbol: symbol.isEmpty ? '${currency.code} ' : symbol,
      decimalDigits: 0,
    );
    return fmt.format(amount);
  }
}
