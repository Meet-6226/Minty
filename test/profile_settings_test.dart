import 'package:drift/native.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/auth_provider.dart';
import 'package:minty/providers/database_providers.dart';
import 'package:minty/providers/settings_providers.dart';
import 'package:minty/providers/theme_provider.dart';
import 'package:minty/screens/category_management_screen.dart';
import 'package:minty/screens/profile_screen.dart';
import 'package:minty/theme/app_colors.dart';
import 'package:minty/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget(Widget child, ProviderContainer container,
      {ThemeData? theme}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('Appearance & Theme Tests', () {
    test('themeModeProvider switches between system, light, and dark', () {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      expect(container.read(themeModeProvider), ThemeMode.light);

      container.read(themeModeProvider.notifier).setDarkMode();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      container.read(themeModeProvider.notifier).setLightMode();
      expect(container.read(themeModeProvider), ThemeMode.light);

      container.read(themeModeProvider.notifier).setSystemMode();
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('AppTheme.darkTheme adheres to Dark Navy specifications', () {
      final dark = AppTheme.darkTheme;

      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(dark.colorScheme.surface, AppColors.darkCardSurface);
      expect(dark.colorScheme.primary, AppColors.mintPrimary);
      expect(dark.primaryColor, AppColors.mintPrimary);
    });

    test('AppTheme.lightTheme adheres to Light Minty specifications', () {
      final light = AppTheme.lightTheme;

      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, AppColors.background);
      expect(light.colorScheme.surface, AppColors.cardSurface);
      expect(light.colorScheme.primary, AppColors.mintPrimary);
    });
  });

  group('Currency Architecture & Settings Tests', () {
    test('Default currency is INR with correct symbol and formatting', () {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      final currency = container.read(currencyProvider);
      expect(currency.code, 'INR');
      expect(currency.symbol, '₹');
      expect(currency.name, 'Indian Rupee');
      expect(currency.format(1250.0), '₹1,250.00');
      expect(currency.format(1250.0, showDecimals: false), '₹1,250');
    });

    test('Extensible currency support allows switching currencies', () {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      final notifier = container.read(currencyProvider.notifier);

      notifier.setCurrency(CurrencyConfig.usd);
      expect(container.read(currencyProvider).code, 'USD');
      expect(container.read(currencyProvider).symbol, '\$');

      notifier.setCurrency(CurrencyConfig.eur);
      expect(container.read(currencyProvider).code, 'EUR');
      expect(container.read(currencyProvider).symbol, '€');

      notifier.setCurrency(CurrencyConfig.gbp);
      expect(container.read(currencyProvider).code, 'GBP');
      expect(container.read(currencyProvider).symbol, '£');

      notifier.setCurrency(CurrencyConfig.jpy);
      expect(container.read(currencyProvider).code, 'JPY');
      expect(container.read(currencyProvider).symbol, '¥');
    });

    test('Notification and Security settings toggles work properly', () {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      final notifNotifier =
          container.read(notificationSettingsProvider.notifier);
      expect(container.read(notificationSettingsProvider).transactionAlerts,
          isTrue);
      notifNotifier.toggleTransactionAlerts(false);
      expect(container.read(notificationSettingsProvider).transactionAlerts,
          isFalse);

      final secNotifier = container.read(securitySettingsProvider.notifier);
      expect(
          container.read(securitySettingsProvider).biometricAuthEnabled,
          isFalse);
      secNotifier.toggleBiometrics(true);
      expect(container.read(securitySettingsProvider).biometricAuthEnabled,
          isTrue);
    });
  });

  group('Category Creation & Database Management Tests', () {
    test('Can insert custom expense category in SQLite', () async {
      final newId = await db.insertCategory(
        CategoriesCompanion.insert(
          name: 'Gaming & Subscriptions',
          type: 'expense',
          icon: 'sports_esports_outlined',
        ),
      );

      expect(newId, greaterThan(0));

      final allCategories = await db.getAllCategories();
      final added = allCategories.firstWhere((c) => c.id == newId);
      expect(added.name, 'Gaming & Subscriptions');
      expect(added.type, 'expense');
      expect(added.icon, 'sports_esports_outlined');
    });

    test('Can insert custom income category in SQLite', () async {
      final newId = await db.insertCategory(
        CategoriesCompanion.insert(
          name: 'Consulting Retainer',
          type: 'income',
          icon: 'work_outline_rounded',
        ),
      );

      expect(newId, greaterThan(0));

      final allCategories = await db.getAllCategories();
      final added = allCategories.firstWhere((c) => c.id == newId);
      expect(added.name, 'Consulting Retainer');
      expect(added.type, 'income');
    });
  });

  group('Logout & Authentication Session Tests', () {
    test('Logout clears session but keeps database data intact', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      // Register and login
      final user = await db.registerUser(
        name: 'Alex Johnson',
        email: 'alex@minty.app',
        password: 'password123',
      );

      final loginSuccess = await container
          .read(authProvider.notifier)
          .login('alex@minty.app', 'password123');
      expect(loginSuccess, isTrue);
      expect(container.read(authProvider).isAuthenticated, isTrue);
      expect(container.read(authProvider).user?.id, user.id);

      // Now logout
      container.read(authProvider.notifier).logout();
      expect(container.read(authProvider).isAuthenticated, isFalse);
      expect(container.read(authProvider).user, isNull);

      // Verify database still holds user and financial data
      final dbUser = await db.getUserByEmail('alex@minty.app');
      expect(dbUser, isNotNull);
      expect(dbUser?.name, 'Alex Johnson');

      final accounts = await db.getAllAccounts();
      expect(accounts, isNotEmpty);
    });
  });

  group('ProfileScreen & CategoryManagementScreen Widget Tests', () {
    testWidgets('ProfileScreen renders user avatar, name, and settings items',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestableWidget(const ProfileScreen(), container),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Personal Account'), findsOneWidget);
      expect(find.text('Financial Management'), findsOneWidget);
      expect(find.text('Monthly Budgets'), findsOneWidget);
      expect(find.text('Savings Goals'), findsOneWidget);
      expect(find.text('Recurring Expenses'), findsOneWidget);
      expect(find.text('Round-Off Wallet'), findsOneWidget);
      expect(find.text('Monthly Summary'), findsOneWidget);

      expect(find.text('Settings & Preferences'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('About Minty'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Tapping Appearance opens modal sheet with Theme options',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestableWidget(const ProfileScreen(), container),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      // Select Dark Mode
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.dark);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Tapping Currency opens modal sheet with supported currencies',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestableWidget(const ProfileScreen(), container),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();

      expect(find.text('Indian Rupee (₹)'), findsOneWidget);
      expect(find.text('US Dollar (\$)'), findsOneWidget);
      expect(find.text('Euro (€)'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Tapping About Minty shows app metadata and privacy notice',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestableWidget(const ProfileScreen(), container),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('About Minty'));
      await tester.pumpAndSettle();

      expect(find.text('Minty Finance'), findsOneWidget);
      expect(find.text('Version 1.0.0 (Build 2026)'), findsOneWidget);
      expect(find.text('100% Local & Private Database'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('CategoryManagementScreen renders tabs and lists categories',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestableWidget(const CategoryManagementScreen(), container),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Add Category'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}


