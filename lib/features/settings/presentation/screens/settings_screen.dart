import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../app/sync_coordinator.dart';
import '../../../debts/presentation/providers/debts_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../wallets/presentation/providers/wallets_provider.dart';
import '../../../buffers/presentation/providers/buffers_provider.dart';
import '../../../allocation/presentation/providers/allocation_plan_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../domain/entities/app_settings_entity.dart';
import '../../../../domain/entities/currency.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final authUser = ref.watch(authSessionProvider);
    final settings = settingsAsync.value ?? AppSettingsEntity.defaults;
    final accountEmail = authUser?.email;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _SectionTitle(title: 'YOUR FINANCIAL SYSTEM'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black.withValues(alpha: 0.06),
                    child: const Icon(Icons.savings_outlined, size: 18, color: Colors.black54),
                  ),
                  title: const Text('Plan-ahead savings', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text(
                    'Save monthly for bills you know are coming (car, school, repairs)',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.buffers),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black.withValues(alpha: 0.06),
                    child: const Icon(Icons.pie_chart_outline, size: 18, color: Colors.black54),
                  ),
                  title: const Text('Allocation plan', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Pay yourself first — pre-decided splits', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.allocationPlan),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionTitle(title: 'REPORTS'),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black.withValues(alpha: 0.06),
                child: const Icon(Icons.assessment_outlined, size: 18, color: Colors.black54),
              ),
              title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text(
                'Generate, view, and download CSV reports',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.reports),
            ),
          ),
          const SizedBox(height: 14),
          _SectionTitle(title: 'CURRENCY & WALLETS'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black.withValues(alpha: 0.06),
                        child: const Icon(Icons.currency_exchange, size: 18, color: Colors.black54),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Base currency', style: TextStyle(fontWeight: FontWeight.w700)),
                            SizedBox(height: 2),
                            Text('Totals convert into this currency', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<Currency>(
                          initialValue: settings.baseCurrency,
                          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                          items: [
                            for (final c in Currency.all)
                              DropdownMenuItem(value: c, child: Text(c.code)),
                          ],
                          onChanged: (c) {
                            if (c == null) return;
                            ref.read(settingsProvider.notifier).setSettings(
                                  settings.copyWith(baseCurrency: c),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black.withValues(alpha: 0.06),
                      child: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: Colors.black54),
                    ),
                    title: const Text('Wallets', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Multiple wallets per currency (e.g. LRD cash + USD cash)', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.wallets),
                  ),
                  const Divider(height: 22),
                  Text('Exchange rates → ${settings.baseCurrency.code}', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter how many base units equal 1 unit of each currency. Example: if base is LRD and 1 USD = 192 LRD, enter 192 for USD.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const _RatesToBaseSection(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SectionTitle(title: 'ACCOUNT'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black.withValues(alpha: 0.06),
                        child: const Icon(Icons.person_outline, size: 18, color: Colors.black54),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Signed in', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              accountEmail ?? '—',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Hive.box<Map>(AppBoxes.transactions).clear();
                        await Hive.box<Map>(AppBoxes.debts).clear();
                        await Hive.box<Map>(AppBoxes.syncQueue).clear();
                        await Hive.box<Map>(AppBoxes.subscription).clear();
                        await Hive.box<Map>(AppBoxes.wallets).clear();
                        await Hive.box<Map>(AppBoxes.buffers).clear();
                        await Hive.box<Map>(AppBoxes.allocationPlans).clear();
                        await Hive.box<Map>(AppBoxes.reports).clear();
                        ref.invalidate(transactionsProvider);
                        ref.invalidate(debtsProvider);
                        ref.invalidate(subscriptionProvider);
                        ref.invalidate(walletsProvider);
                        ref.invalidate(buffersProvider);
                        ref.invalidate(allocationPlanProvider);

                        await ref.read(authSessionProvider.notifier).logout(
                              ref.read(authRefreshListenableProvider),
                            );
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Sign out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SectionTitle(title: 'DATA & SECURITY'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black.withValues(alpha: 0.06),
                    child: const Icon(Icons.sync, size: 18, color: Colors.black54),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sync Status', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Offline mode is okay', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () async {
                      await ref.read(syncCoordinatorProvider).runFullSync();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sync finished (push queue + pull cloud).')),
                        );
                      }
                    },
                    child: const Text('Backup'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatesToBaseSection extends ConsumerWidget {
  const _RatesToBaseSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value ?? AppSettingsEntity.defaults;
    final currency = ref.watch(currencyServiceProvider);
    final targets = Currency.all.where((c) => c != settings.baseCurrency).toList();

    return Column(
      children: [
        for (final c in targets)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Text(c.code, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('rate_${settings.baseCurrency.code}_${c.code}_${settings.ratesToBase[c.code]}_${settings.exchangeRateUsdToLrd}'),
                    initialValue: _initialRate(settings, currency, c),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: '1 ${c.code} = ? ${settings.baseCurrency.code}',
                    ),
                    onFieldSubmitted: (v) {
                      final parsed = double.tryParse(v.trim());
                      if (parsed == null || parsed <= 0) return;
                      final nextRates = Map<String, double>.from(settings.ratesToBase);
                      nextRates[c.code] = parsed;
                      var ex = settings.exchangeRateUsdToLrd;
                      if (settings.baseCurrency == Currency.lrd && c == Currency.usd) {
                        ex = parsed;
                      }
                      if (settings.baseCurrency == Currency.usd && c == Currency.lrd) {
                        ex = parsed > 0 ? 1 / parsed : settings.exchangeRateUsdToLrd;
                      }
                      ref.read(settingsProvider.notifier).setSettings(
                            settings.copyWith(
                              ratesToBase: nextRates,
                              exchangeRateUsdToLrd: ex,
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _initialRate(AppSettingsEntity settings, CurrencyService currency, Currency c) {
    final v = currency.unitsOfBasePerUnitOf(c);
    if (c == Currency.usd || c == Currency.lrd) {
      return v.toStringAsFixed(2);
    }
    return v == 1 ? '' : v.toStringAsFixed(4);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black54)),
    );
  }
}
