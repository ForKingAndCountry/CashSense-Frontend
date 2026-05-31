import '../entities/debt_entity.dart';

abstract class DebtsRepository {
  Future<List<DebtEntity>> getAll();
  Future<void> add(DebtEntity debt);
  Future<void> update(DebtEntity debt);
}

