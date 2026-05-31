import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../buffers/presentation/providers/buffers_provider.dart';
import '../../../debts/presentation/providers/debts_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../../../subscription/domain/subscription_status.dart';
import '../../../subscription/presentation/widgets/upgrade_modal.dart';
import '../../../../core/constants/subscription_constants.dart';
import '../utils/dashboard_metrics.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final authUser = ref.watch(authSessionProvider);
    final currency = ref.watch(currencyServiceProvider);
    final txs = ref.watch(transactionsProvider).value ?? const [];
    final debts = ref.watch(debtsProvider).value ?? const [];
    final wallets = ref.watch(walletsProvider).value ?? const [];
    final buffers = ref.watch(buffersProvider).value ?? const [];

    final monthStart = DateTime(DateTime.now().year, DateTime.now().month);
    final thisMonth = txs.where((t) => t.date.isAfter(monthStart)).toList();
    final metrics = DashboardMetrics.compute(
      monthTxs: thisMonth,
      buffers: buffers,
      currency: currency,
    );

    final pendingDebt = debts
        .where((d) => d.status.name == 'pending')
        .fold<double>(0, (sum, d) => sum + currency.convertToBase(amount: d.amount, from: d.currency));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          if (sub?.isSoftLocked ?? false)
            Material(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => showUpgradeModal(context: context, ref: ref),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF9A9A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: Color(0xFFC62828)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Free trial ended',
                              style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB71C1C)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Subscribe from ${SubscriptionConstants.monthlyPriceLabel} or ${SubscriptionConstants.annualPriceLabel} — tap to pay or send receipt on WhatsApp.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFC62828)),
                    ],
                  ),
                ),
              ),
            ),
          if (sub?.isSoftLocked ?? false) const SizedBox(height: 10),
          if (sub?.status == SubscriptionStatus.grace)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE08A)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 18, color: Colors.black54),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your subscription is running on offline grace. Sync when online.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${authUser?.greetingName ?? 'Friend'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'What happens after money arrives?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black.withValues(alpha: 0.06),
                child: const Icon(Icons.person_outline, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: metrics.margin >= 0
                      ? const [Color(0xFF0E7C66), Color(0xFF0A5D4E)]
                      : const [Color(0xFFB71C1C), Color(0xFF8E0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MONTHLY MARGIN',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currency.format(amount: metrics.margin, currency: currency.baseCurrency),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Income ${currency.format(amount: metrics.income, currency: currency.baseCurrency)} '
                    '− obligations ${currency.format(amount: metrics.obligations, currency: currency.baseCurrency)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  if (pendingDebt > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Pending debts: ${currency.format(amount: pendingDebt, currency: currency.baseCurrency)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: metrics.systemIntegrityScore / 100,
                          strokeWidth: 5,
                          color: const Color(0xFF0E7C66),
                          backgroundColor: Colors.black.withValues(alpha: 0.06),
                        ),
                        Center(
                          child: Text(
                            '${metrics.systemIntegrityScore}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('System integrity', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 2),
                        Text(
                          'Did your system run as designed this month?',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'INCOME',
                  value: currency.format(amount: metrics.income, currency: currency.baseCurrency),
                  subtitle: metrics.systemicIncome > 0
                      ? 'Systemic: ${currency.format(amount: metrics.systemicIncome, currency: currency.baseCurrency)}'
                      : null,
                  color: const Color(0xFF0E7C66),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'SPENT',
                  value: currency.format(amount: metrics.expense, currency: currency.baseCurrency),
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
          if (metrics.categoryTotals.isNotEmpty) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('WHERE YOUR MONEY WENT', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (final e in metrics.categoryTotals.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(CategoryLabels.title(e.key), style: const TextStyle(fontSize: 13)),
                            ),
                            Text(
                              currency.format(amount: e.value, currency: currency.baseCurrency),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (buffers.isNotEmpty) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('PLAN-AHEAD SAVINGS', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            for (final b in buffers.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: b.fundingProgress, minHeight: 4),
                        const SizedBox(height: 4),
                        Text(
                          '${(b.fundingProgress * 100).round()}% toward yearly goal',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      '${(b.fundingProgress * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
          ],
          if (wallets.isNotEmpty) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('WALLETS (THIS MONTH)', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 8),
            for (final w in wallets)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.black.withValues(alpha: 0.06),
                          child: Text(w.currency.code, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(
                                '${w.currency.code} balance (this month)',
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currency.format(
                                amount: walletMonthBalance(thisMonth, w.id),
                                currency: w.currency,
                              ),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '≈ ${currency.format(amount: walletMonthBalanceBase(thisMonth, w.id, currency), currency: currency.baseCurrency)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Text('RECENT', style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('All')),
            ],
          ),
          const SizedBox(height: 8),
          ...txs.take(6).map((t) => TransactionTile(transaction: t)),
          if (txs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No transactions yet. Tap + to add income and run your allocation plan.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final String title;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
            const SizedBox(height: 8),
            Container(
              height: 4,
              width: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}
