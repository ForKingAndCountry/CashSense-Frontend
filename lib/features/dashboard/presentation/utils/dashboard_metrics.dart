import 'package:flutter/material.dart';

import '../../../../core/constants/category_constants.dart';
import '../../../../domain/entities/allocation_plan_entity.dart';
import '../../../../domain/entities/buffer_entity.dart';
import '../../../../domain/entities/currency.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../core/services/currency_service.dart';

class DashboardMetrics {
  const DashboardMetrics({
    required this.income,
    required this.expense,
    required this.margin,
    required this.obligations,
    required this.bufferMonthlyTotal,
    required this.categoryTotals,
    required this.systemIntegrityScore,
    required this.laborIncome,
    required this.systemicIncome,
  });

  final double income;
  final double expense;
  final double margin;
  final double obligations;
  final double bufferMonthlyTotal;
  final Map<String, double> categoryTotals;
  final int systemIntegrityScore;
  final double laborIncome;
  final double systemicIncome;

  static DashboardMetrics compute({
    required List<TransactionEntity> monthTxs,
    required List<BufferEntity> buffers,
    required CurrencyService currency,
  }) {
    double income = 0;
    double expense = 0;
    double laborIncome = 0;
    double systemicIncome = 0;
    double essentialFixed = 0;
    double essentialVariable = 0;
    final categoryTotals = <String, double>{};

    for (final t in monthTxs) {
      final base = currency.convertToBase(amount: t.amount, from: t.currency);
      if (t.type == TransactionType.income) {
        income += base;
        if (t.category == IncomeCategories.labor) laborIncome += base;
        if (t.category == IncomeCategories.systemic) systemicIncome += base;
      } else {
        expense += base;
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + base;
        if (t.category == ExpenseCategories.essentialFixed) essentialFixed += base;
        if (t.category == ExpenseCategories.essentialVariable) essentialVariable += base;
      }
    }

    double bufferMonthlyTotal = 0;
    double bufferFundingScore = 0;
    if (buffers.isNotEmpty) {
      for (final b in buffers) {
        bufferMonthlyTotal += currency.convertToBase(amount: b.monthlyTarget, from: b.currency);
      }
      final avgProgress = buffers.map((b) => b.fundingProgress).reduce((a, c) => a + c) / buffers.length;
      bufferFundingScore = avgProgress;
    } else {
      bufferFundingScore = 1;
    }

    final obligations = essentialFixed + essentialVariable + bufferMonthlyTotal;
    final margin = income - obligations;

    var integrity = 50;
    if (income > 0) integrity += 25;
    integrity += (bufferFundingScore * 25).round();
    if (margin >= 0) integrity += 25;
    if (integrity > 100) integrity = 100;

    return DashboardMetrics(
      income: income,
      expense: expense,
      margin: margin,
      obligations: obligations,
      bufferMonthlyTotal: bufferMonthlyTotal,
      categoryTotals: categoryTotals,
      systemIntegrityScore: integrity,
      laborIncome: laborIncome,
      systemicIncome: systemicIncome,
    );
  }
}

/// Shows allocation splits when income is recorded.
Future<void> showAllocationSheet({
  required BuildContext context,
  required AllocationPlanEntity plan,
  required double incomeAmount,
  required CurrencyService currency,
  required Currency incomeCurrency,
}) async {
  final baseIncome = currency.convertToBase(amount: incomeAmount, from: incomeCurrency);
  final splits = plan.splitsFor(baseIncome);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Execute your plan',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Income detected — move money in this order before spending.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            for (final e in splits.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Text(
                      currency.format(amount: e.value, currency: currency.baseCurrency),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan noted. You manage money with intention.'),
                  ),
                );
              },
              child: const Text('Got it — I\'ll move the money'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      );
    },
  );
}

double walletMonthBalance(List<TransactionEntity> txs, String walletId) {
  return txs.where((t) => t.walletId == walletId).fold<double>(0, (sum, t) {
    final sign = t.type == TransactionType.income ? 1.0 : -1.0;
    return sum + sign * t.amount;
  });
}

double walletMonthBalanceBase(
  List<TransactionEntity> txs,
  String walletId,
  CurrencyService currency,
) {
  return txs.where((t) => t.walletId == walletId).fold<double>(0, (sum, t) {
    final base = currency.convertToBase(amount: t.amount, from: t.currency);
    final sign = t.type == TransactionType.income ? 1.0 : -1.0;
    return sum + sign * base;
  });
}
