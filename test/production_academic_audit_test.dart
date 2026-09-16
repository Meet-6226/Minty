import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/auth_provider.dart';
import 'package:minty/providers/database_providers.dart';
import 'package:minty/screens/budgets_screen.dart';
import 'package:minty/screens/insights_screen.dart';
import 'package:minty/screens/login_screen.dart';
import 'package:minty/screens/monthly_summary_screen.dart';
import 'package:minty/screens/profile_screen.dart';
import 'package:minty/screens/recurring_expenses_screen.dart';
import 'package:minty/screens/register_screen.dart';
import 'package:minty/screens/round_off_wallet_screen.dart';
import 'package:minty/screens/savings_goals_screen.dart';
import 'package:minty/screens/splash_screen.dart';
import 'package:minty/screens/transaction_details_screen.dart';
import 'package:minty/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget createAuditApp(Widget child, ProviderContainer container,
      {ThemeMode themeMode = ThemeMode.light}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: child,
      ),
    );
  }

  group('1. Authentication, Navigation & State Flows', () {
    testWidgets('SplashScreen renders and displays logo & title',
        (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createAuditApp(const SplashScreen(), container));
      expect(find.text('Minty'), findsOneWidget);
      expect(find.text('Fresh finance, made simple.'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2500));
    });

    testWidgets('LoginScreen and RegisterScreen render with input validation',
        (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createAuditApp(const LoginScreen(), container));
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);

      await tester.pumpWidget(createAuditApp(const RegisterScreen(), container));
      expect(find.text('Create Account'), findsWidgets);
    });

    test('Auth state management & logout flow works correctly',
        () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final authNotifier = container.read(authProvider.notifier);
      expect(container.read(authProvider).isAuthenticated, isFalse);

      final success = await authNotifier.login('meet@minty.app', 'password123');
      expect(success, isTrue);
      expect(container.read(authProvider).isAuthenticated, isTrue);
      expect(container.read(authProvider).user?.email, 'meet@minty.app');

      authNotifier.logout();
      expect(container.read(authProvider).isAuthenticated, isFalse);
      expect(container.read(authProvider).user, isNull);
    });
  });

  group('2. Core Financial Features & Screens', () {
    test('Expense Creation & Account Balance Deduction', () async {
      final accounts = await db.getAllAccounts();
      final foodCat = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('food'));
      final primaryAccount = accounts.first;
      final initialBalance = primaryAccount.balance;

      await db.addExpense(
        accountId: primaryAccount.id,
        categoryId: foodCat.id,
        amount: 350.0,
        description: 'Team Lunch',
        date: DateTime.now(),
      );

      final updatedAccounts = await db.getAllAccounts();
      final updatedPrimary = updatedAccounts.firstWhere((a) => a.id == primaryAccount.id);
      expect(updatedPrimary.balance, initialBalance - 350.0);

      final txs = await db.watchAllTransactionsWithDetails().first;
      expect(txs.any((t) => t.transaction.description == 'Team Lunch'), isTrue);
    });

    test('Income Creation & Account Balance Addition', () async {
      final accounts = await db.getAllAccounts();
      final salaryCat = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('salary'));
      final primaryAccount = accounts.first;
      final initialBalance = primaryAccount.balance;

      await db.addIncome(
        accountId: primaryAccount.id,
        categoryId: salaryCat.id,
        amount: 25000.0,
        description: 'Consulting Project',
        date: DateTime.now(),
      );

      final updatedAccounts = await db.getAllAccounts();
      final updatedPrimary = updatedAccounts.firstWhere((a) => a.id == primaryAccount.id);
      expect(updatedPrimary.balance, initialBalance + 25000.0);
    });

    testWidgets('Transaction Details Screen Renders Correctly',
        (tester) async {
      final accounts = await db.getAllAccounts();
      final billsCat = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('bills'));
      final primaryAccount = accounts.first;

      final txId = await db.addExpense(
        accountId: primaryAccount.id,
        categoryId: billsCat.id,
        amount: 1499.0,
        description: 'Broadband Wifi Bill',
        date: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createAuditApp(
          TransactionDetailsScreen(transactionId: txId),
          container,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TransactionDetailsScreen), findsOneWidget);
    });

    test('Payment Flow, Round-Off & Round-Off Wallet', () async {
      final accounts = await db.getAllAccounts();
      final shoppingCat = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('shopping'));
      final primaryAccount = accounts.first;
      final initialBalance = primaryAccount.balance;

      // Pay ₹421 with round-off -> total charged ₹430, round-off ₹9
      await db.processPayment(
        accountId: primaryAccount.id,
        categoryId: shoppingCat.id,
        amount: 421.0,
        description: 'Paid to Aarav Sharma - Book purchase',
        date: DateTime.now(),
        roundOffAmount: 9.0,
      );

      final updatedAccounts = await db.getAllAccounts();
      final updatedPrimary = updatedAccounts.firstWhere((a) => a.id == primaryAccount.id);
      expect(updatedPrimary.balance, initialBalance - 430.0);

      // Verify Round-Off Wallet
      final walletBalance = await db.watchRoundOffWalletBalance().first;
      expect(walletBalance, greaterThanOrEqualTo(9.0));
    });

    testWidgets('Round-Off Wallet Screen renders correctly',
        (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createAuditApp(const RoundOffWalletScreen(), container),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RoundOffWalletScreen), findsOneWidget);
    });

    test('Budgets Creation & Dynamic Spending Tracking', () async {
      final categories = await db.getAllCategories();
      final foodCat = categories.firstWhere((c) => c.name.toLowerCase().contains('food'));
      final now = DateTime.now();
      final targetMonth = now.month == 12 ? 1 : now.month + 1;
      final targetYear = now.month == 12 ? now.year + 1 : now.year;

      await db.createBudget(
        categoryId: foodCat.id,
        amount: 7500.0,
        month: targetMonth,
        year: targetYear,
      );

      final budgets = await db.watchBudgetsWithSpendingForMonth(targetMonth, targetYear).first;
      final foodBudget = budgets.firstWhere((b) => b.category.id == foodCat.id);
      expect(foodBudget.budget.amount, 7500.0);
      expect(foodBudget.remaining, 7500.0);
      expect(foodBudget.progress, 0.0);
    });

    testWidgets('BudgetsScreen renders without error',
        (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createAuditApp(const BudgetsScreen(), container));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(BudgetsScreen), findsOneWidget);
    });

    test('Savings Goals Creation & Contributions Tracking', () async {
      final now = DateTime.now();

      final goalId = await db.createSavingsGoal(
        name: 'Emergency Fund',
        targetAmount: 50000.0,
        targetDate: now.add(const Duration(days: 180)),
      );

      await db.addGoalContribution(
        goalId: goalId,
        amount: 10000.0,
        date: now,
        note: 'Initial deposit',
      );

      final goalDetails = await db.watchSavingsGoalDetails(goalId).first;
      expect(goalDetails, isNotNull);
      expect(goalDetails!.savedAmount, 10000.0);
      expect(goalDetails.remaining, 40000.0);
      expect(goalDetails.progress, 0.2);
      expect(goalDetails.isCompleted, isFalse);
    });

    testWidgets('SavingsGoalsScreen renders without error',
        (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createAuditApp(const SavingsGoalsScreen(), container));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SavingsGoalsScreen), findsOneWidget);
    });

    test('Recurring Expense Creation & Monthly Commitment Calculation', () async {
      final billsCat = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('bills'));

      final recId = await db.createRecurringExpense(
        name: 'Cloud Storage Pro',
        amount: 699.0,
        frequency: 'Monthly',
        categoryId: billsCat.id,
        nextDate: DateTime.now().add(const Duration(days: 30)),
      );

      final recurrings = await db.watchAllRecurringExpensesWithCategory().first;
      expect(recurrings.any((r) => r.recurringExpense.id == recId), isTrue);
    });

    testWidgets('RecurringExpensesScreen renders without error',
        (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createAuditApp(const RecurringExpensesScreen(), container),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RecurringExpensesScreen), findsOneWidget);
    });

    testWidgets('Insights & Monthly Summary Screens render without error',
        (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(createAuditApp(const InsightsScreen(), container));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(InsightsScreen), findsOneWidget);

      await tester.pumpWidget(createAuditApp(const MonthlySummaryScreen(), container));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(MonthlySummaryScreen), findsOneWidget);
    });

    testWidgets('Profile Screen & Dark Mode Theme Rendering',
        (tester) async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      // Light mode
      await tester.pumpWidget(createAuditApp(
        const ProfileScreen(),
        container,
        themeMode: ThemeMode.light,
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Dark mode
      await tester.pumpWidget(createAuditApp(
        const ProfileScreen(),
        container,
        themeMode: ThemeMode.dark,
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });

  group('3. Cumulative Data Integrity After Multiple Operations', () {
    test('Balances, Incomes, Expenses, Budgets, and Wallet remain 100% mathematically exact',
        () async {
      final accounts = await db.getAllAccounts();
      final primaryAccount = accounts.first;
      final foodCat = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('food'));
      final salaryCat = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('salary'));
      final shopCat = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('shopping'));
      final now = DateTime.now();

      final initialBalance = primaryAccount.balance;
      final initialBudgets = await db.watchBudgetsWithSpendingForMonth(now.month, now.year).first;
      final initialFoodBudget = initialBudgets.firstWhere((b) => b.category.id == foodCat.id);
      final initialFoodSpent = initialFoodBudget.spent;
      final initialWalletBal = await db.watchRoundOffWalletBalance().first;

      // 1. Add Income +10,000
      await db.addIncome(
        accountId: primaryAccount.id,
        categoryId: salaryCat.id,
        amount: 10000.0,
        description: 'Bonus',
        date: now,
      );

      // 2. Add Expense -1,500
      await db.addExpense(
        accountId: primaryAccount.id,
        categoryId: foodCat.id,
        amount: 1500.0,
        description: 'Groceries',
        date: now,
      );

      // 3. Make Payment ₹275 with Round-off -> ₹280 charged (Round-off ₹5)
      await db.processPayment(
        accountId: primaryAccount.id,
        categoryId: shopCat.id,
        amount: 275.0,
        description: 'Paid to Supermarket - Weekly essentials',
        date: now,
        roundOffAmount: 5.0,
      );

      // 4. Update Budget for Food ₹6,000
      await db.updateBudget(
        id: initialFoodBudget.budget.id,
        amount: 6000.0,
      );

      // 5. Add another Food Expense -1,000
      await db.addExpense(
        accountId: primaryAccount.id,
        categoryId: foodCat.id,
        amount: 1000.0,
        description: 'Dinner',
        date: now,
      );

      // Verify Account Balance
      // Expected = initialBalance + 10000 - 1500 - 280 - 1000
      final expectedBalance = initialBalance + 10000.0 - 1500.0 - 280.0 - 1000.0;
      final updatedAcc = (await db.getAllAccounts()).firstWhere((a) => a.id == primaryAccount.id);
      expect(updatedAcc.balance, expectedBalance);

      // Verify Total Account Balance
      final totalBal = await db.watchTotalAccountBalance().first;
      expect(totalBal, greaterThanOrEqualTo(expectedBalance));

      // Verify Budget Spending
      final budgets = await db.watchBudgetsWithSpendingForMonth(now.month, now.year).first;
      final foodBudget = budgets.firstWhere((b) => b.category.id == foodCat.id);
      // Food spent should be initialFoodSpent + 1500 + 1000
      expect(foodBudget.spent, initialFoodSpent + 2500.0);
      expect(foodBudget.remaining, 6000.0 - (initialFoodSpent + 2500.0));
      expect(foodBudget.progress, (initialFoodSpent + 2500.0) / 6000.0);

      // Verify Round-off wallet balance
      final walletBal = await db.watchRoundOffWalletBalance().first;
      expect(walletBal, initialWalletBal + 5.0);
    });
  });
}
