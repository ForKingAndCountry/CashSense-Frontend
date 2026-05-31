import 'package:hive/hive.dart';

import '../core/constants/app_constants.dart';

class SyncQueueItem {
  const SyncQueueItem._(this.type, this.payload);

  final String type;
  final Map<String, Object?> payload;

  Map<String, Object?> toMap() => {'type': type, 'payload': payload};

  static SyncQueueItem fromMap(Map<dynamic, dynamic> map) {
    return SyncQueueItem._(
      (map['type'] as String?) ?? 'unknown',
      (map['payload'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }

  factory SyncQueueItem.transactionUpsert({required String transactionId}) {
    return SyncQueueItem._('transaction_upsert', {'id': transactionId});
  }

  factory SyncQueueItem.transactionDelete({required String transactionId}) {
    return SyncQueueItem._('transaction_delete', {'id': transactionId});
  }

  factory SyncQueueItem.debtUpsert({required String debtId}) {
    return SyncQueueItem._('debt_upsert', {'id': debtId});
  }

  factory SyncQueueItem.walletUpsert({required String walletId}) {
    return SyncQueueItem._('wallet_upsert', {'id': walletId});
  }

  factory SyncQueueItem.walletDelete({required String walletId}) {
    return SyncQueueItem._('wallet_delete', {'id': walletId});
  }

  factory SyncQueueItem.bufferUpsert({required String bufferId}) {
    return SyncQueueItem._('buffer_upsert', {'id': bufferId});
  }

  factory SyncQueueItem.bufferDelete({required String bufferId}) {
    return SyncQueueItem._('buffer_delete', {'id': bufferId});
  }

  factory SyncQueueItem.allocationPlanUpsert({required String planId}) {
    return SyncQueueItem._('allocation_plan_upsert', {'id': planId});
  }
}

abstract class SyncQueue {
  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> pending();
  Future<void> clear();

  /// Replace the entire pending list (used after partial push success).
  Future<void> setPending(List<SyncQueueItem> items);
}

class HiveSyncQueue implements SyncQueue {
  HiveSyncQueue(this._box);

  final Box<Map> _box;

  factory HiveSyncQueue.open() => HiveSyncQueue(Hive.box<Map>(AppBoxes.syncQueue));

  static const _key = 'queue';

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    final current = await pending();
    final next = [...current, item];
    await _box.put(_key, {'items': next.map((i) => i.toMap()).toList()});
  }

  @override
  Future<List<SyncQueueItem>> pending() async {
    final map = _box.get(_key);
    final items = (map?['items'] as List?) ?? const [];
    return items
        .whereType<Map>()
        .map((m) => SyncQueueItem.fromMap(m))
        .toList(growable: false);
  }

  @override
  Future<void> clear() async {
    await _box.delete(_key);
  }

  @override
  Future<void> setPending(List<SyncQueueItem> items) async {
    if (items.isEmpty) {
      await clear();
      return;
    }
    await _box.put(_key, {'items': items.map((i) => i.toMap()).toList()});
  }
}

