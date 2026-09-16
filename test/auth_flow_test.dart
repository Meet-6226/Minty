import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/auth_provider.dart';
import 'package:minty/providers/database_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('Authentication Flow Tests', () {
    test('Seeded user can log in with default password', () async {
      final authNotifier = container.read(authProvider.notifier);

      final loginSuccess =
          await authNotifier.login('meet@minty.app', 'password123');
      expect(loginSuccess, isTrue);

      final authState = container.read(authProvider);
      expect(authState.user, isNotNull);
      expect(authState.user?.name, 'Meet Alshi');
      expect(authState.user?.email, 'meet@minty.app');
      expect(authState.isAuthenticated, isTrue);
    });

    test('Login fails with incorrect password', () async {
      final authNotifier = container.read(authProvider.notifier);

      final loginSuccess =
          await authNotifier.login('meet@minty.app', 'wrongpassword');
      expect(loginSuccess, isFalse);

      final authState = container.read(authProvider);
      expect(authState.user, isNull);
      expect(authState.errorMessage, contains('Incorrect password'));
    });

    test('Login fails for non-existent user email', () async {
      final authNotifier = container.read(authProvider.notifier);

      final loginSuccess =
          await authNotifier.login('unknown@minty.app', 'password123');
      expect(loginSuccess, isFalse);

      final authState = container.read(authProvider);
      expect(authState.user, isNull);
      expect(authState.errorMessage, contains('No account found'));
    });

    test('New user can register and is immediately authenticated', () async {
      final authNotifier = container.read(authProvider.notifier);

      final regSuccess = await authNotifier.register(
        name: 'Rahul Sharma',
        email: 'rahul@minty.app',
        password: 'securePassword99',
      );
      expect(regSuccess, isTrue);

      final authState = container.read(authProvider);
      expect(authState.user, isNotNull);
      expect(authState.user?.name, 'Rahul Sharma');
      expect(authState.user?.email, 'rahul@minty.app');

      // Verify user is persisted in SQLite
      final dbUser = await db.getUserByEmail('rahul@minty.app');
      expect(dbUser, isNotNull);
      expect(dbUser?.name, 'Rahul Sharma');

      // Logout
      authNotifier.logout();
      expect(container.read(authProvider).user, isNull);
      expect(container.read(authProvider).isAuthenticated, isFalse);

      // Log back in with new credentials
      final reloginSuccess =
          await authNotifier.login('rahul@minty.app', 'securePassword99');
      expect(reloginSuccess, isTrue);
      expect(container.read(authProvider).user?.name, 'Rahul Sharma');
    });

    test('Registration fails if email is already registered', () async {
      final authNotifier = container.read(authProvider.notifier);

      final regSuccess = await authNotifier.register(
        name: 'Duplicate Meet',
        email: 'meet@minty.app',
        password: 'anyPassword123',
      );
      expect(regSuccess, isFalse);

      final authState = container.read(authProvider);
      expect(authState.errorMessage, contains('already exists'));
    });
  });
}
