import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory database for testing
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Minty Database Tests', () {
    test('Database schema initializes and seeds correctly', () async {
      // 1. Verify User table
      final user = await db.getCurrentUser();
      expect(user, isNotNull);
      expect(user?.name, 'Meet Alshi');
      expect(user?.email, 'meet@minty.app');

      // 2. Verify Accounts table
      final accounts = await db.getAllAccounts();
      expect(accounts.length, greaterThanOrEqualTo(4));
      expect(accounts.any((a) => a.name.contains('HDFC')), isTrue);

      // 3. Verify Categories table
      final categories = await db.getAllCategories();
      expect(categories.length, greaterThanOrEqualTo(10));
      expect(categories.any((c) => c.name == 'Food & Drink'), isTrue);
      expect(categories.any((c) => c.type == 'income'), isTrue);
      expect(categories.any((c) => c.type == 'expense'), isTrue);

      // 4. Verify Transactions table
      final transactions = await db.watchAllTransactions().first;
      expect(transactions.length, greaterThanOrEqualTo(10));

      // 5. Verify Budgets table
      final now = DateTime.now();
      final budgets = await db.watchBudgetsForMonth(now.month, now.year).first;
      expect(budgets.isNotEmpty, isTrue);

      // 6. Verify SavingsGoals table
      final goals = await db.watchAllSavingsGoals().first;
      expect(goals.length, greaterThanOrEqualTo(3));
      expect(goals.any((g) => g.name == 'MacBook Air M3'), isTrue);

      // 7. Verify GoalContributions table
      final macbookGoal = goals.firstWhere((g) => g.name == 'MacBook Air M3');
      final contributions =
          await db.watchContributionsForGoal(macbookGoal.id).first;
      expect(contributions.length, 3);
      final macbookSaved =
          await db.watchGoalSavedAmount(macbookGoal.id).first;
      expect(macbookSaved, 58000.0); // 25000 + 18000 + 15000

      // 8. Verify RecurringExpenses table
      final recurring = await db.watchActiveRecurringExpenses().first;
      expect(recurring.length, greaterThanOrEqualTo(5));

      // 9. Verify Contacts table
      final contacts = await db.watchAllContacts().first;
      expect(contacts.length, greaterThanOrEqualTo(5));
      expect(contacts.any((c) => c.name == 'Rohan Sharma'), isTrue);
    });

    test('Round-Off Wallet balance is calculated dynamically via SUM(roundOffAmount)',
        () async {
      // Seeded transactions (nearest ₹10 round-up rule):
      // Starbucks (5) + Blinkit (5) + Swiggy (8) + Uber (8) + Cult.fit (1) + Jio (9) + Zara (6) + BookMyShow (5) = 47.0
      final roundOffBalance = await db.watchRoundOffWalletBalance().first;
      expect(roundOffBalance, 47.0);

      // Add another transaction with round-off: Payment = ₹990, round-off = ₹10
      final accounts = await db.getAllAccounts();
      final categories = await db.getAllCategories();
      final foodCategory = categories.firstWhere((c) => c.type == 'expense');

      await db.addExpense(
        accountId: accounts.first.id,
        categoryId: foodCategory.id,
        amount: 990.0,
        description: 'Dinner Party',
        date: DateTime.now(),
        roundOffAmount: 10.0,
      );

      final updatedRoundOffBalance =
          await db.watchRoundOffWalletBalance().first;
      expect(updatedRoundOffBalance, 57.0); // 47 + 10 = 57.0
    });

    test('Adding Expense correctly updates Account balance', () async {
      final accounts = await db.getAllAccounts();
      final primaryAccount = accounts.first;
      final initialBalance = primaryAccount.balance;

      final categories = await db.getAllCategories();
      final foodCategory = categories.firstWhere((c) => c.name == 'Food & Drink');

      final expenseId = await db.addExpense(
        accountId: primaryAccount.id,
        categoryId: foodCategory.id,
        amount: 500.0,
        description: 'Team Lunch',
        date: DateTime.now(),
        roundOffAmount: 10.0,
      );

      expect(expenseId, isPositive);

      final updatedAccounts = await db.getAllAccounts();
      final updatedPrimary =
          updatedAccounts.firstWhere((a) => a.id == primaryAccount.id);

      // Account balance = initial - (amount + roundOffAmount) = initial - 510
      expect(updatedPrimary.balance, initialBalance - 510.0);
    });

    test('Adding Income correctly updates Account balance', () async {
      final accounts = await db.getAllAccounts();
      final primaryAccount = accounts.first;
      final initialBalance = primaryAccount.balance;

      final categories = await db.getAllCategories();
      final salaryCategory =
          categories.firstWhere((c) => c.name == 'Salary');

      final incomeId = await db.addIncome(
        accountId: primaryAccount.id,
        categoryId: salaryCategory.id,
        amount: 15000.0,
        description: 'Consulting gig',
        date: DateTime.now(),
      );

      expect(incomeId, isPositive);

      final updatedAccounts = await db.getAllAccounts();
      final updatedPrimary =
          updatedAccounts.firstWhere((a) => a.id == primaryAccount.id);

      // Account balance = initial + amount = initial + 15000
      expect(updatedPrimary.balance, initialBalance + 15000.0);
    });

    test('Deleting Transaction correctly reverses Account balance', () async {
      final accounts = await db.getAllAccounts();
      final primaryAccount = accounts.first;
      final initialBalance = primaryAccount.balance;

      final categories = await db.getAllCategories();
      final foodCategory = categories.firstWhere((c) => c.name == 'Food & Drink');

      // Add expense
      final expenseId = await db.addExpense(
        accountId: primaryAccount.id,
        categoryId: foodCategory.id,
        amount: 400.0,
        description: 'Snacks',
        date: DateTime.now(),
        roundOffAmount: 15.0,
      );

      var updatedAccounts = await db.getAllAccounts();
      var acc = updatedAccounts.firstWhere((a) => a.id == primaryAccount.id);
      expect(acc.balance, initialBalance - 415.0);

      // Delete expense
      await db.deleteTransaction(expenseId);

      updatedAccounts = await db.getAllAccounts();
      acc = updatedAccounts.firstWhere((a) => a.id == primaryAccount.id);
      // Balance reversed back
      expect(acc.balance, initialBalance);
    });

    test('watchAllTransactionsWithDetails supports search and filter', () async {
      final all = await db.watchAllTransactionsWithDetails().first;
      expect(all.length, greaterThanOrEqualTo(10));

      final searchResults = await db
          .watchAllTransactionsWithDetails(searchQuery: 'Starbucks')
          .first;
      expect(searchResults.length, 1);
      expect(searchResults.first.transaction.description, 'Starbucks Coffee');

      final expensesOnly = await db
          .watchAllTransactionsWithDetails(typeFilter: 'expense')
          .first;
      expect(expensesOnly.every((t) => t.transaction.type == 'expense'), isTrue);

      final roundOffOnly = await db
          .watchAllTransactionsWithDetails(roundOffOnly: true)
          .first;
      expect(roundOffOnly.every((t) => t.transaction.roundOffAmount > 0), isTrue);
    });

    test('Financial totals are dynamically calculated from records', () async {
      final totalIncome = await db.watchTotalIncome().first;
      expect(totalIncome, 83500.0); // 65000 + 18500

      final totalSavings = await db.watchTotalSavings().first;
      expect(totalSavings, 98000.0); // 58000 (Macbook) + 30000 (Emergency) + 10000 (Goa)
    });
  });
}
