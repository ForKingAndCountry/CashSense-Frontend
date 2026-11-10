/// Pre-decided "pay yourself first" allocation percentages (must sum to 100).
class AllocationPlanEntity {
  const AllocationPlanEntity({
    required this.id,
    required this.name,
    required this.percentSavings,
    required this.percentDebt,
    required this.percentInvestment,
    required this.percentGuiltFree,
    required this.synced,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = true,
  });

  final String id;
  final String name;
  final double percentSavings;
  final double percentDebt;
  final double percentInvestment;
  final double percentGuiltFree;
  final bool isDefault;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get totalPercent =>
      percentSavings + percentDebt + percentInvestment + percentGuiltFree;

  bool get isValid => (totalPercent - 100).abs() < 0.01;

  Map<String, double> splitsFor(double income) => {
        'Untouchable Savings': income * percentSavings / 100,
        'Obligation Repayment': income * percentDebt / 100,
        'Future Investment': income * percentInvestment / 100,
        'Guilt-Free Spending': income * percentGuiltFree / 100,
      };

  static AllocationPlanEntity defaults({required String id, required DateTime now}) {
    return AllocationPlanEntity(
      id: id,
      name: 'Default Plan',
      percentSavings: 10,
      percentDebt: 20,
      percentInvestment: 10,
      percentGuiltFree: 60,
      isDefault: true,
      synced: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  AllocationPlanEntity copyWith({
    String? id,
    String? name,
    double? percentSavings,
    double? percentDebt,
    double? percentInvestment,
    double? percentGuiltFree,
    bool? isDefault,
    bool? synced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AllocationPlanEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      percentSavings: percentSavings ?? this.percentSavings,
      percentDebt: percentDebt ?? this.percentDebt,
      percentInvestment: percentInvestment ?? this.percentInvestment,
      percentGuiltFree: percentGuiltFree ?? this.percentGuiltFree,
      isDefault: isDefault ?? this.isDefault,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
