import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chanson_2/screens/account_screen.dart';

void main() {
  group('Profile login validation', () {
    test('accepts trimmed email addresses', () {
      expect(validateProfileEmail(' user@example.com '), isNull);
    });

    test('rejects invalid email addresses', () {
      expect(
        validateProfileEmail('not-an-email'),
        'Enter a valid email address.',
      );
    });

    test('requires a password value', () {
      expect(validateProfilePassword(''), 'Enter your password.');
    });

    test('requires passwords with at least six characters', () {
      expect(
        validateProfilePassword('short'),
        'Password must contain at least 6 characters.',
      );
      expect(validateProfilePassword('password'), isNull);
    });

    test('requires matching registration confirmation', () {
      expect(
        validateProfilePasswordConfirmation(
          value: 'different',
          password: 'password',
        ),
        'Passwords do not match.',
      );
    });

    test('accepts matching registration confirmation', () {
      expect(
        validateProfilePasswordConfirmation(
          value: 'password',
          password: 'password',
        ),
        isNull,
      );
    });
  });
}
