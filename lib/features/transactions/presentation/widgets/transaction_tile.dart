import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/wallet_entity.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyServiceProvider);
    final wallets = ref.watch(walletsProvider).value;
    final walletName = _walletName(wallets, transaction.walletId);
    final isIncome = transaction.type == TransactionType.income;
    final sign = isIncome ? '+' : '-';
    final amount = currency.format(amount: transaction.amount, currency: transaction.currency);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.06),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(CategoryLabels.title(transaction.category), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
            if (walletName != null) walletName,
            if (transaction.note.isNotEmpty) transaction.note,
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '$sign$amount',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isIncome ? const Color(0xFF0E7C66) : const Color(0xFFD32F2F),
              ),
        ),
      ),
    );
  }
}

String? _walletName(List<WalletEntity>? wallets, String? walletId) {
  if (walletId == null || wallets == null) return null;
  for (final w in wallets) {
    if (w.id == walletId) return w.name;
  }
  return null;
}

