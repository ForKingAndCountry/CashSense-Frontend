import '../entities/transaction_entity.dart';

abstract class TransactionsRepository {
  Future<List<TransactionEntity>> getAll();
  Future<void> add(TransactionEntity transaction);
  Future<void> delete(String id);
}

