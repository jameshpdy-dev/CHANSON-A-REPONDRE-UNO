import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chanson_2/app.dart';
import 'package:uno_chanson_2/core/app_router.dart';
import 'package:uno_chanson_2/models/auth_user.dart';
import 'package:uno_chanson_2/services/auth_service.dart';

void main() {
  const user = AuthUser(id: 'user-1', email: 'user@example.com');

  Future<void> openProfile(
    WidgetTester tester,
    _ProfileAuthService auth,
  ) async {
    AppRouter.router.go(AppRoutes.profile);
    await tester.pumpWidget(
      ChansonUnoApp(
        aiBackendUrlOverride: 'https://api.test',
        authServiceOverride: auth,
      ),
    );
    await tester.pump();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  testWidgets('signed-out Profile renders the complete login form', (
    tester,
  ) async {
    await openProfile(tester, _ProfileAuthService());

    expect(find.text('PROFILE'), findsOneWidget);
    expect(find.text('Sign in to access AI features'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('SIGN IN'), findsOneWidget);
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    expect(find.text('FORGOT PASSWORD'), findsOneWidget);
  });

  testWidgets('Profile validates email and password before sign-in', (
    tester,
  ) async {
    final auth = _ProfileAuthService(signInUser: user);
    await openProfile(tester, auth);

    await tapVisible(tester, find.text('SIGN IN'));

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('successful sign-in shows safe account and AI actions', (
    tester,
  ) async {
    final auth = _ProfileAuthService(signInUser: user);
    await openProfile(tester, auth);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      user.email,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password',
    );
    await tapVisible(tester, find.text('SIGN IN'));

    expect(find.text('Signed in'), findsOneWidget);
    expect(find.text('Email: ${user.email}'), findsOneWidget);
    expect(find.text('OPEN AI CHAT'), findsOneWidget);
    expect(find.text('OPEN CARD TRANSCRIPTION'), findsOneWidget);
    expect(find.text('SIGN OUT'), findsOneWidget);
  });

  testWidgets('registration confirmation remains signed out', (tester) async {
    final auth = _ProfileAuthService(
      registerError: const EmailConfirmationRequiredException(),
    );
    await openProfile(tester, auth);

    await tapVisible(tester, find.text('CREATE ACCOUNT'));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), user.email);
    await tester.enterText(fields.at(1), 'password');
    await tester.enterText(fields.at(2), 'password');
    await tapVisible(tester, find.text('CREATE ACCOUNT').last);

    expect(find.textContaining('Check your email'), findsWidgets);
    expect(find.text('SIGN IN'), findsOneWidget);
  });

  testWidgets('password reset is neutral and logout clears identity', (
    tester,
  ) async {
    final auth = _ProfileAuthService(signInUser: user);
    await openProfile(tester, auth);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      user.email,
    );
    await tapVisible(tester, find.text('FORGOT PASSWORD'));
    expect(
      find.textContaining('If an account exists for this email'),
      findsOneWidget,
    );
    expect(auth.resetCalls, 1);

    auth.emit(user);
    await tester.pump();
    await tapVisible(tester, find.text('SIGN OUT'));
    expect(find.text('SIGN IN'), findsOneWidget);
    final emailField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Email'),
    );
    expect(emailField.controller?.text, isEmpty);
  });
}

class _ProfileAuthService implements AuthService {
  _ProfileAuthService({
    this.signInUser,
    this.registerError,
    AuthUser? currentUser,
  }) : _current = currentUser;

  final AuthUser? signInUser;
  final AuthException? registerError;
  final _changes = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;
  int signInCalls = 0;
  int resetCalls = 0;

  void emit(AuthUser? user) {
    _current = user;
    _changes.add(user);
  }

  @override
  Stream<AuthUser?> get authStateChanges => _changes.stream;
  @override
  AuthUser? get currentUser => _current;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    final user =
        signInUser ?? (throw const AuthException('Invalid email or password.'));
    emit(user);
    return user;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    if (registerError != null) throw registerError!;
    final user =
        signInUser ??
        (throw const AuthException('Authentication service is unavailable.'));
    emit(user);
    return user;
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    resetCalls++;
  }

  @override
  Future<void> signOut() async => emit(null);
  @override
  Future<String?> getAccessToken() async => _current == null ? null : 'token';
  @override
  Future<String?> refreshAccessToken() async =>
      _current == null ? null : 'token';
  @override
  Future<void> deleteAccount() async {}
}
