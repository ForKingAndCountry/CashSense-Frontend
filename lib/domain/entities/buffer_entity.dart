import 'currency.dart';

/// Handles "predictably unpredictable" expenses (car repairs, annual fees, etc.).
class BufferEntity {
  const BufferEntity({
    required this.id,
    required this.name,
    required this.annualEstimate,
    required this.currentBalance,
    required this.currency,
    required this.synced,
    required this.createdAt,
    required this.updatedAt,
    this.purpose,
    this.deleted = false,
  });

  final String id;
  final String name;
  final String? purpose;

  /// Expected annual cost for this irregular expense.
  final double annualEstimate;

  /// Amount currently set aside in this buffer.
  final double currentBalance;
  final Currency currency;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;

  /// Monthly amount to move into this buffer (annual ÷ 12).
  double get monthlyTarget => annualEstimate > 0 ? annualEstimate / 12 : 0;

  /// Progress toward fully funding the annual estimate (0–1).
  double get fundingProgress =>
      annualEstimate > 0 ? (currentBalance / annualEstimate).clamp(0.0, 1.0) : 0;

  BufferEntity copyWith({
    String? id,
    String? name,
    String? purpose,
    double? annualEstimate,
    double? currentBalance,
    Currency? currency,
    bool? synced,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
  }) {
    return BufferEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      annualEstimate: annualEstimate ?? this.annualEstimate,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }
}
