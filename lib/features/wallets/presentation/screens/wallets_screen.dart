import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/currency.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../providers/wallets_provider.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final txs = ref.watch(transactionsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: walletsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (wallets) {
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: wallets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final w = wallets[i];
              final used = txs.where((t) => t.walletId == w.id).length;
              return Card(
                child: ListTile(
                  title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${w.currency.code} · $used transactions'),
                  trailing: used == 0
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await ref.read(walletsProvider.notifier).deleteWallet(w.id);
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = TextEditingController();
          Currency c = Currency.lrd;
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              final bottom = MediaQuery.of(ctx).viewInsets.bottom;
              return StatefulBuilder(
                builder: (ctx, setModal) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'New wallet',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: name,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Currency>(
                          initialValue: c,
                          decoration: const InputDecoration(labelText: 'Currency'),
                          items: [
                            for (final cur in Currency.all)
                              DropdownMenuItem(value: cur, child: Text('${cur.code} — ${cur.displayName}')),
                          ],
                          onChanged: (v) {
                            if (v != null) setModal(() => c = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () async {
                            await ref.read(walletsProvider.notifier).addWallet(name: name.text, currency: c);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Wallet'),
      ),
    );
  }
}
