import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import 'upgrade_modal.dart';

/// Shows the upgrade modal once per session when the free trial has ended.
class SubscriptionUpgradeListener extends ConsumerStatefulWidget {
  const SubscriptionUpgradeListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SubscriptionUpgradeListener> createState() =>
      _SubscriptionUpgradeListenerState();
}

class _SubscriptionUpgradeListenerState extends ConsumerState<SubscriptionUpgradeListener> {
  void _promptIfSoftLocked() {
    if (ref.read(upgradeModalShownThisSessionProvider)) return;
    final sub = ref.read(subscriptionProvider);
    if (sub?.isSoftLocked != true) return;

    ref.read(upgradeModalShownThisSessionProvider.notifier).state = true;
    showUpgradeModal(context: context, ref: ref);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _promptIfSoftLocked();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(subscriptionProvider, (previous, next) {
      if (next?.isSoftLocked != true) return;
      if (previous?.isSoftLocked == true) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _promptIfSoftLocked();
      });
    });
    return widget.child;
  }
}
