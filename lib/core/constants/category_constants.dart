/// Systemic expense and income categories (stored in DB / sync).
abstract final class ExpenseCategories {
  static const essentialFixed = 'Essential Fixed';
  static const essentialVariable = 'Essential Variable';
  static const nonEssentialFixed = 'Non-essential Fixed';
  static const nonEssentialVariable = 'Non-essential Variable';

  static const all = [
    essentialFixed,
    essentialVariable,
    nonEssentialFixed,
    nonEssentialVariable,
  ];

  static bool isEssential(String category) =>
      category == essentialFixed || category == essentialVariable;
}

abstract final class IncomeCategories {
  static const labor = 'Labor Income';
  static const systemic = 'Systemic Income';

  static const all = [labor, systemic];
}

/// Plain-language labels shown in the app (internal category strings stay unchanged).
abstract final class CategoryLabels {
  static String title(String category) {
    return switch (category) {
      IncomeCategories.labor => 'From my job',
      IncomeCategories.systemic => 'Other money in',
      ExpenseCategories.essentialFixed => 'Monthly bills',
      ExpenseCategories.essentialVariable => 'Everyday needs',
      ExpenseCategories.nonEssentialFixed => 'Subscriptions',
      ExpenseCategories.nonEssentialVariable => 'Fun & extras',
      _ => category,
    };
  }

  static String hint(String category) {
    return switch (category) {
      IncomeCategories.labor => 'Salary, pay, side work',
      IncomeCategories.systemic => 'Gift, refund, rental',
      ExpenseCategories.essentialFixed => 'Rent, school fees, same each time',
      ExpenseCategories.essentialVariable => 'Food, transport, utilities',
      ExpenseCategories.nonEssentialFixed => 'Phone data, memberships',
      ExpenseCategories.nonEssentialVariable => 'Eating out, treats',
      _ => '',
    };
  }
}
