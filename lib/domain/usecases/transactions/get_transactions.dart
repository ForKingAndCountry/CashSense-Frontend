import '../../entities/transaction_entity.dart';
import '../../repositories/transactions_repository.dart';

class GetTransactions {
  GetTransactions(this.repository);

  final TransactionsRepository repository;

  Future<List<TransactionEntity>> call() => repository.getAll();
}

