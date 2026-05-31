import '../../entities/transaction_entity.dart';
import '../../repositories/transactions_repository.dart';

class AddTransaction {
  AddTransaction(this.repository);

  final TransactionsRepository repository;

  Future<void> call(TransactionEntity transaction) => repository.add(transaction);
}

