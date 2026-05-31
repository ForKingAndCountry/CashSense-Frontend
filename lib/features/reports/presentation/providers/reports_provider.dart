import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../core/services/report_file_service.dart';
import '../../../../core/services/report_generator.dart';
import '../../../../data/datasources/local/reports_local_data_source.dart';
import '../../../../domain/entities/app_settings_entity.dart';
import '../../../../domain/entities/report_entity.dart';
import '../../../debts/presentation/providers/debts_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

final reportsLocalDataSourceProvider = Provider<ReportsLocalDataSource>(
  (ref) => ReportsLocalDataSource(),
);

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<List<ReportEntity>>>((ref) {
  return ReportsNotifier(ref);
});

class ReportsNotifier extends StateNotifier<AsyncValue<List<ReportEntity>>> {
  ReportsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref ref;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final items = ref.read(reportsLocalDataSourceProvider).loadAll();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ReportEntity?> generate({
    required ReportType type,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final txs = ref.read(transactionsProvider).value ?? const [];
    final debts = ref.read(debtsProvider).value ?? const [];
    final wallets = ref.read(walletsProvider).value ?? const [];
    final settings = ref.read(settingsProvider).value ?? AppSettingsEntity.defaults;
    final currency = ref.read(currencyServiceProvider);

    final walletNames = {for (final w in wallets) w.id: w.name};

    final content = ReportGenerator.build(
      type: type,
      transactions: txs,
      debts: debts,
      currency: currency,
      settings: settings,
      periodStart: periodStart,
      periodEnd: periodEnd,
      walletNames: walletNames,
    );

    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'cashsense_report_$stamp.csv';
    await ReportFileService.write(fileName, content);

    final report = ReportEntity(
      id: const Uuid().v4(),
      title: ReportGenerator.titleFor(
        type: type,
        periodStart: periodStart,
        periodEnd: periodEnd,
      ),
      type: type,
      periodStart: periodStart,
      periodEnd: periodEnd,
      createdAt: DateTime.now(),
      fileName: fileName,
    );

    await ref.read(reportsLocalDataSourceProvider).save(report);
    await load();
    return report;
  }

  Future<void> deleteReport(ReportEntity report) async {
    await ReportFileService.delete(report.fileName);
    await ref.read(reportsLocalDataSourceProvider).delete(report.id);
    await load();
  }
}
