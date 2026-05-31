import 'package:url_launcher/url_launcher.dart';

import '../constants/subscription_constants.dart';

/// Opens WhatsApp chat with the Pocket Accountant support number.
class WhatsAppSupport {
  static Uri chatUri(String message) {
    return Uri.parse(
      'https://wa.me/${SubscriptionConstants.supportWhatsApp}?text=${Uri.encodeComponent(message)}',
    );
  }

  static Future<bool> openChat(String message) async {
    final uri = chatUri(message);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
