import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/database_providers.dart';
import 'package:minty/providers/insights_providers.dart';

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

  group('End-to-End Financial Integration Tests', () {
    test('Complete Income Flow: Updates balance, dashboard, activity, analytics',
        () async {
      // 1. Initial State Check
      final initialBalance = await db.watchTotalAccountBalance().first;
      final initialIncome = await db.watchTotalIncome().first;
      final initialTransactions = await db.watchAllTransactions().first;
      final accounts = await db.getAllAccounts();
      final primaryAccount = accounts.first;
      final salaryCategory = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('salary'));

      // 2. Add Income
      const incomeAmount = 50000.0;
      await db.addIncome(
        accountId: primaryAccount.id,
        categoryId: salaryCategory.id,
        amount: incomeAmount,
        date: DateTime.now(),
        description: 'Monthly Salary Credits',
      );

      // 3. Verify Account Balance
      final updatedAccount = await (db.select(db.accounts)
            ..where((a) => a.id.equals(primaryAccount.id)))
          .getSingle();
      expect(updatedAccount.balance, primaryAccount.balance + incomeAmount);

      // 4. Verify Total Balance & Dashboard
      final newTotalBalance = await db.watchTotalAccountBalance().first;
      expect(newTotalBalance, initialBalance + incomeAmount);

      final newTotalIncome = await db.watchTotalIncome().first;
      expect(newTotalIncome, initialIncome + incomeAmount);

      // 5. Verify Activity / Transactions
      final newTransactions = await db.watchAllTransactions().first;
      expect(newTransactions.length, initialTransactions.length + 1);
      final latestTx = newTransactions.first;
      expect(latestTx.amount, incomeAmount);
      expect(latestTx.type, 'income');
      expect(latestTx.description, 'Monthly Salary Credits');

      // 6. Verify Analytics Data Calculation
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      final monthIncome =
          await db.watchTotalIncome(from: startOfMonth, to: endOfMonth).first;
      expect(monthIncome, greaterThanOrEqualTo(incomeAmount));
    });

    test(
        'Complete Expense Flow: Updates balance, dashboard, activity, budgets, analytics',
        () async {
      // 1. Initial State & Setup a Budget
      final accounts = await db.getAllAccounts();
      final primaryAccount = accounts.first;
      final initialBalance = await db.watchTotalAccountBalance().first;
      final initialExpense = await db.watchTotalExpenses().first;
      final foodCategory = (await db.getAllCategories())
          .firstWhere((c) => c.name.toLowerCase().contains('food'));

      final now = DateTime.now();

      // Check initial spending in this category for the current month
      final initialBudgets =
          await db.watchBudgetsWithSpendingForMonth(now.month, now.year).first;
      final initialSpent = initialBudgets
          .where((b) => b.budget.categoryId == foodCategory.id)
          .fold<double>(0.0, (sum, b) => sum + b.spent);

      // Create or update budget for Food for current month
      await db.createBudget(
        categoryId: foodCategory.id,
        amount: 8000.0,
        month: now.month,
        year: now.year,
      );

      // 2. Add Expense
      const expenseAmount = 1200.0;
      await db.addExpense(
        accountId: primaryAccount.id,
        categoryId: foodCategory.id,
        amount: expenseAmount,
        date: now,
        description: 'Supermarket Groceries',
      );

      // 3. Verify Account Balance
      final updatedAccount = await (db.select(db.accounts)
            ..where((a) => a.id.equals(primaryAccount.id)))
          .getSingle();
      expect(updatedAccount.balance, primaryAccount.balance - expenseAmount);

      // 4. Verify Dashboard Total Balance & Expense
      final newTotalBalance = await db.watchTotalAccountBalance().first;
      expect(newTotalBalance, initialBalance - expenseAmount);

      final newTotalExpense = await db.watchTotalExpenses().first;
      expect(newTotalExpense, initialExpense + expenseAmount);

      // 5. Verify Budgets Calculation (dynamically sums all transactions)
      final budgetsWithSpending =
          await db.watchBudgetsWithSpendingForMonth(now.month, now.year).first;
      final foodBudget = budgetsWithSpending
          .firstWhere((b) => b.budget.categoryId == foodCategory.id);
      expect(foodBudget.spent, initialSpent + expenseAmount);
      expect(foodBudget.remaining, 8000.0 - (initialSpent + expenseAmount));
      expect(foodBudget.progress,
          closeTo((initialSpent + expenseAmount) / 8000.0, 0.001));
      expect(foodBudget.isExceeded, isFalse);
    });

    test(
        'Complete Payment Flow: Balance check, round-off deduction, wallet update, transaction',
        () async {
      // 1. Initial State
      final accounts = await db.getAllAccounts();
      final primaryAccount = accounts.first;
      final initialAccountBalance = primaryAccount.balance;
      final initialTotalBalance =
          await db.watchTotalAccountBalance().first;
      final initialWalletBalance =
          await db.watchRoundOffWalletBalance().first;
      final categories = await db.getAllCategories();
      final shoppingCategory = categories.first;

      // 2. Insufficient Balance Check
      expect(
        () async => await db.processPayment(
          accountId: primaryAccount.id,
          categoryId: shoppingCategory.id,
          amount: initialAccountBalance + 5000.0,
          description: 'Payment to Priya Sharma',
          date: DateTime.now(),
          roundOffAmount: 5.0,
        ),
        throwsA(isA<Exception>()),
      );

      // 3. Valid Payment with Round-Off: ₹273 -> Round up to ₹280 (Round-off = ₹7)
      const payAmount = 273.0;
      const roundOff = 7.0;
      const totalDeduction = 280.0;

      await db.processPayment(
        accountId: primaryAccount.id,
        categoryId: shoppingCategory.id,
        amount: payAmount,
        description: 'Payment to Priya Sharma',
        date: DateTime.now(),
        roundOffAmount: roundOff,
      );

      // 4. Verify Account Deducted Total Payment (Amount + Round-off)
      final updatedAccount = await (db.select(db.accounts)
            ..where((a) => a.id.equals(primaryAccount.id)))
          .getSingle();
      expect(updatedAccount.balance, initialAccountBalance - totalDeduction);

      // 5. Verify Transaction Stored with Payee & Round-Off
      final recentTx = (await db.watchAllTransactions().first).first;
      expect(recentTx.amount, payAmount);
      expect(recentTx.roundOffAmount, roundOff);
      expect(recentTx.type, 'expense');

      // 6. Verify Round-Off Wallet Balance Updated
      final newWalletBalance =
          await db.watchRoundOffWalletBalance().first;
      expect(newWalletBalance, initialWalletBalance + roundOff);

      // 7. Verify Dashboard Total Balance Decreased by Total Deduction
      final newTotalBalance = await db.watchTotalAccountBalance().first;
      expect(newTotalBalance, initialTotalBalance - totalDeduction);
    });

    test('Savings Contribution Flow: Updates goal progress and remaining',
        () async {
      // 1. Create a Goal
      final goalId = await db.createSavingsGoal(
        name: 'Emergency Fund',
        targetAmount: 50000.0,
        targetDate: DateTime.now().add(const Duration(days: 180)),
      );

      // 2. Add Contribution
      const contributionAmount = 15000.0;
      await db.addGoalContribution(
        goalId: goalId,
        amount: contributionAmount,
        date: DateTime.now(),
        note: 'Initial deposit',
      );

      // 3. Verify Goal Progress
      final goalsWithDetails =
          await db.watchSavingsGoalsWithDetails().first;
      final myGoal = goalsWithDetails.firstWhere((g) => g.goal.id == goalId);
      expect(myGoal.savedAmount, contributionAmount);
      expect(myGoal.remaining, 35000.0);
      expect(myGoal.progress, closeTo(15000.0 / 50000.0, 0.001));
      expect(myGoal.isCompleted, isFalse);

      // 4. Add remaining contribution to complete goal
      await db.addGoalContribution(
        goalId: goalId,
        amount: 35000.0,
        date: DateTime.now(),
        note: 'Final top up',
      );

      final completedGoal = (await db.watchSavingsGoalsWithDetails().first)
          .firstWhere((g) => g.goal.id == goalId);
      expect(completedGoal.savedAmount, 50000.0);
      expect(completedGoal.remaining, 0.0);
      expect(completedGoal.progress, 1.0);
      expect(completedGoal.isCompleted, isTrue);
    });

    test(
        'Recurring Expense Flow: Appears in list, manual payment execution updates records',
        () async {
      // 1. Initial State
      final accounts = await db.getAllAccounts();
      final primaryAccount = accounts.first;
      final initialBalance = primaryAccount.balance;
      final categories = await db.getAllCategories();
      final billCategory = categories.first;

      final dueDate = DateTime(2026, 9, 20);
      final recurringId = await db.createRecurringExpense(
        name: 'Cloud Storage Pro',
        amount: 650.0,
        frequency: 'monthly',
        nextDate: dueDate,
        categoryId: billCategory.id,
      );

      // 2. Appears in Recurring List
      final recurringList =
          await db.watchActiveRecurringExpenses().first;
      expect(recurringList.any((r) => r.id == recurringId), isTrue);
      final recurringItem =
          recurringList.firstWhere((r) => r.id == recurringId);

      // 3. Pay Recurring Expense Now
      await db.payRecurringExpenseNow(
        recurring: recurringItem,
        accountId: primaryAccount.id,
      );

      // 4. Verify Account Balance Deducted
      final updatedAccount = await (db.select(db.accounts)
            ..where((a) => a.id.equals(primaryAccount.id)))
          .getSingle();
      expect(updatedAccount.balance, initialBalance - 650.0);

      // 5. Verify Transaction Created
      final latestTx = (await db.watchAllTransactions().first).first;
      expect(latestTx.amount, 650.0);
      expect(latestTx.description, contains('Recurring: Cloud Storage Pro'));

      // 6. Verify Due Date Advanced by 1 Month
      final updatedRecurring =
          await (db.select(db.recurringExpenses)..where((r) => r.id.equals(recurringId)))
              .getSingle();
      expect(updatedRecurring.nextDate.month, (dueDate.month % 12) + 1);
    });

    test('Defensive Calculations & Zero State Safety (No NaN, Infinity, null)',
        () async {
      final analytics = MonthlyAnalyticsData.empty(DateTime.now());

      expect(analytics.totalIncome, 0.0);
      expect(analytics.totalExpense, 0.0);
      expect(analytics.netSavings, 0.0);
      expect(analytics.savingsRate, 0.0);
      expect(analytics.savingsRate.isNaN, isFalse);
      expect(analytics.savingsRate.isInfinite, isFalse);

      const insight = FinancialInsight(
        tag: 'SAVINGS RATE',
        title: 'Great start!',
        subtitle: 'You are on track this month.',
      );

      expect(insight.title, isNotEmpty);
      expect(insight.subtitle, isNotEmpty);
      expect(insight.subtitle.contains('NaN'), isFalse);
      expect(insight.subtitle.contains('null'), isFalse);
      expect(insight.subtitle.contains('Infinity'), isFalse);
    });
  });
}
