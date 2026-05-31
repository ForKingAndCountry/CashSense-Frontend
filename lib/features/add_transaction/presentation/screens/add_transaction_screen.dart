import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../domain/entities/currency.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/wallet_entity.dart';
import '../../../allocation/presentation/providers/allocation_plan_provider.dart';
import '../../../dashboard/presentation/utils/dashboard_metrics.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../subscription/presentation/widgets/upgrade_modal.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  bool _upgradePrompted = false;

  TransactionType _type = TransactionType.income;
  Currency _currency = Currency.lrd;
  String? _walletId;
  String _category = ExpenseCategories.essentialFixed;

  final _amount = TextEditingController(text: '0');
  final _note = TextEditingController();

  static const _incomeCategories = <(String, IconData)>[
    (IncomeCategories.labor, Icons.work),
    (IncomeCategories.systemic, Icons.monetization_on),
  ];

  static const _expenseCategories = <(String, IconData)>[
    (ExpenseCategories.essentialFixed, Icons.lock),
    (ExpenseCategories.essentialVariable, Icons.shopping_cart),
    (ExpenseCategories.nonEssentialFixed, Icons.leak_remove),
    (ExpenseCategories.nonEssentialVariable, Icons.celebration),
  ];

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  List<WalletEntity> _walletsForCurrency(List<WalletEntity> all) {
    return all.where((w) => w.currency == _currency).toList();
  }

  String? _resolveWalletId(List<WalletEntity> forCurrency) {
    if (forCurrency.isEmpty) return null;
    if (_walletId != null && forCurrency.any((w) => w.id == _walletId)) return _walletId;
    return forCurrency.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final sub = ref.watch(subscriptionProvider);
    final shouldSoftLock = sub?.isSoftLocked ?? false;

    if (shouldSoftLock && !_upgradePrompted) {
      _upgradePrompted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final navigator = Navigator.of(context);
        await showUpgradeModal(context: context, ref: ref);
        if (!mounted) return;
        final latest = ref.read(subscriptionProvider);
        if (latest?.isSoftLocked ?? true) {
          navigator.pop();
        }
      });
    }

    if (shouldSoftLock) {
      return const SizedBox.shrink();
    }

    final walletsAsync = ref.watch(walletsProvider);
    final currencyFmt = ref.watch(currencyServiceProvider);
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final isIncome = _type == TransactionType.income;
    final headerColor = isIncome ? const Color(0xFF0E7C66) : const Color(0xFFD32F2F);
    final amountLabel = currencyFmt.format(amount: amount, currency: _currency);

    final wallets = walletsAsync.value ?? const <WalletEntity>[];
    final forCurrency = _walletsForCurrency(wallets);
    final selectedWalletId = _resolveWalletId(forCurrency);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              color: headerColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'Record transaction',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(value: TransactionType.income, label: Text('Money In')),
                      ButtonSegment(value: TransactionType.expense, label: Text('Money Out')),
                    ],
                    selected: {_type},
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      backgroundColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.12)),
                      side: WidgetStateProperty.all(
                        BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                      ),
                    ),
                    onSelectionChanged: (s) => setState(() {
                      _type = s.first;
                      _category = _type == TransactionType.income ? IncomeCategories.labor : ExpenseCategories.essentialFixed;
                    }),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    amountLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isIncome ? 'Money coming in' : 'Money going out',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amount,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Amount'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 120,
                        child: DropdownButtonFormField<Currency>(
                          initialValue: _currency,
                          decoration: const InputDecoration(labelText: 'Currency', isDense: true),
                          items: [
                            for (final c in Currency.all) DropdownMenuItem(value: c, child: Text(c.code)),
                          ],
                          onChanged: (c) {
                            if (c == null) return;
                            setState(() {
                              _currency = c;
                              _walletId = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (forCurrency.isEmpty)
                    const Text(
                      'No wallet for this currency yet. Create one in Settings → Wallets.',
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: selectedWalletId,
                      decoration: const InputDecoration(labelText: 'Wallet'),
                      items: [
                        for (final w in forCurrency) DropdownMenuItem(value: w.id, child: Text(w.name)),
                      ],
                      onChanged: (id) => setState(() => _walletId = id),
                    ),
                  const SizedBox(height: 14),
                  Text('What is this for?', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    isIncome
                        ? 'Pick the closest match — it helps you see where your money comes from.'
                        : 'Pick the closest match — it helps you see where your money goes.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: isIncome ? 2 : 2,
                    childAspectRatio: isIncome ? 1.35 : 1.45,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      for (final c in isIncome ? _incomeCategories : _expenseCategories)
                        _CategoryTile(
                          categoryKey: c.$1,
                          icon: c.$2,
                          selected: _category == c.$1,
                          onTap: () => setState(() => _category = c.$1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _note,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      hintText: isIncome ? 'e.g. March salary, payment from client' : 'e.g. Market run, taxi to work',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: amount <= 0 || selectedWalletId == null
                        ? null
                        : () async {
                            await ref.read(transactionsProvider.notifier).add(
                                  type: _type,
                                  amount: amount,
                                  currency: _currency,
                                  walletId: selectedWalletId,
                                  category: _category,
                                  note: _note.text.trim(),
                                  date: DateTime.now(),
                                );
                            if (!context.mounted) return;
                            if (_type == TransactionType.income) {
                              final plan = ref.read(allocationPlanProvider).value;
                              if (plan != null) {
                                await showAllocationSheet(
                                  context: context,
                                  plan: plan,
                                  incomeAmount: amount,
                                  currency: currencyFmt,
                                  incomeCurrency: _currency,
                                );
                              }
                            }
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.categoryKey,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String categoryKey;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? Theme.of(context).colorScheme.primary : Colors.black.withValues(alpha: 0.06);
    final accent = selected ? Theme.of(context).colorScheme.primary : Colors.black54;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: selected ? 1.5 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: accent),
            const SizedBox(height: 8),
            Text(
              CategoryLabels.title(categoryKey),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (CategoryLabels.hint(categoryKey).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                CategoryLabels.hint(categoryKey),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.black45,
                      fontSize: 10,
                      height: 1.2,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
