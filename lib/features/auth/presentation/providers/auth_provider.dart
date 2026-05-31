import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/auth_refresh.dart';
import '../../../../domain/entities/auth_user_entity.dart';
import '../../data/auth_api_service.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) => AuthApiService());

final authSessionProvider = NotifierProvider<AuthSessionNotifier, AuthUserEntity?>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends Notifier<AuthUserEntity?> {
  @override
  AuthUserEntity? build() => null;

  Future<void> restoreSession() async {
    state = await ref.read(authApiServiceProvider).readSession();
  }

  Future<void> login({
    required String email,
    required String password,
    required AuthRefreshListenable refresh,
  }) async {
    state = await ref.read(authApiServiceProvider).login(email: email, password: password);
    refresh.refresh();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required AuthRefreshListenable refresh,
  }) async {
    state = await ref.read(authApiServiceProvider).register(
          name: name,
          email: email,
          password: password,
        );
    refresh.refresh();
  }

  Future<void> logout(AuthRefreshListenable refresh) async {
    await ref.read(authApiServiceProvider).logout();
    state = null;
    refresh.refresh();
  }
}
