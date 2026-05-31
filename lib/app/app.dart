import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_branding.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'router.dart';
import 'providers.dart';
import 'sync_lifecycle.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authSessionProvider.notifier).restoreSession().then((_) {
        ref.read(authRefreshListenableProvider).refresh();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    ref.watch(subscriptionProvider);

    return SyncLifecycleScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: AppBranding.appName,
        theme: AppTheme.light(),
        routerConfig: router,
      ),
    );
  }
}
