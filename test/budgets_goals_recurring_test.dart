import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/database_providers.dart';
import 'package:minty/screens/budgets_screen.dart';
import 'package:minty/screens/goal_details_screen.dart';
import 'package:minty/screens/recurring_expenses_screen.dart';
import 'package:minty/screens/savings_goals_screen.dart';
import 'package:minty/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget(Widget child, ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('Budgets Database & Logic Tests', () {
    test('Budgets calculate spent dynamically from transactions and compute remaining',
        () async {
      final now = DateTime.now();

      // Fetch categories
      final categories = await db.watchAllCategories().first;
      final foodCat = categories.firstWhere((c) => c.name.contains('Food'));
      final accounts = await db.watchAllAccounts().first;

      // Create a test budget of ₹10,000 for food
      final budgetId = await db.createBudget(
        categoryId: foodCat.id,
        amount: 10000.0,
        month: now.month,
        year: now.year,
      );
      expect(budgetId, isPositive);

      // Add expense transaction of ₹7,500
      await db.addExpense(
        accountId: accounts.first.id,
        categoryId: foodCat.id,
        amount: 7500.0,
        description: 'Dinner at restaurant',
        date: now,
      );

      final budgetsWithSpending =
          await db.watchBudgetsWithSpendingForMonth(now.month, now.year).first;
      final foodBudget = budgetsWithSpending
          .firstWhere((b) => b.category.id == foodCat.id);

      // Remaining must be ₹10,000 - ₹7,500 = ₹2,500 (or including any seed transactions)
      expect(foodBudget.spent, greaterThanOrEqualTo(7500.0));
      expect(foodBudget.remaining, equals(foodBudget.budget.amount - foodBudget.spent));
      expect(foodBudget.progress, equals(foodBudget.spent / foodBudget.budget.amount));
    });

    test('Budget warning states (approaching >= 80% and exceeded >= 100%)', () {
      final category = Category(id: 1, name: 'Dining', type: 'expense', icon: 'local_cafe_outlined');

      // Under limit (< 80%)
      final b1 = BudgetWithCategoryAndSpending(
        budget: Budget(id: 1, categoryId: 1, amount: 10000, month: 9, year: 2026),
        category: category,
        spent: 5000,
      );
      expect(b1.progress, 0.5);
      expect(b1.remaining, 5000.0);
      expect(b1.isApproaching, isFalse);
      expect(b1.isExceeded, isFalse);

      // Approaching limit (85%)
      final b2 = BudgetWithCategoryAndSpending(
        budget: Budget(id: 2, categoryId: 1, amount: 10000, month: 9, year: 2026),
        category: category,
        spent: 8500,
      );
      expect(b2.progress, 0.85);
      expect(b2.remaining, 1500.0);
      expect(b2.isApproaching, isTrue);
      expect(b2.isExceeded, isFalse);

      // Exceeded limit (110%)
      final b3 = BudgetWithCategoryAndSpending(
        budget: Budget(id: 3, categoryId: 1, amount: 10000, month: 9, year: 2026),
        category: category,
        spent: 11000,
      );
      expect(b3.progress, 1.1);
      expect(b3.remaining, -1000.0);
      expect(b3.isApproaching, isFalse);
      expect(b3.isExceeded, isTrue);
    });

    test('Budget CRUD operations (create, update, delete)', () async {
      final now = DateTime.now();
      final categories = await db.watchAllCategories().first;
      final rentCat = categories.firstWhere((c) => c.name.contains('Rent'));

      // Create
      final newId = await db.createBudget(
        categoryId: rentCat.id,
        amount: 20000.0,
        month: now.month,
        year: now.year,
      );

      // Update
      final updated = await db.updateBudget(id: newId, amount: 22000.0);
      expect(updated, isTrue);

      // Delete
      final deletedCount = await db.deleteBudget(newId);
      expect(deletedCount, 1);
    });
  });

  group('Savings Goals Database & Logic Tests', () {
    test('Savings Goals calculate savedAmount from SUM(goalContributions)', () async {
      final now = DateTime.now();

      // Create a goal
      final goalId = await db.createSavingsGoal(
        name: 'Japan Vacation',
        targetAmount: 150000.0,
        targetDate: now.add(const Duration(days: 300)),
      );

      // Add contributions
      await db.addGoalContribution(
        goalId: goalId,
        amount: 30000.0,
        date: now.subtract(const Duration(days: 10)),
        note: 'Initial deposit',
      );
      await db.addGoalContribution(
        goalId: goalId,
        amount: 20000.0,
        date: now.subtract(const Duration(days: 2)),
        note: 'Freelance UI bonus',
      );

      final goals = await db.watchSavingsGoalsWithDetails().first;
      final japanGoal = goals.firstWhere((g) => g.goal.id == goalId);

      expect(japanGoal.savedAmount, 50000.0);
      expect(japanGoal.remaining, 100000.0);
      expect(japanGoal.progress, closeTo(0.333, 0.01));
      expect(japanGoal.isCompleted, isFalse);
      expect(japanGoal.contributions.length, 2);

      // Delete one contribution
      final firstContrib = japanGoal.contributions.first;
      await db.deleteGoalContribution(firstContrib.id);

      final updatedGoal = await db.watchSavingsGoalDetails(goalId).first;
      expect(updatedGoal!.savedAmount, 30000.0);
      expect(updatedGoal.contributions.length, 1);
    });

    test('Deleting savings goal deletes associated goal contributions', () async {
      final now = DateTime.now();
      final goalId = await db.createSavingsGoal(
        name: 'Emergency Fund 2',
        targetAmount: 50000.0,
        targetDate: now.add(const Duration(days: 180)),
      );

      await db.addGoalContribution(
        goalId: goalId,
        amount: 15000.0,
        date: now,
      );

      await db.deleteSavingsGoal(goalId);

      final goals = await db.watchAllSavingsGoals().first;
      expect(goals.any((g) => g.id == goalId), isFalse);

      final contribs = await db.watchContributionsForGoal(goalId).first;
      expect(contribs, isEmpty);
    });
  });

  group('Recurring Expenses Database & Logic Tests', () {
    test('Recurring expenses monthlyEquivalent normalization', () {
      final cat = Category(id: 1, name: 'Bills', type: 'expense', icon: 'receipt_long_outlined');

      final monthly = RecurringExpenseWithCategory(
        recurringExpense: RecurringExpense(
          id: 1,
          name: 'Netflix',
          amount: 649.0,
          categoryId: 1,
          frequency: 'monthly',
          nextDate: DateTime.now(),
          active: true,
        ),
        category: cat,
      );
      expect(monthly.monthlyEquivalent, 649.0);

      final weekly = RecurringExpenseWithCategory(
        recurringExpense: RecurringExpense(
          id: 2,
          name: 'Groceries delivery',
          amount: 1000.0,
          categoryId: 1,
          frequency: 'weekly',
          nextDate: DateTime.now(),
          active: true,
        ),
        category: cat,
      );
      expect(weekly.monthlyEquivalent, closeTo(4330.0, 1.0));

      final yearly = RecurringExpenseWithCategory(
        recurringExpense: RecurringExpense(
          id: 3,
          name: 'Amazon Prime',
          amount: 1499.0,
          categoryId: 1,
          frequency: 'yearly',
          nextDate: DateTime.now(),
          active: true,
        ),
        category: cat,
      );
      expect(yearly.monthlyEquivalent, closeTo(124.91, 0.1));
    });

    test('payRecurringExpenseNow creates transaction, deducts balance, and advances date',
        () async {
      final accounts = await db.watchAllAccounts().first;
      final acc = accounts.first;
      final initialBalance = acc.balance;

      final recurringList =
          await db.watchAllRecurringExpensesWithCategory().first;
      final netflix = recurringList
          .firstWhere((r) => r.recurringExpense.name.contains('Netflix'));

      final oldNextDate = netflix.recurringExpense.nextDate;

      await db.payRecurringExpenseNow(
        recurring: netflix.recurringExpense,
        accountId: acc.id,
      );

      // Check account balance deducted
      final updatedAccounts = await db.watchAllAccounts().first;
      final updatedAcc = updatedAccounts.firstWhere((a) => a.id == acc.id);
      expect(updatedAcc.balance, initialBalance - netflix.recurringExpense.amount);

      // Check nextDate advanced
      final updatedRecurring =
          await db.watchAllRecurringExpensesWithCategory().first;
      final updatedNetflix = updatedRecurring
          .firstWhere((r) => r.recurringExpense.id == netflix.recurringExpense.id);
      expect(updatedNetflix.recurringExpense.nextDate.month, (oldNextDate.month % 12) + 1);
    });
  });

  group('UI Widget Tests for Budgets, Goals, and Recurring', () {
    testWidgets('BudgetsScreen renders overview, list, and month selector',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      await tester.pumpWidget(buildTestableWidget(const BudgetsScreen(), container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Monthly Budgets'), findsOneWidget);
      expect(find.text('MONTHLY BUDGET'), findsOneWidget);
      expect(find.text('Category Budgets'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('SavingsGoalsScreen renders total saved and goals list',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      await tester.pumpWidget(buildTestableWidget(const SavingsGoalsScreen(), container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Savings Goals'), findsOneWidget);
      expect(find.text('TOTAL SAVED'), findsOneWidget);
      expect(find.text('Your Goals'), findsOneWidget);
      expect(find.text('MacBook Air M3'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('GoalDetailsScreen renders details and contributions',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      final goals = await (db.select(db.savingsGoals)..limit(1)).get();
      final goal = goals.first;

      await tester.pumpWidget(buildTestableWidget(GoalDetailsScreen(goalId: goal.id), container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Goal Details'), findsOneWidget);
      expect(find.text(goal.name), findsOneWidget);
      expect(find.text('Contribution History'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('RecurringExpensesScreen renders hero total and subscriptions list',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );

      await tester.pumpWidget(buildTestableWidget(const RecurringExpensesScreen(), container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Recurring Expenses'), findsOneWidget);
      expect(find.text('TOTAL RECURRING / MONTH'), findsOneWidget);
      expect(find.text('Subscriptions & Bills'), findsOneWidget);
      expect(find.textContaining('Netflix'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
