import 'currency.dart';

enum TransactionType { income, expense }

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    required this.note,
    required this.synced,
    required this.createdAt,
    required this.updatedAt,
    this.walletId,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final Currency currency;
  final String category;
  final DateTime date;
  final String note;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Which wallet this movement belongs to (offline-first).
  final String? walletId;

  TransactionEntity copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    Currency? currency,
    String? category,
    DateTime? date,
    String? note,
    bool? synced,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? walletId,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      walletId: walletId ?? this.walletId,
    );
  }
}
