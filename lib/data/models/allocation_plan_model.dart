import '../../domain/entities/allocation_plan_entity.dart';

class AllocationPlanModel {
  const AllocationPlanModel({
    required this.id,
    required this.name,
    required this.percentSavings,
    required this.percentDebt,
    required this.percentInvestment,
    required this.percentGuiltFree,
    required this.isDefault,
    required this.synced,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String id;
  final String name;
  final double percentSavings;
  final double percentDebt;
  final double percentInvestment;
  final double percentGuiltFree;
  final bool isDefault;
  final bool synced;
  final int createdAtMs;
  final int updatedAtMs;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'percent_savings': percentSavings,
        'percent_debt': percentDebt,
        'percent_investment': percentInvestment,
        'percent_guilt_free': percentGuiltFree,
        'is_default': isDefault,
        'synced': synced,
        'created_at': createdAtMs,
        'updated_at': updatedAtMs,
      };

  static AllocationPlanModel fromMap(Map<dynamic, dynamic> map) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return AllocationPlanModel(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? 'Default Plan',
      percentSavings: ((map['percent_savings'] as num?) ?? 10).toDouble(),
      percentDebt: ((map['percent_debt'] as num?) ?? 20).toDouble(),
      percentInvestment: ((map['percent_investment'] as num?) ?? 10).toDouble(),
      percentGuiltFree: ((map['percent_guilt_free'] as num?) ?? 60).toDouble(),
      isDefault: (map['is_default'] as bool?) ?? true,
      synced: (map['synced'] as bool?) ?? false,
      createdAtMs: (map['created_at'] as int?) ?? now,
      updatedAtMs: (map['updated_at'] as int?) ?? now,
    );
  }

  AllocationPlanEntity toEntity() {
    return AllocationPlanEntity(
      id: id,
      name: name,
      percentSavings: percentSavings,
      percentDebt: percentDebt,
      percentInvestment: percentInvestment,
      percentGuiltFree: percentGuiltFree,
      isDefault: isDefault,
      synced: synced,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }

  static AllocationPlanModel fromEntity(AllocationPlanEntity e) {
    return AllocationPlanModel(
      id: e.id,
      name: e.name,
      percentSavings: e.percentSavings,
      percentDebt: e.percentDebt,
      percentInvestment: e.percentInvestment,
      percentGuiltFree: e.percentGuiltFree,
      isDefault: e.isDefault,
      synced: e.synced,
      createdAtMs: e.createdAt.millisecondsSinceEpoch,
      updatedAtMs: e.updatedAt.millisecondsSinceEpoch,
    );
  }

  AllocationPlanModel copyWith({bool? synced, int? updatedAtMs}) {
    return AllocationPlanModel(
      id: id,
      name: name,
      percentSavings: percentSavings,
      percentDebt: percentDebt,
      percentInvestment: percentInvestment,
      percentGuiltFree: percentGuiltFree,
      isDefault: isDefault,
      synced: synced ?? this.synced,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }
}
