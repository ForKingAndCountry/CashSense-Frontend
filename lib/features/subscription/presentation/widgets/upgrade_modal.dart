import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/services/whatsapp_support.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

Future<void> showUpgradeModal({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dContext) => const _UpgradeDialog(),
  );
}

class _UpgradeDialog extends ConsumerStatefulWidget {
  const _UpgradeDialog();

  @override
  ConsumerState<_UpgradeDialog> createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends ConsumerState<_UpgradeDialog> {
  bool _busy = false;
  bool _waitingForAdmin = false;
  SubscriptionPlan _selectedPlan = SubscriptionPlan.monthly;

  String get _userEmail {
    final auth = ref.read(authSessionProvider);
    return auth?.email ?? 'not signed in';
  }

  String? get _userName => ref.read(authSessionProvider)?.name;

  Future<void> _openWhatsApp(String message, {required bool afterPayment}) async {
    setState(() => _busy = true);
    final opened = await WhatsAppSupport.openChat(message);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (afterPayment) _waitingForAdmin = true;
    });

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open WhatsApp. Message ${SubscriptionConstants.supportWhatsApp} manually.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _onHavePaid() async {
    await _openWhatsApp(
      SubscriptionConstants.paymentProofMessage(
        userEmail: _userEmail,
        userName: _userName,
        plan: _selectedPlan,
      ),
      afterPayment: true,
    );
  }

  Future<void> _onContactSupport() async {
    await _openWhatsApp(
      SubscriptionConstants.paymentInquiryMessage(
        userEmail: _userEmail,
        userName: _userName,
        plan: _selectedPlan,
      ),
      afterPayment: false,
    );
  }

  Future<void> _onCheckActivation() async {
    setState(() => _busy = true);
    await ref.read(subscriptionProvider.notifier).verifyPayment();
    if (!mounted) return;
    setState(() => _busy = false);

    final sub = ref.read(subscriptionProvider);
    if (sub?.isActiveNow == true) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your subscription is active. Welcome back!')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not active yet. We will turn it on after we confirm your payment.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your free trial has ended'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a plan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final plan in SubscriptionConstants.pricingOptions) ...[
              _PlanOptionCard(
                plan: plan,
                selected: _selectedPlan == plan,
                onTap: _busy ? null : () => setState(() => _selectedPlan = plan),
              ),
              if (plan != SubscriptionConstants.pricingOptions.last) const SizedBox(height: 8),
            ],
            const SizedBox(height: 14),
            const Text(
              'Pay now',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Send ${_selectedPlan.priceLabel} using one of the accounts below, '
              'then tap “I have paid” to WhatsApp us your receipt.',
              style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 14),
            ),
            const SizedBox(height: 12),
            const _PaymentSection(
              title: SubscriptionConstants.localPaymentTitle,
              accounts: [
                SubscriptionConstants.orangeMoney,
                SubscriptionConstants.mobileMoney,
              ],
            ),
            const SizedBox(height: 10),
            const _PaymentSection(
              title: SubscriptionConstants.regionalPaymentTitle,
              note: SubscriptionConstants.regionalPaymentNote,
            ),
            const SizedBox(height: 12),
            _StepRow(
              number: '1',
              text: 'Pay ${_selectedPlan.priceLabel} to one of the numbers above.',
            ),
            const SizedBox(height: 8),
            _StepRow(
              number: '2',
              text: 'Tap I have paid — WhatsApp opens. Attach your receipt and send.',
            ),
            const SizedBox(height: 8),
            _StepRow(
              number: '3',
              text: 'We activate your account after we confirm payment (usually same day).',
            ),
            if (_waitingForAdmin) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE08A)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.hourglass_top, size: 20, color: Color(0xFFEF6C00)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Thanks! Send your receipt on WhatsApp if you have not already. '
                        'You can use the app fully again once we approve your payment.',
                        style: TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _busy ? null : _onHavePaid,
            icon: const Icon(Icons.chat, size: 20),
            label: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('I have paid — send receipt on WhatsApp'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _onContactSupport,
            icon: const Icon(Icons.support_agent, size: 20),
            label: const Text('Contact support on WhatsApp'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _onCheckActivation,
          child: const Text('I already paid — check if I’m active'),
        ),
      ],
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  const _PlanOptionCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE8F6F2) : const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF0E7C66) : const Color(0xFFE0E4EA),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? const Color(0xFF0E7C66) : Colors.black38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.priceLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF0A5D4E),
                      ),
                    ),
                    if (plan.savingsNote != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        plan.savingsNote!,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.title,
    this.accounts = const [],
    this.note,
  });

  final String title;
  final List<PaymentAccount> accounts;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E4EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0A5D4E)),
          ),
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(note!, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.35)),
          ],
          for (final account in accounts) ...[
            const SizedBox(height: 10),
            _PaymentAccountRow(account: account),
          ],
        ],
      ),
    );
  }
}

class _PaymentAccountRow extends StatelessWidget {
  const _PaymentAccountRow({required this.account});

  final PaymentAccount account;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCE3EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            account.label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text('Name: ${account.accountName}', style: const TextStyle(fontSize: 13, height: 1.35)),
          Text(
            'No. ${account.accountNumber}',
            style: const TextStyle(fontSize: 13, height: 1.35, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: const Color(0xFF0E7C66),
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.35, color: Colors.black87))),
      ],
    );
  }
}
