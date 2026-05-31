import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(transactionsProvider).value ?? const <TransactionEntity>[];

    final all = txs;
    final income = txs.where((t) => t.type == TransactionType.income).toList();
    final expense = txs.where((t) => t.type == TransactionType.expense).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text('History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black54,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Money In'),
                  Tab(text: 'Money Out'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _List(txs: all),
                _List(txs: income),
                _List(txs: expense),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.txs});

  final List<TransactionEntity> txs;

  @override
  Widget build(BuildContext context) {
    if (txs.isEmpty) {
      return Center(
        child: Text(
          'No transactions yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemBuilder: (context, i) => TransactionTile(transaction: txs[i]),
      separatorBuilder: (context, i) => const SizedBox(height: 10),
      itemCount: txs.length,
    );
  }
}

