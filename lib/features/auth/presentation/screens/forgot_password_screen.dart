import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_page_scaffold.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: 'Reset password',
      subtitle: 'Password reset is handled by your account administrator for now.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'The Next.js API does not include email reset yet. '
            'Use a new account or ask support to reset your password in the database.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}
