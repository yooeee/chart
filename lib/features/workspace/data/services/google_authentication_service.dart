import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthenticationService {
  static const _webClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const _serverClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;
  bool _initialized = false;

  bool get isConfigured =>
      kIsWeb ? _webClientId.isNotEmpty : _serverClientId.isNotEmpty;

  bool get supportsProgrammaticSignIn =>
      _initialized && _googleSignIn.supportsAuthenticate();

  Future<void> initialize(
    Future<void> Function(GoogleSignInAccount? account) onAccountChanged,
  ) async {
    if (!isConfigured || _initialized) return;
    await _googleSignIn.initialize(
      clientId: kIsWeb ? _webClientId : null,
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
    _subscription = _googleSignIn.authenticationEvents.listen((event) async {
      final account = switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };
      await onAccountChanged(account);
    });
    _initialized = true;
    await _googleSignIn.attemptLightweightAuthentication();
  }

  Future<void> signIn() async {
    if (!isConfigured) {
      throw StateError('Google OAuth Client ID가 설정되지 않았습니다.');
    }
    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError('이 플랫폼은 Google 공식 로그인 버튼을 사용해야 합니다.');
    }
    await _googleSignIn.authenticate();
  }

  Future<void> signOut() async {
    if (_initialized) await _googleSignIn.signOut();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
