import '../entities/wallet_entity.dart';

abstract class WalletsRepository {
  Future<List<WalletEntity>> getAll();
  Future<void> upsert(WalletEntity wallet);
  Future<void> delete(String id);
  Future<void> clear();
}
