import '../../domain/entities/currency.dart';
import '../../domain/entities/debt_entity.dart';

class DebtModel {
  const DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.currencyCode,
    required this.type,
    required this.status,
    required this.dueDateMs,
    required this.synced,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String id;
  final String personName;
  final double amount;
  final String currencyCode;
  final String type; // owed | lent
  final String status; // pending | paid
  final int? dueDateMs;
  final bool synced;
  final int createdAtMs;
  final int updatedAtMs;

  Map<String, Object?> toMap() => {
        'id': id,
        'person_name': personName,
        'amount': amount,
        'currency': currencyCode,
        'type': type,
        'status': status,
        'due_date': dueDateMs,
        'synced': synced,
        'created_at': createdAtMs,
        'updated_at': updatedAtMs,
      };

  static DebtModel fromMap(Map<dynamic, dynamic> map) {
    return DebtModel(
      id: (map['id'] as String?) ?? '',
      personName: (map['person_name'] as String?) ?? '',
      amount: ((map['amount'] as num?) ?? 0).toDouble(),
      currencyCode: (map['currency'] as String?) ?? 'LRD',
      type: (map['type'] as String?) ?? 'owed',
      status: (map['status'] as String?) ?? 'pending',
      dueDateMs: map['due_date'] as int?,
      synced: (map['synced'] as bool?) ?? false,
      createdAtMs: (map['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      updatedAtMs: (map['updated_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  DebtEntity toEntity() {
    return DebtEntity(
      id: id,
      personName: personName,
      amount: amount,
      currency: Currency.fromCode(currencyCode),
      type: type == 'lent' ? DebtType.lent : DebtType.owed,
      status: status == 'paid' ? DebtStatus.paid : DebtStatus.pending,
      dueDate: dueDateMs == null ? null : DateTime.fromMillisecondsSinceEpoch(dueDateMs!),
      synced: synced,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }

  static DebtModel fromEntity(DebtEntity e) {
    return DebtModel(
      id: e.id,
      personName: e.personName,
      amount: e.amount,
      currencyCode: e.currency.code,
      type: e.type == DebtType.lent ? 'lent' : 'owed',
      status: e.status == DebtStatus.paid ? 'paid' : 'pending',
      dueDateMs: e.dueDate?.millisecondsSinceEpoch,
      synced: e.synced,
      createdAtMs: e.createdAt.millisecondsSinceEpoch,
      updatedAtMs: e.updatedAt.millisecondsSinceEpoch,
    );
  }

  DebtModel copyWith({
    bool? synced,
    int? updatedAtMs,
  }) {
    return DebtModel(
      id: id,
      personName: personName,
      amount: amount,
      currencyCode: currencyCode,
      type: type,
      status: status,
      dueDateMs: dueDateMs,
      synced: synced ?? this.synced,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }
}

