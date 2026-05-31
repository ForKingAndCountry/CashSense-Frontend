import '../../domain/entities/wallet_entity.dart';

import '../../domain/repositories/wallets_repository.dart';

import '../../sync/sync_queue.dart';

import '../datasources/local/wallets_local_data_source.dart';

import '../models/wallet_model.dart';



class WalletsRepositoryImpl implements WalletsRepository {

  WalletsRepositoryImpl(this._local, this._syncQueue);



  final WalletsLocalDataSource _local;

  final SyncQueue _syncQueue;



  @override

  Future<List<WalletEntity>> getAll() async {

    final models = await _local.getAll();

    return models.map((m) => m.toEntity()).toList();

  }



  @override

  Future<void> upsert(WalletEntity wallet) async {

    final model = WalletModel.fromEntity(wallet);

    await _local.upsert(model);

    await _syncQueue.enqueue(SyncQueueItem.walletUpsert(walletId: model.id));

  }



  @override

  Future<void> delete(String id) async {

    final existing = await _local.getById(id);

    if (existing == null) return;

    final now = DateTime.now();

    await _local.upsert(existing.copyWith(

      deleted: true,

      synced: false,

      updatedAtMs: now.millisecondsSinceEpoch,

    ));

    await _syncQueue.enqueue(SyncQueueItem.walletDelete(walletId: id));

  }



  @override

  Future<void> clear() => _local.clear();

}

