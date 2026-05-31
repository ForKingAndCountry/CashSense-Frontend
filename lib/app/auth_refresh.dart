import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] when the app session changes (login / logout).
final class AuthRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}
