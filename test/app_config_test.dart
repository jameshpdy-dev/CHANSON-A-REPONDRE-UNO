import 'package:flutter_test/flutter_test.dart';
import 'package:uno_chanson_2/core/app_config.dart';

void main() {
  test('development authentication bypass is disabled by default', () {
    expect(AppConfig.skipAuthForDevelopment, isFalse);
  });
  test('normalizes backend URL whitespace and trailing slashes', () {
    expect(
      AppConfig.normalizeAiBackendUrl('  https://api.example.com///  '),
      'https://api.example.com',
    );
  });

  test('accepts only HTTP and HTTPS URLs with a host', () {
    expect(AppConfig.isValidAiBackendUrl('http://127.0.0.1:3000'), isTrue);
    expect(AppConfig.isValidAiBackendUrl('https://api.example.com'), isTrue);
    expect(AppConfig.isValidAiBackendUrl('ftp://api.example.com'), isFalse);
    expect(AppConfig.isValidAiBackendUrl('not a url'), isFalse);
    expect(AppConfig.isValidAiBackendUrl(''), isFalse);
  });

  test('rejects missing and placeholder Supabase configuration', () {
    expect(AppConfig.isPlaceholder(''), isTrue);
    expect(AppConfig.isPlaceholder('YOUR_PUBLIC_ANON_KEY'), isTrue);
    expect(AppConfig.isPlaceholder('REAL_PROJECT_ID'), isTrue);
    expect(AppConfig.isPlaceholder('REAL_PUBLISHABLE_KEY'), isTrue);
    expect(AppConfig.isPlaceholder('YOUR_PROJECT_ID'), isTrue);
    expect(AppConfig.isPlaceholder('replace_with_a_real_key'), isTrue);
    expect(AppConfig.isPlaceholder('example_key'), isTrue);
    expect(AppConfig.isPlaceholder('dummy-value'), isTrue);
    expect(
      AppConfig.isValidSupabaseUrl('https://YOUR_PROJECT.supabase.co'),
      isFalse,
    );
    expect(
      AppConfig.isValidSupabaseUrl('https://project-ref.supabase.co'),
      isTrue,
    );
  });

  test('accepts plausible JWT and modern publishable client keys', () {
    expect(
      AppConfig.isValidSupabaseClientKey(
        'sb_publishable_abcdefghijklmnopqrstuvwx',
      ),
      isTrue,
    );
    expect(
      AppConfig.isValidSupabaseClientKey(
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature',
      ),
      isTrue,
    );
    expect(AppConfig.isValidSupabaseClientKey('sb_publishable_short'), isFalse);
    expect(AppConfig.isValidSupabaseClientKey('REAL_PUBLISHABLE_KEY'), isFalse);
  });
}
