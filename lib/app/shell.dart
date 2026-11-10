import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../features/subscription/presentation/widgets/subscription_upgrade_listener.dart';
import '../features/subscription/presentation/widgets/upgrade_modal.dart';
import 'providers.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith(AppRoutes.history)) return 1;
    if (location.startsWith(AppRoutes.debts)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _goForIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        return;
      case 1:
        context.go(AppRoutes.history);
        return;
      case 2:
        context.go(AppRoutes.debts);
        return;
      case 3:
        context.go(AppRoutes.settings);
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexForLocation(location);
    final sub = ref.watch(subscriptionProvider);
    final softLocked = sub?.isSoftLocked ?? false;

    return Scaffold(
      body: SubscriptionUpgradeListener(child: child),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (softLocked) {
            await showUpgradeModal(context: context, ref: ref);
            return;
          }
          context.push(AppRoutes.addTransaction);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  selected: index == 0,
                  onTap: () => _goForIndex(context, 0),
                ),
                _NavItem(
                  icon: Icons.history,
                  label: 'History',
                  selected: index == 1,
                  onTap: () => _goForIndex(context, 1),
                ),
                const SizedBox(width: 40),
                _NavItem(
                  icon: Icons.people_outline,
                  label: 'Obligations',
                  selected: index == 2,
                  onTap: () => _goForIndex(context, 2),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  selected: index == 3,
                  onTap: () => _goForIndex(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).colorScheme.primary : Colors.black54;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}

