import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

enum AuthenticationMode {
  loading,
  unauthenticated,
  developmentBypass,
  authenticated,
  configurationError,
}

class AuthController extends ChangeNotifier {
  AuthController(
    this.service, {
    this.developmentBypassEnabled = false,
    this.configurationError = false,
  }) {
    _user = service.currentUser;
    status = _user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    _subscription = service.authStateChanges.listen(_onAuthState);
  }

  final AuthService service;
  final bool developmentBypassEnabled;
  final bool configurationError;
  late final StreamSubscription<AuthUser?> _subscription;
  AuthStatus status = AuthStatus.loading;
  AuthUser? _user;
  AuthUser? get user => _user;
  AuthenticationMode get mode {
    if (status == AuthStatus.loading) return AuthenticationMode.loading;
    if (_user != null) return AuthenticationMode.authenticated;
    if (configurationError) return AuthenticationMode.configurationError;
    if (developmentBypassEnabled && !_bypassSuppressed) {
      return AuthenticationMode.developmentBypass;
    }
    return AuthenticationMode.unauthenticated;
  }

  bool get canUseProtectedAi => mode == AuthenticationMode.authenticated;
  bool _bypassSuppressed = false;
  bool busy = false;
  String? error;

  void showRealSignIn() {
    _bypassSuppressed = true;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) =>
      _execute(() => service.signIn(email: email, password: password));
  Future<bool> register(String email, String password) =>
      _execute(() => service.register(email: email, password: password));

  Future<bool> sendPasswordReset(String email) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await service.sendPasswordReset(email: email);
      return true;
    } on AuthException catch (exception) {
      error = exception.message;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await service.signOut();
    _onAuthState(null);
  }

  Future<bool> refreshSession() async {
    error = null;
    try {
      final token = await service.refreshAccessToken();
      if (token == null || token.isEmpty) {
        throw const AuthException('Your session could not be refreshed.');
      }
      return true;
    } on AuthException catch (exception) {
      error = exception.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _execute(Future<AuthUser> Function() action) async {
    if (busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      _onAuthState(await action());
      return true;
    } on AuthException catch (exception) {
      error = exception.message;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  void _onAuthState(AuthUser? value) {
    _user = value;
    status = value == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
