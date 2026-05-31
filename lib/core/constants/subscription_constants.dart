import 'app_branding.dart';

/// Subscription pricing and support contact (Liberia).
abstract final class SubscriptionConstants {
  static const monthlyPriceUsd = 3.0;
  static const monthlyPriceLabel = r'USD $3/month';

  static const annualPriceUsd = 18.0;
  static const annualPriceLabel = r'USD $18/year';

  static const pricingOptions = [SubscriptionPlan.monthly, SubscriptionPlan.annual];

  /// WhatsApp number without + or spaces (wa.me format).
  static const supportWhatsApp = '231773260121';

  static const localPaymentTitle = 'Local payment';

  static const orangeMoney = PaymentAccount(
    label: 'Orange Money',
    accountName: 'Owen W. Blay',
    accountNumber: '0760695842',
  );

  static const mobileMoney = PaymentAccount(
    label: 'Mobile Money',
    accountName: 'Caleb Massalay',
    accountNumber: '0555876216',
  );

  static const regionalPaymentTitle = 'Regional payment';
  static const regionalPaymentNote = 'Details will come soon.';

  static String paymentInquiryMessage({
    required String userEmail,
    String? userName,
    SubscriptionPlan plan = SubscriptionPlan.monthly,
  }) {
    final name = userName?.trim();
    return [
      'Hello ${AppBranding.appName} support,',
      '',
      'I would like to subscribe (${plan.priceLabel}).',
      'Please help me with payment or activation.',
      '',
      if (name != null && name.isNotEmpty) 'Name: $name',
      'App email: $userEmail',
      '',
      'Thank you.',
    ].join('\n');
  }

  static String paymentProofMessage({
    required String userEmail,
    String? userName,
    SubscriptionPlan plan = SubscriptionPlan.monthly,
  }) {
    final name = userName?.trim();
    return [
      'Hello ${AppBranding.appName} support,',
      '',
      'I have paid ${plan.priceLabel} for my ${plan.billingPeriod} subscription.',
      'Please activate my account after you confirm my payment.',
      '',
      'I will attach my receipt screenshot in this chat',
      '(Orange Money / Mobile Money).',
      '',
      if (name != null && name.isNotEmpty) 'Name: $name',
      'App email: $userEmail',
      '',
      'Thank you.',
    ].join('\n');
  }

  static String localPaymentSummary() {
    return [
      '$localPaymentTitle:',
      '${orangeMoney.label} — ${orangeMoney.accountName}, No. ${orangeMoney.accountNumber}',
      '${mobileMoney.label} — ${mobileMoney.accountName}, No. ${mobileMoney.accountNumber}',
    ].join('\n');
  }
}

class PaymentAccount {
  const PaymentAccount({
    required this.label,
    required this.accountName,
    required this.accountNumber,
  });

  final String label;
  final String accountName;
  final String accountNumber;
}

enum SubscriptionPlan {
  monthly,
  annual;

  String get priceLabel => switch (this) {
        SubscriptionPlan.monthly => SubscriptionConstants.monthlyPriceLabel,
        SubscriptionPlan.annual => SubscriptionConstants.annualPriceLabel,
      };

  String get title => switch (this) {
        SubscriptionPlan.monthly => 'Monthly',
        SubscriptionPlan.annual => 'Annual / Yearly',
      };

  String get billingPeriod => switch (this) {
        SubscriptionPlan.monthly => 'monthly',
        SubscriptionPlan.annual => 'annual',
      };

  String? get savingsNote => switch (this) {
        SubscriptionPlan.monthly => null,
        SubscriptionPlan.annual => 'Save vs 12 months at monthly rate',
      };
}
