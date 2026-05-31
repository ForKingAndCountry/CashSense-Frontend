import '../../domain/entities/currency.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currencyCode,
    required this.category,
    required this.note,
    required this.dateMs,
    required this.synced,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.walletId,
  });

  final String id;
  final String type; // income | expense
  final double amount;
  final String currencyCode; // LRD | USD | …
  final String category;
  final String note;
  final int dateMs;
  final bool synced;
  final int createdAtMs;
  final int updatedAtMs;
  final String? walletId;

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type,
        'amount': amount,
        'currency': currencyCode,
        'category': category,
        'note': note,
        'date': dateMs,
        'synced': synced,
        'created_at': createdAtMs,
        'updated_at': updatedAtMs,
        if (walletId != null) 'wallet_id': walletId,
      };

  static TransactionModel fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: (map['id'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'expense',
      amount: ((map['amount'] as num?) ?? 0).toDouble(),
      currencyCode: (map['currency'] as String?) ?? 'LRD',
      category: (map['category'] as String?) ?? 'Other',
      note: (map['note'] as String?) ?? '',
      dateMs: (map['date'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      synced: (map['synced'] as bool?) ?? false,
      createdAtMs: (map['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      updatedAtMs: (map['updated_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      walletId: map['wallet_id'] as String?,
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      amount: amount,
      currency: Currency.fromCode(currencyCode),
      category: category,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      note: note,
      synced: synced,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
      walletId: walletId,
    );
  }

  static TransactionModel fromEntity(TransactionEntity e) {
    return TransactionModel(
      id: e.id,
      type: e.type == TransactionType.income ? 'income' : 'expense',
      amount: e.amount,
      currencyCode: e.currency.code,
      category: e.category,
      note: e.note,
      dateMs: e.date.millisecondsSinceEpoch,
      synced: e.synced,
      createdAtMs: e.createdAt.millisecondsSinceEpoch,
      updatedAtMs: e.updatedAt.millisecondsSinceEpoch,
      walletId: e.walletId,
    );
  }

  TransactionModel copyWith({
    bool? synced,
    int? updatedAtMs,
    String? walletId,
  }) {
    return TransactionModel(
      id: id,
      type: type,
      amount: amount,
      currencyCode: currencyCode,
      category: category,
      note: note,
      dateMs: dateMs,
      synced: synced ?? this.synced,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      walletId: walletId ?? this.walletId,
    );
  }
}
