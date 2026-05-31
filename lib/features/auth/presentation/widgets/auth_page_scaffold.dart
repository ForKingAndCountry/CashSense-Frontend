import 'package:flutter/material.dart';

import '../../../../core/constants/app_branding.dart';

/// Shared header + layout for sign-in flows (matches app scaffold + card style).
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.bottom,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: primary.withValues(alpha: 0.12),
                    child: Icon(Icons.account_balance_wallet_outlined, color: primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppBranding.appName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: child,
                ),
              ),
              if (bottom != null) ...[
                const SizedBox(height: 20),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String firebaseAuthMessage(Object e) {
  final s = e.toString();
  if (s.contains('invalid-email')) return 'That email address looks invalid.';
  if (s.contains('user-disabled')) return 'This account has been disabled.';
  if (s.contains('user-not-found')) return 'No account found for that email.';
  if (s.contains('wrong-password')) return 'Incorrect password.';
  if (s.contains('invalid-credential')) return 'Email or password is incorrect.';
  if (s.contains('email-already-in-use')) return 'An account already exists with this email.';
  if (s.contains('weak-password')) return 'Password should be at least 6 characters.';
  if (s.contains('network-request-failed')) return 'Network error. Check your connection.';
  if (s.contains('too-many-requests')) return 'Too many attempts. Try again later.';
  return 'Something went wrong. Please try again.';
}
