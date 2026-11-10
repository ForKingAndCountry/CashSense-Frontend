import 'package:intl/intl.dart';

import '../../core/constants/app_branding.dart';
import '../../core/constants/category_constants.dart';
import '../../core/services/currency_service.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/entities/debt_entity.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/entities/transaction_entity.dart';

class ReportGenerator {
  static String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _row(List<String> cells) => cells.map(_csvCell).join(',');

  static List<TransactionEntity> filterByPeriod({
    required List<TransactionEntity> transactions,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final start = DateTime(periodStart.year, periodStart.month, periodStart.day);
    final end = DateTime(periodEnd.year, periodEnd.month, periodEnd.day, 23, 59, 59, 999);
    return transactions
        .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static String build({
    required ReportType type,
    required List<TransactionEntity> transactions,
    required List<DebtEntity> debts,
    required CurrencyService currency,
    required AppSettingsEntity settings,
    required DateTime periodStart,
    required DateTime periodEnd,
    Map<String, String> walletNames = const {},
  }) {
    final filtered = filterByPeriod(
      transactions: transactions,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    return switch (type) {
      ReportType.summary => _buildSummary(
          filtered: filtered,
          debts: debts,
          currency: currency,
          settings: settings,
          periodStart: periodStart,
          periodEnd: periodEnd,
        ),
      ReportType.transactions => _buildTransactions(
          filtered: filtered,
          currency: currency,
          settings: settings,
          periodStart: periodStart,
          periodEnd: periodEnd,
          walletNames: walletNames,
        ),
    };
  }

  static String _periodLabel(DateTime start, DateTime end) {
    final fmt = DateFormat('d MMM yyyy');
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  static String _buildSummary({
    required List<TransactionEntity> filtered,
    required List<DebtEntity> debts,
    required CurrencyService currency,
    required AppSettingsEntity settings,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final base = settings.baseCurrency.code;
    double income = 0;
    double expense = 0;
    final categoryTotals = <String, double>{};

    for (final t in filtered) {
      final amount = currency.convertToBase(amount: t.amount, from: t.currency);
      if (t.type == TransactionType.income) {
        income += amount;
      } else {
        expense += amount;
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + amount;
      }
    }

    final pendingDebts = debts.where((d) => d.status == DebtStatus.pending).toList();
    double owedToYou = 0;
    double youOwe = 0;
    for (final d in pendingDebts) {
      final amount = currency.convertToBase(amount: d.amount, from: d.currency);
      if (d.type == DebtType.lent) {
        owedToYou += amount;
      } else {
        youOwe += amount;
      }
    }

    final lines = <String>[
      _row(['${AppBranding.appName} — Monthly Summary Report']),
      _row(['Period', _periodLabel(periodStart, periodEnd)]),
      _row(['Generated', DateFormat('d MMM yyyy, HH:mm').format(DateTime.now())]),
      _row(['Base currency', base]),
      '',
      _row(['Metric', 'Amount ($base)']),
      _row(['Total income', income.toStringAsFixed(2)]),
      _row(['Total expenses', expense.toStringAsFixed(2)]),
      _row(['Net margin', (income - expense).toStringAsFixed(2)]),
      _row(['Transaction count', '${filtered.length}']),
      '',
      _row(['Category', 'Amount ($base)']),
    ];

    for (final entry in categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))) {
      lines.add(_row([CategoryLabels.title(entry.key), entry.value.toStringAsFixed(2)]));
    }

    if (pendingDebts.isNotEmpty) {
      lines.addAll([
        '',
        _row(['Outstanding obligations (all time)', 'Amount ($base)']),
        _row(['People owe you', owedToYou.toStringAsFixed(2)]),
        _row(['You owe others', youOwe.toStringAsFixed(2)]),
      ]);
    }

    return lines.join('\n');
  }

  static String _buildTransactions({
    required List<TransactionEntity> filtered,
    required CurrencyService currency,
    required AppSettingsEntity settings,
    required DateTime periodStart,
    required DateTime periodEnd,
    required Map<String, String> walletNames,
  }) {
    final base = settings.baseCurrency.code;
    final dateFmt = DateFormat('yyyy-MM-dd');
    final lines = <String>[
      _row(['${AppBranding.appName} — Transaction Detail Report']),
      _row(['Period', _periodLabel(periodStart, periodEnd)]),
      _row(['Generated', DateFormat('d MMM yyyy, HH:mm').format(DateTime.now())]),
      _row(['Base currency', base]),
      '',
      _row(['Date', 'Type', 'Category', 'Amount', 'Currency', 'Amount ($base)', 'Wallet', 'Note']),
    ];

    for (final t in filtered) {
      final inBase = currency.convertToBase(amount: t.amount, from: t.currency);
      final wallet = t.walletId != null ? (walletNames[t.walletId!] ?? t.walletId!) : '';
      lines.add(
        _row([
          dateFmt.format(t.date),
          t.type == TransactionType.income ? 'Income' : 'Expense',
          CategoryLabels.title(t.category),
          t.amount.toStringAsFixed(2),
          t.currency.code,
          inBase.toStringAsFixed(2),
          wallet,
          t.note,
        ]),
      );
    }

    if (filtered.isEmpty) {
      lines.add(_row(['No transactions in this period', '', '', '', '', '', '', '']));
    }

    return lines.join('\n');
  }

  static String titleFor({
    required ReportType type,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    final monthFmt = DateFormat('MMM yyyy');
    final sameMonth = periodStart.year == periodEnd.year && periodStart.month == periodEnd.month;
    final period = sameMonth ? monthFmt.format(periodStart) : _periodLabel(periodStart, periodEnd);
    return '${type.label} · $period';
  }
}
