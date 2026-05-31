import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../domain/entities/currency.dart';
import '../providers/buffers_provider.dart';

class BuffersScreen extends ConsumerWidget {
  const BuffersScreen({super.key});

  static const _intro = '''
Some costs don’t hit every month — but you know they’re coming. Think car repairs, school fees at the end of the year, or a phone you’ll need to replace.

A plan-ahead jar helps you save a little each month so these bills don’t feel like emergencies.''';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buffersAsync = ref.watch(buffersProvider);
    final currency = ref.watch(currencyServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan-ahead savings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: buffersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (buffers) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            children: [
              _IntroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF0E7C66).withValues(alpha: 0.12),
                          child: const Icon(Icons.savings_outlined, color: Color(0xFF0E7C66)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Save before the bill arrives',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _intro.trim(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _ExampleChip(label: 'Car repair'),
                        _ExampleChip(label: 'School fees'),
                        _ExampleChip(label: 'Medical visit'),
                        _ExampleChip(label: 'New phone'),
                      ],
                    ),
                  ],
                ),
              ),
              if (buffers.isEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'No jars yet',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap the button below to create your first one. '
                  'Enter how much you think you’ll need in a year — we’ll suggest a small amount to set aside each month.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const SizedBox(height: 16),
                Text('YOUR JARS', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                for (final b in buffers) ...[
                  _BufferJarCard(
                    name: b.name,
                    purpose: b.purpose,
                    progress: b.fundingProgress,
                    saved: currency.format(amount: b.currentBalance, currency: b.currency),
                    yearlyGoal: currency.format(amount: b.annualEstimate, currency: b.currency),
                    monthlySuggestion: currency.format(amount: b.monthlyTarget, currency: b.currency),
                    onAddMoney: () => _showFundDialog(context, ref, b.id, b.currency, b.name),
                    onDelete: () => ref.read(buffersProvider.notifier).deleteBuffer(b.id),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBufferSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New savings jar'),
      ),
    );
  }

  Future<void> _showFundDialog(
    BuildContext context,
    WidgetRef ref,
    String bufferId,
    Currency currency,
    String jarName,
  ) async {
    final amountCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to “$jarName”'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How much are you putting aside right now? Every bit counts.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (${currency.code})',
                hintText: 'e.g. 500',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
              if (amount <= 0) return;
              await ref.read(buffersProvider.notifier).fundBuffer(bufferId, amount);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to “$jarName”. Nice work staying ahead.')),
                );
              }
            },
            child: const Text('Add money'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBufferSheet(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final annual = TextEditingController();
    final purpose = TextEditingController();
    Currency c = Currency.lrd;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final yearly = double.tryParse(annual.text.trim()) ?? 0;
            final monthly = yearly > 0 ? yearly / 12 : 0.0;
            final currencyFmt = ref.read(currencyServiceProvider);

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'New savings jar',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Give it a name, guess what you might spend in a year, and start saving bit by bit.',
                    style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'What are you saving for?',
                      hintText: 'e.g. Car repair, School fees',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: purpose,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Extra detail (optional)',
                      hintText: 'e.g. Tires and service for my car',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: annual,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'About how much per year?',
                      hintText: 'Rough guess is fine',
                      helperText: yearly > 0
                          ? 'Suggested: set aside ~${currencyFmt.format(amount: monthly, currency: c)} each month'
                          : 'We divide this by 12 to suggest a monthly amount',
                    ),
                    onChanged: (_) => setModal(() {}),
                  ),
                  const SizedBox(height: 10),
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
                      final estimate = double.tryParse(annual.text.trim()) ?? 0;
                      if (estimate <= 0 || name.text.trim().isEmpty) return;
                      await ref.read(buffersProvider.notifier).addBuffer(
                            name: name.text,
                            annualEstimate: estimate,
                            currency: c,
                            purpose: purpose.text,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Create jar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFE8F6F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF0E7C66).withValues(alpha: 0.15)),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  const _ExampleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _BufferJarCard extends StatelessWidget {
  const _BufferJarCard({
    required this.name,
    required this.purpose,
    required this.progress,
    required this.saved,
    required this.yearlyGoal,
    required this.monthlySuggestion,
    required this.onAddMoney,
    required this.onDelete,
  });

  final String name;
  final String? purpose;
  final double progress;
  final String saved;
  final String yearlyGoal;
  final String monthlySuggestion;
  final VoidCallback onAddMoney;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round().clamp(0, 100);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF0E7C66).withValues(alpha: 0.1),
                  child: const Icon(Icons.inventory_2_outlined, size: 18, color: Color(0xFF0E7C66)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      if (purpose != null && purpose!.isNotEmpty)
                        Text(purpose!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Remove jar',
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  percent >= 100 ? 'Goal reached for the year' : '$percent% saved toward yearly goal',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0E7C66)),
                ),
                Text('$percent%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                color: const Color(0xFF0E7C66),
                backgroundColor: Colors.black.withValues(alpha: 0.06),
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Saved so far', value: saved),
            const SizedBox(height: 4),
            _InfoRow(label: 'Yearly goal', value: yearlyGoal),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Suggested each month',
              value: monthlySuggestion,
              emphasized: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAddMoney,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Put money aside'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: emphasized ? FontWeight.w600 : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
            color: emphasized ? const Color(0xFF0E7C66) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
