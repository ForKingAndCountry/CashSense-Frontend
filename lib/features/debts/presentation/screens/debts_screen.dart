import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../domain/entities/debt_entity.dart';
import '../../../../domain/entities/currency.dart';
import '../providers/debts_provider.dart';
import '../../../subscription/presentation/widgets/upgrade_modal.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(debtsProvider).value ?? const <DebtEntity>[];
    final iOwe = all.where((d) => d.type == DebtType.owed).toList();
    final owedToMe = all.where((d) => d.type == DebtType.lent).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text('Debts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(onPressed: _openAddDebt, icon: const Icon(Icons.add)),
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
                  Tab(text: 'I Owe'),
                  Tab(text: 'Owed To Me'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _DebtList(items: iOwe),
                _DebtList(items: owedToMe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddDebt() async {
    final sub = ref.read(subscriptionProvider);
    if (sub?.isSoftLocked ?? false) {
      await showUpgradeModal(context: context, ref: ref);
      return;
    }

    final res = await showModalBottomSheet<_DebtDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddDebtSheet(),
    );
    if (res == null) return;

    await ref.read(debtsProvider.notifier).add(
          type: res.type,
          personName: res.personName,
          amount: res.amount,
          currency: res.currency,
        );
  }
}

class _DebtList extends ConsumerWidget {
  const _DebtList({required this.items});

  final List<DebtEntity> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No debts yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      );
    }

    final currency = ref.watch(currencyServiceProvider);
    final sub = ref.watch(subscriptionProvider);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemBuilder: (context, i) {
        final d = items[i];
        final amount = currency.format(amount: d.amount, currency: d.currency);
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.06),
              child: Text(d.personName.isEmpty ? '?' : d.personName.characters.first.toUpperCase()),
            ),
            title: Text(d.personName.isEmpty ? 'Unknown' : d.personName),
            subtitle: Text(d.status == DebtStatus.paid ? 'Paid' : 'Pending'),
            trailing: Text(
              amount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            onTap: () async {
              if (sub?.isSoftLocked ?? false) {
                await showUpgradeModal(context: context, ref: ref);
                return;
              }
              await ref.read(debtsProvider.notifier).markPaid(d, d.status != DebtStatus.paid);
            },
          ),
        );
      },
      separatorBuilder: (context, i) => const SizedBox(height: 10),
      itemCount: items.length,
    );
  }
}

class _AddDebtSheet extends StatefulWidget {
  const _AddDebtSheet();

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  DebtType _type = DebtType.owed;
  Currency _currency = Currency.lrd;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Debt', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          SegmentedButton<DebtType>(
            segments: const [
              ButtonSegment(value: DebtType.owed, label: Text('I Owe')),
              ButtonSegment(value: DebtType.lent, label: Text('Owed To Me')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Person name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<Currency>(
            initialValue: _currency,
            decoration: const InputDecoration(labelText: 'Currency'),
            items: [
              for (final c in Currency.all) DropdownMenuItem(value: c, child: Text(c.code)),
            ],
            onChanged: (c) {
              if (c != null) setState(() => _currency = c);
            },
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(_amount.text.trim()) ?? 0;
              Navigator.of(context).pop(
                _DebtDraft(
                  type: _type,
                  personName: _name.text.trim(),
                  amount: amount,
                  currency: _currency,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _DebtDraft {
  const _DebtDraft({
    required this.type,
    required this.personName,
    required this.amount,
    required this.currency,
  });

  final DebtType type;
  final String personName;
  final double amount;
  final Currency currency;
}

