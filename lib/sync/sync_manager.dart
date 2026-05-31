import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import '../core/constants/app_constants.dart';
import '../core/config/api_config.dart';
import '../data/datasources/local/allocation_plans_local_data_source.dart';
import '../data/datasources/local/buffers_local_data_source.dart';
import '../data/datasources/local/debts_local_data_source.dart';
import '../data/datasources/local/transactions_local_data_source.dart';
import '../data/datasources/local/wallets_local_data_source.dart';
import '../data/models/allocation_plan_model.dart';
import '../data/models/buffer_model.dart';
import '../data/models/debt_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/wallet_model.dart';
import 'sync_queue.dart';

/// Offline-first sync manager communicating with Next.js/MongoDB REST API.
class SyncManager {
  SyncManager({
    required this.queue,
    required this.transactionsLocal,
    required this.debtsLocal,
    required this.walletsLocal,
    required this.buffersLocal,
    required this.allocationPlansLocal,
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 10),
            )),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final SyncQueue queue;
  final TransactionsLocalDataSource transactionsLocal;
  final DebtsLocalDataSource debtsLocal;
  final WalletsLocalDataSource walletsLocal;
  final BuffersLocalDataSource buffersLocal;
  final AllocationPlansLocalDataSource allocationPlansLocal;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const _lastSyncKey = 'last_sync_time';

  Future<void> sync() async {
    try {
      final token = await _secureStorage.read(key: 'auth_jwt_token');
      if (token == null || token.isEmpty) return;

      final settingsBox = Hive.box<Map>(AppBoxes.settings);
      final lastSyncAt = settingsBox.get(_lastSyncKey) as String?;

      final pendingQueueItems = await queue.pending();
      final txPayload = <Map<String, dynamic>>[];
      final debtPayload = <Map<String, dynamic>>[];
      final walletPayload = <Map<String, dynamic>>[];
      final bufferPayload = <Map<String, dynamic>>[];
      final allocationPayload = <Map<String, dynamic>>[];

      for (final item in pendingQueueItems) {
        final id = item.payload['id'] as String?;
        if (id == null) continue;
        final nowMs = DateTime.now().millisecondsSinceEpoch;

        if (item.type == 'transaction_upsert') {
          final localTx = await transactionsLocal.getById(id);
          if (localTx != null) txPayload.add({...localTx.toMap(), 'deleted': false});
        } else if (item.type == 'transaction_delete') {
          txPayload.add({'id': id, 'deleted': true, 'updated_at': nowMs});
        } else if (item.type == 'debt_upsert') {
          final localDebt = await debtsLocal.getById(id);
          if (localDebt != null) debtPayload.add({...localDebt.toMap(), 'deleted': false});
        } else if (item.type == 'wallet_upsert') {
          final localWallet = await walletsLocal.getById(id);
          if (localWallet != null) {
            walletPayload.add({...localWallet.toMap(), 'deleted': localWallet.deleted});
          }
        } else if (item.type == 'wallet_delete') {
          walletPayload.add({'id': id, 'deleted': true, 'updated_at': nowMs});
        } else if (item.type == 'buffer_upsert') {
          final localBuffer = await buffersLocal.getById(id);
          if (localBuffer != null) bufferPayload.add({...localBuffer.toMap(), 'deleted': false});
        } else if (item.type == 'buffer_delete') {
          bufferPayload.add({'id': id, 'deleted': true, 'updated_at': nowMs});
        } else if (item.type == 'allocation_plan_upsert') {
          final plan = await allocationPlansLocal.getDefault();
          if (plan != null && plan.id == id) {
            allocationPayload.add({...plan.toMap(), 'deleted': false});
          }
        }
      }

      const deviceId = 'flutter_device_01';

      final response = await _dio.post(
        '/api/sync',
        data: {
          'deviceId': deviceId,
          'lastSyncAt': lastSyncAt,
          'transactions': txPayload,
          'debts': debtPayload,
          'wallets': walletPayload,
          'buffers': bufferPayload,
          'allocationPlans': allocationPayload,
          'appVersion': '1.0.0',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        for (final txMap in (data['transactions'] as List?) ?? const []) {
          if (txMap is Map) {
            await transactionsLocal.upsert(TransactionModel.fromMap(txMap).copyWith(synced: true));
          }
        }

        for (final debtMap in (data['debts'] as List?) ?? const []) {
          if (debtMap is Map) {
            await debtsLocal.upsert(DebtModel.fromMap(debtMap).copyWith(synced: true));
          }
        }

        for (final walletMap in (data['wallets'] as List?) ?? const []) {
          if (walletMap is Map) {
            await walletsLocal.upsert(WalletModel.fromMap(walletMap).copyWith(synced: true));
          }
        }

        for (final bufferMap in (data['buffers'] as List?) ?? const []) {
          if (bufferMap is Map) {
            await buffersLocal.upsert(BufferModel.fromMap(bufferMap).copyWith(synced: true));
          }
        }

        for (final planMap in (data['allocationPlans'] as List?) ?? const []) {
          if (planMap is Map) {
            await allocationPlansLocal.upsert(AllocationPlanModel.fromMap(planMap).copyWith(synced: true));
          }
        }

        final subMap = data['subscription'] as Map?;
        if (subMap != null) {
          final status = subMap['status'] as String?;
          final endsAt = subMap['endsAt'] as String?;
          if (status != null) {
            final subBox = Hive.box<Map>(AppBoxes.subscription);
            await subBox.put('cached_subscription', {
              'status': status,
              'endsAt': endsAt,
              'lastVerified': DateTime.now().toIso8601String(),
            });
          }
        }

        await queue.clear();
        await settingsBox.put(_lastSyncKey, data['serverTime']);
      }
    } catch (e) {
      // ignore: avoid_print
      print('REST Sync encountered error: $e');
    }
  }
}
