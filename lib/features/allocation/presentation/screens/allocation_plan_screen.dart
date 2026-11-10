import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/allocation_plan_entity.dart';
import '../providers/allocation_plan_provider.dart';

class AllocationPlanScreen extends ConsumerStatefulWidget {
  const AllocationPlanScreen({super.key});

  @override
  ConsumerState<AllocationPlanScreen> createState() => _AllocationPlanScreenState();
}

class _AllocationPlanScreenState extends ConsumerState<AllocationPlanScreen> {
  final _savings = TextEditingController();
  final _debt = TextEditingController();
  final _investment = TextEditingController();
  final _guiltFree = TextEditingController();
  bool _loaded = false;
  int _rebuildTick = 0;

  @override
  void dispose() {
    _savings.dispose();
    _debt.dispose();
    _investment.dispose();
    _guiltFree.dispose();
    super.dispose();
  }

  void _loadPlan(AllocationPlanEntity plan) {
    if (_loaded) return;
    _savings.text = plan.percentSavings.toStringAsFixed(0);
    _debt.text = plan.percentDebt.toStringAsFixed(0);
    _investment.text = plan.percentInvestment.toStringAsFixed(0);
    _guiltFree.text = plan.percentGuiltFree.toStringAsFixed(0);
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(allocationPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocation Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (plan) {
          _loadPlan(plan);
          final total = (_parse(_savings) + _parse(_debt) + _parse(_investment) + _parse(_guiltFree));
          final valid = (total - 100).abs() < 0.01;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'Pay yourself first',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'When income arrives, move money in this order — before spending. '
                'Percentages must total 100%.',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _PercentField(
                controller: _savings,
                label: 'Untouchable savings',
                icon: Icons.lock,
                onChanged: () => setState(() => _rebuildTick++),
              ),
              _PercentField(
                controller: _debt,
                label: 'Obligation repayment',
                icon: Icons.credit_card,
                onChanged: () => setState(() => _rebuildTick++),
              ),
              _PercentField(
                controller: _investment,
                label: 'Future investment',
                icon: Icons.trending_up,
                onChanged: () => setState(() => _rebuildTick++),
              ),
              _PercentField(
                controller: _guiltFree,
                label: 'Guilt-free spending',
                icon: Icons.celebration,
                onChanged: () => setState(() => _rebuildTick++),
              ),
              // ignore: unused_local_variable — forces rebuild when percentages change
              if (_rebuildTick >= 0) const SizedBox.shrink(),
              const SizedBox(height: 12),
              Text(
                'Total: ${total.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: valid ? const Color(0xFF0E7C66) : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: valid
                    ? () async {
                        final now = DateTime.now();
                        await ref.read(allocationPlanProvider.notifier).save(
                              plan.copyWith(
                                percentSavings: _parse(_savings),
                                percentDebt: _parse(_debt),
                                percentInvestment: _parse(_investment),
                                percentGuiltFree: _parse(_guiltFree),
                                updatedAt: now,
                              ),
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Allocation plan saved.')),
                          );
                          context.pop();
                        }
                      }
                    : null,
                child: const Text('Save plan'),
              ),
            ],
          );
        },
      ),
    );
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
}

class _PercentField extends StatelessWidget {
  const _PercentField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          suffixText: '%',
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}
