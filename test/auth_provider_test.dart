// test/auth_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:myraid/presentation/providers/auth_provider.dart';

/// A simple integration-style test that exercises AuthProvider using the
/// built-in mock backend (useRealApi = false in AppConfig).
///
/// Run with:  flutter test
void main() {
  late AuthProvider authProvider;

  setUp(() {
    authProvider = AuthProvider();
  });

  group('AuthProvider – mock backend', () {
    // ── login ──────────────────────────────────────────────────────────────
    test('login succeeds with valid credentials', () async {
      final result = await authProvider.login('jane@example.com', 'password123');

      expect(result, isTrue);
      expect(authProvider.state, AuthState.authenticated);
      expect(authProvider.user, isNotNull);
      expect(authProvider.user!.email, 'jane@example.com');
      expect(authProvider.errorMessage, isNull);
    });

    test('login fails when password is too short', () async {
      final result = await authProvider.login('jane@example.com', '123');

      expect(result, isFalse);
      expect(authProvider.state, AuthState.error);
      expect(authProvider.errorMessage, isNotNull);
    });

    test('login fails with empty email', () async {
      final result = await authProvider.login('', 'password123');

      expect(result, isFalse);
      expect(authProvider.state, AuthState.error);
    });

    test('login fails with invalid email format', () async {
      final result = await authProvider.login('notanemail', 'password123');

      expect(result, isFalse);
      expect(authProvider.state, AuthState.error);
    });

    // ── register ───────────────────────────────────────────────────────────
    test('register succeeds with valid data', () async {
      final result = await authProvider.register(
        'Jane Doe',
        'jane@example.com',
        'password123',
      );

      expect(result, isTrue);
      expect(authProvider.state, AuthState.authenticated);
      expect(authProvider.user!.name, 'Jane Doe');
    });

    test('register fails when a field is empty', () async {
      final result = await authProvider.register('', 'jane@example.com', 'pass');

      expect(result, isFalse);
      expect(authProvider.state, AuthState.error);
    });

    // ── logout ─────────────────────────────────────────────────────────────
    test('logout clears user and sets unauthenticated state', () async {
      // First log in
      await authProvider.login('jane@example.com', 'password123');
      expect(authProvider.isAuthenticated, isTrue);

      // Then log out
      await authProvider.logout();

      expect(authProvider.state, AuthState.unauthenticated);
      expect(authProvider.user, isNull);
      expect(authProvider.isAuthenticated, isFalse);
    });

    // ── initial state ──────────────────────────────────────────────────────
    test('initial state is AuthState.initial', () {
      expect(authProvider.state, AuthState.initial);
      expect(authProvider.user, isNull);
      expect(authProvider.isAuthenticated, isFalse);
    });
  });
}