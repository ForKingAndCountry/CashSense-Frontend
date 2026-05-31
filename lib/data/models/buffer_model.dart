import '../../domain/entities/buffer_entity.dart';
import '../../domain/entities/currency.dart';

class BufferModel {
  const BufferModel({
    required this.id,
    required this.name,
    required this.annualEstimate,
    required this.currentBalance,
    required this.currencyCode,
    required this.synced,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.purpose,
    this.deleted = false,
  });

  final String id;
  final String name;
  final String? purpose;
  final double annualEstimate;
  final double currentBalance;
  final String currencyCode;
  final bool synced;
  final int createdAtMs;
  final int updatedAtMs;
  final bool deleted;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        if (purpose != null) 'purpose': purpose,
        'annual_estimate': annualEstimate,
        'current_balance': currentBalance,
        'currency': currencyCode,
        'synced': synced,
        'created_at': createdAtMs,
        'updated_at': updatedAtMs,
        'deleted': deleted,
      };

  static BufferModel fromMap(Map<dynamic, dynamic> map) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return BufferModel(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? 'Buffer',
      purpose: map['purpose'] as String?,
      annualEstimate: ((map['annual_estimate'] as num?) ?? 0).toDouble(),
      currentBalance: ((map['current_balance'] as num?) ?? 0).toDouble(),
      currencyCode: (map['currency'] as String?) ?? 'LRD',
      synced: (map['synced'] as bool?) ?? false,
      createdAtMs: (map['created_at'] as int?) ?? now,
      updatedAtMs: (map['updated_at'] as int?) ?? now,
      deleted: (map['deleted'] as bool?) ?? false,
    );
  }

  BufferEntity toEntity() {
    return BufferEntity(
      id: id,
      name: name,
      purpose: purpose,
      annualEstimate: annualEstimate,
      currentBalance: currentBalance,
      currency: Currency.fromCode(currencyCode),
      synced: synced,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
      deleted: deleted,
    );
  }

  static BufferModel fromEntity(BufferEntity e) {
    return BufferModel(
      id: e.id,
      name: e.name,
      purpose: e.purpose,
      annualEstimate: e.annualEstimate,
      currentBalance: e.currentBalance,
      currencyCode: e.currency.code,
      synced: e.synced,
      createdAtMs: e.createdAt.millisecondsSinceEpoch,
      updatedAtMs: e.updatedAt.millisecondsSinceEpoch,
      deleted: e.deleted,
    );
  }

  BufferModel copyWith({
    bool? synced,
    int? updatedAtMs,
    double? currentBalance,
    bool? deleted,
  }) {
    return BufferModel(
      id: id,
      name: name,
      purpose: purpose,
      annualEstimate: annualEstimate,
      currentBalance: currentBalance ?? this.currentBalance,
      currencyCode: currencyCode,
      synced: synced ?? this.synced,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deleted: deleted ?? this.deleted,
    );
  }
}
