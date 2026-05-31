import 'currency.dart';

enum DebtType { owed, lent }
enum DebtStatus { pending, paid }

class DebtEntity {
  const DebtEntity({
    required this.id,
    required this.personName,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.dueDate,
    required this.synced,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String personName;
  final double amount;
  final Currency currency;
  final DebtType type;
  final DebtStatus status;
  final DateTime? dueDate;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;
}

