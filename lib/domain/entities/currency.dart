enum Currency {
  lrd,
  usd,
  brl,
  gnf,
  sll,
  xof,
  ngn;

  String get code => switch (this) {
        Currency.lrd => 'LRD',
        Currency.usd => 'USD',
        Currency.brl => 'BRL',
        Currency.gnf => 'GNF',
        Currency.sll => 'SLL',
        Currency.xof => 'XOF',
        Currency.ngn => 'NGN',
      };

  String get displayName => switch (this) {
        Currency.lrd => 'Liberian dollar',
        Currency.usd => 'US dollar',
        Currency.brl => 'Brazilian real',
        Currency.gnf => 'Guinean franc',
        Currency.sll => 'Sierra Leonean leone',
        Currency.xof => 'West African CFA franc',
        Currency.ngn => 'Nigerian naira',
      };

  static List<Currency> get all => Currency.values;

  static Currency fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return Currency.usd;
      case 'BRL':
        return Currency.brl;
      case 'GNF':
        return Currency.gnf;
      case 'SLL':
        return Currency.sll;
      case 'XOF':
        return Currency.xof;
      case 'NGN':
        return Currency.ngn;
      case 'LRD':
      default:
        return Currency.lrd;
    }
  }
}
