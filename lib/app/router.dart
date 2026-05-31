import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../features/add_transaction/presentation/screens/add_transaction_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/debts/presentation/screens/debts_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/wallets/presentation/screens/wallets_screen.dart';
import '../features/buffers/presentation/screens/buffers_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/allocation/presentation/screens/allocation_plan_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../domain/entities/report_entity.dart';
import 'providers.dart';
import 'shell.dart';

bool _isAuthRoute(String location) {
  return location == AppRoutes.login ||
      location == AppRoutes.signup ||
      location == AppRoutes.forgotPassword;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(authSessionProvider);
      final loc = state.matchedLocation;
      final onAuth = _isAuthRoute(loc);

      if (user == null && !onAuth) {
        return AppRoutes.login;
      }
      if (user != null && onAuth) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.history,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HistoryScreen()),
          ),
          GoRoute(
            path: AppRoutes.debts,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DebtsScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const AddTransactionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.wallets,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const WalletsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.buffers,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const BuffersScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.allocationPlan,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const AllocationPlanScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.reports,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const ReportsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.reportView,
        pageBuilder: (context, state) {
          final report = state.extra! as ReportEntity;
          return CustomTransitionPage(
            child: ReportViewScreen(report: report),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
    ],
  );
});
