import 'package:drift/drift.dart';
import 'connection/connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

class TransactionWithDetails {
  final Transaction transaction;
  final Category category;
  final Account account;

  const TransactionWithDetails({
    required this.transaction,
    required this.category,
    required this.account,
  });
}

class BudgetWithCategoryAndSpending {
  final Budget budget;
  final Category category;
  final double spent;

  const BudgetWithCategoryAndSpending({
    required this.budget,
    required this.category,
    required this.spent,
  });

  double get remaining => budget.amount - spent;
  double get progress => budget.amount > 0 ? (spent / budget.amount) : 0.0;
  bool get isApproaching => progress >= 0.80 && progress < 1.0;
  bool get isExceeded => progress >= 1.0;
}

class SavingsGoalWithDetails {
  final SavingsGoal goal;
  final double savedAmount;
  final List<GoalContribution> contributions;

  const SavingsGoalWithDetails({
    required this.goal,
    required this.savedAmount,
    this.contributions = const [],
  });

  double get remaining =>
      (goal.targetAmount - savedAmount) > 0 ? (goal.targetAmount - savedAmount) : 0.0;
  double get progress =>
      goal.targetAmount > 0 ? (savedAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => savedAmount >= goal.targetAmount;

  int get daysRemaining {
    final diff = goal.targetDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  int get monthsRemaining {
    final now = DateTime.now();
    final months = (goal.targetDate.year - now.year) * 12 +
        (goal.targetDate.month - now.month);
    return months > 0 ? months : 0;
  }
}

class RecurringExpenseWithCategory {
  final RecurringExpense recurringExpense;
  final Category category;

  const RecurringExpenseWithCategory({
    required this.recurringExpense,
    required this.category,
  });

  double get monthlyEquivalent {
    switch (recurringExpense.frequency.toLowerCase()) {
      case 'daily':
        return recurringExpense.amount * 30;
      case 'weekly':
        return recurringExpense.amount * 4.33;
      case 'yearly':
        return recurringExpense.amount / 12;
      case 'monthly':
      default:
        return recurringExpense.amount;
    }
  }
}

@DriftDatabase(
  tables: [
    Users,
    Accounts,
    Categories,
    Transactions,
    Budgets,
    SavingsGoals,
    GoalContributions,
    RecurringExpenses,
    Contacts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await seedDatabase();
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ==========================================
  // SEED DATA INITIALIZER
  // ==========================================
  Future<void> seedDatabase() async {
    final existingUsers = await (select(users)..limit(1)).get();
    if (existingUsers.isNotEmpty) {
      return;
    }

    // 1. Seed User
    await into(users).insert(
      UsersCompanion.insert(
        name: 'Meet Alshi',
        email: 'meet@minty.app',
        password: const Value('password123'),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    // 2. Seed Accounts
    final hdfcId = await into(accounts).insert(
      AccountsCompanion.insert(
        name: 'HDFC Bank (Primary)',
        type: 'Savings',
        balance: 38500.0,
      ),
    );
    final iciciId = await into(accounts).insert(
      AccountsCompanion.insert(
        name: 'ICICI Salary Account',
        type: 'Salary',
        balance: 25000.0,
      ),
    );
    await into(accounts).insert(
      AccountsCompanion.insert(
        name: 'Cash Wallet',
        type: 'Cash',
        balance: 2500.0,
      ),
    );
    final paytmId = await into(accounts).insert(
      AccountsCompanion.insert(
        name: 'Paytm / UPI Wallet',
        type: 'Wallet',
        balance: 1850.0,
      ),
    );

    // 3. Seed Categories
    // Incomes
    final salaryCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Salary',
        type: 'income',
        icon: 'payments_rounded',
      ),
    );
    final freelanceCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Freelance',
        type: 'income',
        icon: 'work_outline_rounded',
      ),
    );
    await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Investments',
        type: 'income',
        icon: 'trending_up_rounded',
      ),
    );
    await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Gifts & Refunds',
        type: 'income',
        icon: 'card_giftcard_rounded',
      ),
    );

    // Expenses
    final foodCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Food & Drink',
        type: 'expense',
        icon: 'local_cafe_outlined',
      ),
    );
    final groceriesCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Groceries & Daily Needs',
        type: 'expense',
        icon: 'shopping_bag_outlined',
      ),
    );
    final rentCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Rent & Housing',
        type: 'expense',
        icon: 'home_outlined',
      ),
    );
    final billsCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Bills & Utilities',
        type: 'expense',
        icon: 'receipt_long_outlined',
      ),
    );
    final subsCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Entertainment & Subscriptions',
        type: 'expense',
        icon: 'movie_outlined',
      ),
    );
    final shoppingCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Shopping & Lifestyle',
        type: 'expense',
        icon: 'shopping_cart_outlined',
      ),
    );
    final travelCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Travel & Commute',
        type: 'expense',
        icon: 'directions_car_outlined',
      ),
    );
    final fitnessCatId = await into(categories).insert(
      CategoriesCompanion.insert(
        name: 'Health & Fitness',
        type: 'expense',
        icon: 'fitness_center_outlined',
      ),
    );

    final now = DateTime.now();

    // 4. Seed Budgets (Current Month & Year)
    await into(budgets).insert(
      BudgetsCompanion.insert(
        categoryId: foodCatId,
        amount: 8000.0,
        month: now.month,
        year: now.year,
      ),
    );
    await into(budgets).insert(
      BudgetsCompanion.insert(
        categoryId: groceriesCatId,
        amount: 6000.0,
        month: now.month,
        year: now.year,
      ),
    );
    await into(budgets).insert(
      BudgetsCompanion.insert(
        categoryId: subsCatId,
        amount: 2500.0,
        month: now.month,
        year: now.year,
      ),
    );
    await into(budgets).insert(
      BudgetsCompanion.insert(
        categoryId: shoppingCatId,
        amount: 5000.0,
        month: now.month,
        year: now.year,
      ),
    );
    await into(budgets).insert(
      BudgetsCompanion.insert(
        categoryId: travelCatId,
        amount: 3000.0,
        month: now.month,
        year: now.year,
      ),
    );

    // 5. Seed Savings Goals & Contributions
    final macbookGoalId = await into(savingsGoals).insert(
      SavingsGoalsCompanion.insert(
        name: 'MacBook Air M3',
        targetAmount: 85000.0,
        targetDate: DateTime(now.year, 12, 31),
      ),
    );
    await into(goalContributions).insert(
      GoalContributionsCompanion.insert(
        goalId: macbookGoalId,
        amount: 25000.0,
        date: now.subtract(const Duration(days: 45)),
        note: const Value('Initial savings allocation'),
      ),
    );
    await into(goalContributions).insert(
      GoalContributionsCompanion.insert(
        goalId: macbookGoalId,
        amount: 18000.0,
        date: now.subtract(const Duration(days: 20)),
        note: const Value('Freelance UI project bonus'),
      ),
    );
    await into(goalContributions).insert(
      GoalContributionsCompanion.insert(
        goalId: macbookGoalId,
        amount: 15000.0,
        date: now.subtract(const Duration(days: 5)),
        note: const Value('Monthly savings deposit'),
      ),
    );

    final emergencyGoalId = await into(savingsGoals).insert(
      SavingsGoalsCompanion.insert(
        name: 'Emergency Fund',
        targetAmount: 100000.0,
        targetDate: DateTime(now.year + 1, 6, 30),
      ),
    );
    await into(goalContributions).insert(
      GoalContributionsCompanion.insert(
        goalId: emergencyGoalId,
        amount: 20000.0,
        date: now.subtract(const Duration(days: 30)),
        note: const Value('Starter fund'),
      ),
    );
    await into(goalContributions).insert(
      GoalContributionsCompanion.insert(
        goalId: emergencyGoalId,
        amount: 10000.0,
        date: now.subtract(const Duration(days: 10)),
        note: const Value('Regular deposit'),
      ),
    );

    final goaGoalId = await into(savingsGoals).insert(
      SavingsGoalsCompanion.insert(
        name: 'Goa Vacation Trip',
        targetAmount: 25000.0,
        targetDate: DateTime(now.year, now.month + 3, 15),
      ),
    );
    await into(goalContributions).insert(
      GoalContributionsCompanion.insert(
        goalId: goaGoalId,
        amount: 10000.0,
        date: now.subtract(const Duration(days: 12)),
        note: const Value('Trip fund allocation'),
      ),
    );

    // 6. Seed Recurring Expenses
    await into(recurringExpenses).insert(
      RecurringExpensesCompanion.insert(
        name: 'Netflix Premium (4K)',
        amount: 649.0,
        categoryId: subsCatId,
        frequency: 'monthly',
        nextDate: DateTime(now.year, now.month, 28),
      ),
    );
    await into(recurringExpenses).insert(
      RecurringExpensesCompanion.insert(
        name: 'Spotify Family Plan',
        amount: 179.0,
        categoryId: subsCatId,
        frequency: 'monthly',
        nextDate: DateTime(now.year, now.month, 22),
      ),
    );
    await into(recurringExpenses).insert(
      RecurringExpensesCompanion.insert(
        name: 'Cult.fit Gym Membership',
        amount: 1499.0,
        categoryId: fitnessCatId,
        frequency: 'monthly',
        nextDate: DateTime(now.year, now.month + 1, 5),
      ),
    );
    await into(recurringExpenses).insert(
      RecurringExpensesCompanion.insert(
        name: 'JioFiber 300Mbps Broadband',
        amount: 999.0,
        categoryId: billsCatId,
        frequency: 'monthly',
        nextDate: DateTime(now.year, now.month, 18),
      ),
    );
    await into(recurringExpenses).insert(
      RecurringExpensesCompanion.insert(
        name: 'Apartment Rent & Maintenance',
        amount: 16500.0,
        categoryId: rentCatId,
        frequency: 'monthly',
        nextDate: DateTime(now.year, now.month + 1, 1),
      ),
    );

    // 7. Seed Contacts (UPI & Quick Pay)
    await into(contacts).insert(
      ContactsCompanion.insert(
        name: 'Rohan Sharma',
        phone: '+91 98201 45892',
        upiId: 'rohan.sharma@okhdfcbank',
        avatar: const Value('R'),
      ),
    );
    await into(contacts).insert(
      ContactsCompanion.insert(
        name: 'Priya Patel',
        phone: '+91 98765 43210',
        upiId: 'priyapatel@okaxis',
        avatar: const Value('P'),
      ),
    );
    await into(contacts).insert(
      ContactsCompanion.insert(
        name: 'Aarav Verma',
        phone: '+91 91234 56789',
        upiId: 'aaravv@paytm',
        avatar: const Value('A'),
      ),
    );
    await into(contacts).insert(
      ContactsCompanion.insert(
        name: 'Sneha Reddy',
        phone: '+91 99887 76655',
        upiId: 'sneha.reddy@icici',
        avatar: const Value('S'),
      ),
    );
    await into(contacts).insert(
      ContactsCompanion.insert(
        name: 'Amit Gupta',
        phone: '+91 97654 32109',
        upiId: 'amitgupta@upi',
        avatar: const Value('A'),
      ),
    );

    // 8. Seed Transactions (with realistic roundOffAmount)
    // Note: roundOffWallet balance = SUM(roundOffAmount)
    // 1) Starbucks Coffee (Today)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: hdfcId,
        categoryId: foodCatId,
        type: 'expense',
        amount: 280.0,
        description: 'Starbucks Coffee',
        date: now.subtract(const Duration(hours: 3)),
        roundOffAmount: const Value(20.0), // Rounded to ₹300, wallet gets ₹20
      ),
    );

    // 2) Freelance UI Payout (Yesterday)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: hdfcId,
        categoryId: freelanceCatId,
        type: 'income',
        amount: 18500.0,
        description: 'Freelance UI Payout',
        date: now.subtract(const Duration(days: 1, hours: 2)),
        roundOffAmount: const Value(0.0),
      ),
    );

    // 3) Blinkit Groceries (2 days ago)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: paytmId,
        categoryId: groceriesCatId,
        type: 'expense',
        amount: 435.0,
        description: 'Blinkit Groceries',
        date: now.subtract(const Duration(days: 2, hours: 4)),
        roundOffAmount: const Value(15.0), // Rounded to ₹450, wallet gets ₹15
      ),
    );

    // 4) Monthly Salary (1st of month)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: iciciId,
        categoryId: salaryCatId,
        type: 'income',
        amount: 65000.0,
        description: 'Monthly Salary Credit',
        date: DateTime(now.year, now.month, 1, 9, 30),
        roundOffAmount: const Value(0.0),
      ),
    );

    // 5) Swiggy Gourmet Dinner (3 days ago)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: hdfcId,
        categoryId: foodCatId,
        type: 'expense',
        amount: 580.0,
        description: 'Swiggy Gourmet Dinner',
        date: now.subtract(const Duration(days: 3, hours: 6)),
        roundOffAmount: const Value(20.0), // Rounded to ₹600, wallet gets ₹20
      ),
    );

    // 6) Uber Ride (4 days ago)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: paytmId,
        categoryId: travelCatId,
        type: 'expense',
        amount: 342.0,
        description: 'Uber ride to Bandra',
        date: now.subtract(const Duration(days: 4, hours: 8)),
        roundOffAmount: const Value(8.0), // Rounded to ₹350, wallet gets ₹8
      ),
    );

    // 7) Cult.fit Monthly (6 days ago)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: hdfcId,
        categoryId: fitnessCatId,
        type: 'expense',
        amount: 1499.0,
        description: 'Cult.fit Monthly Pass',
        date: now.subtract(const Duration(days: 6)),
        roundOffAmount: const Value(1.0), // Rounded to ₹1500, wallet gets ₹1
      ),
    );

    // 8) Jio Fiber Broadband (8 days ago)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: hdfcId,
        categoryId: billsCatId,
        type: 'expense',
        amount: 999.0,
        description: 'Jio Fiber Broadband Bill',
        date: now.subtract(const Duration(days: 8)),
        roundOffAmount: const Value(1.0), // Rounded to ₹1000, wallet gets ₹1
      ),
    );

    // 9) Zara Shopping (10 days ago)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: hdfcId,
        categoryId: shoppingCatId,
        type: 'expense',
        amount: 2190.0,
        description: 'Zara Weekend Shopping',
        date: now.subtract(const Duration(days: 10)),
        roundOffAmount: const Value(10.0), // Rounded to ₹2200, wallet gets ₹10
      ),
    );

    // 10) BookMyShow Tickets (12 days ago)
    await into(transactions).insert(
      TransactionsCompanion.insert(
        accountId: paytmId,
        categoryId: subsCatId,
        type: 'expense',
        amount: 760.0,
        description: 'BookMyShow IMAX Tickets',
        date: now.subtract(const Duration(days: 12)),
        roundOffAmount: const Value(40.0), // Rounded to ₹800, wallet gets ₹40
      ),
    );
  }

  // ==========================================
  // QUERY & HELPER METHODS
  // ==========================================

  // Users
  Stream<User?> watchCurrentUser() =>
      (select(users)..limit(1)).watchSingleOrNull();
  Future<User?> getCurrentUser() =>
      (select(users)..limit(1)).getSingleOrNull();
  Future<User?> getUserByEmail(String email) =>
      (select(users)..where((u) => u.email.equals(email.trim().toLowerCase())))
          .getSingleOrNull();
  Future<User?> authenticateUser(String email, String password) =>
      (select(users)
            ..where((u) =>
                u.email.equals(email.trim().toLowerCase()) &
                u.password.equals(password)))
          .getSingleOrNull();
  Future<User> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final id = await into(users).insert(
      UsersCompanion.insert(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: Value(password),
      ),
    );
    return (select(users)..where((u) => u.id.equals(id))).getSingle();
  }

  // Accounts
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();
  Future<List<Account>> getAllAccounts() => select(accounts).get();
  Future<int> insertAccount(AccountsCompanion account) =>
      into(accounts).insert(account);

  // Categories
  Stream<List<Category>> watchAllCategories() => select(categories).watch();
  Stream<List<Category>> watchCategoriesByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).watch();
  Future<List<Category>> getAllCategories() => select(categories).get();
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);
  Future<bool> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id)))
          .go()
          .then((count) => count > 0);


  // Transactions
  Stream<List<Transaction>> watchAllTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Stream<List<TransactionWithDetails>> watchAllTransactionsWithDetails({
    String? searchQuery,
    int? categoryId,
    String? typeFilter,
    bool roundOffOnly = false,
  }) {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
    ]);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query.where(transactions.description
          .lower()
          .contains(searchQuery.trim().toLowerCase()));
    }

    if (categoryId != null) {
      query.where(transactions.categoryId.equals(categoryId));
    }

    if (typeFilter != null &&
        typeFilter != 'all' &&
        typeFilter.isNotEmpty) {
      query.where(transactions.type.equals(typeFilter));
    }

    if (roundOffOnly) {
      query.where(transactions.roundOffAmount.isBiggerThanValue(0.0));
    }

    query.orderBy([OrderingTerm.desc(transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(transactions),
          category: row.readTable(categories),
          account: row.readTable(accounts),
        );
      }).toList();
    });
  }

  Stream<List<TransactionWithDetails>> watchRecentTransactionsWithDetails(
      {int limit = 5}) {
    final query = (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(transactions),
          category: row.readTable(categories),
          account: row.readTable(accounts),
        );
      }).toList();
    });
  }

  Stream<TransactionWithDetails?> watchTransactionDetails(int id) {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
    ])..where(transactions.id.equals(id));

    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return TransactionWithDetails(
        transaction: row.readTable(transactions),
        category: row.readTable(categories),
        account: row.readTable(accounts),
      );
    });
  }

  Future<int> addExpense({
    required int accountId,
    required int categoryId,
    required double amount,
    required String description,
    required DateTime date,
    double roundOffAmount = 0.0,
  }) async {
    return transaction(() async {
      final account = await (select(accounts)
            ..where((a) => a.id.equals(accountId)))
          .getSingle();
      final updatedBalance = account.balance - (amount + roundOffAmount);
      await (update(accounts)..where((a) => a.id.equals(accountId)))
          .write(AccountsCompanion(balance: Value(updatedBalance)));

      return into(transactions).insert(
        TransactionsCompanion.insert(
          accountId: accountId,
          categoryId: categoryId,
          type: 'expense',
          amount: amount,
          description: description,
          date: date,
          roundOffAmount: Value(roundOffAmount),
        ),
      );
    });
  }

  Future<int> addIncome({
    required int accountId,
    required int categoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    return transaction(() async {
      final account = await (select(accounts)
            ..where((a) => a.id.equals(accountId)))
          .getSingle();
      final updatedBalance = account.balance + amount;
      await (update(accounts)..where((a) => a.id.equals(accountId)))
          .write(AccountsCompanion(balance: Value(updatedBalance)));

      return into(transactions).insert(
        TransactionsCompanion.insert(
          accountId: accountId,
          categoryId: categoryId,
          type: 'income',
          amount: amount,
          description: description,
          date: date,
          roundOffAmount: const Value(0.0),
        ),
      );
    });
  }

  Future<void> deleteTransaction(int transactionId) async {
    return transaction(() async {
      final tx = await (select(transactions)
            ..where((t) => t.id.equals(transactionId)))
          .getSingleOrNull();
      if (tx == null) return;

      final account = await (select(accounts)
            ..where((a) => a.id.equals(tx.accountId)))
          .getSingleOrNull();
      if (account != null) {
        double newBalance = account.balance;
        if (tx.type == 'expense') {
          newBalance += (tx.amount + tx.roundOffAmount);
        } else if (tx.type == 'income') {
          newBalance -= tx.amount;
        }
        await (update(accounts)..where((a) => a.id.equals(account.id)))
            .write(AccountsCompanion(balance: Value(newBalance)));
      }

      await (delete(transactions)..where((t) => t.id.equals(transactionId)))
          .go();
    });
  }

  // ==========================================
  // BUDGETS CRUD & WATCH METHODS
  // ==========================================
  Stream<List<Budget>> watchBudgetsForMonth(int month, int year) =>
      (select(budgets)
            ..where((b) => b.month.equals(month) & b.year.equals(year)))
          .watch();

  Stream<List<BudgetWithCategoryAndSpending>> watchBudgetsWithSpendingForMonth(
      int month, int year) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final query = select(budgets).join([
      innerJoin(categories, categories.id.equalsExp(budgets.categoryId)),
      leftOuterJoin(
        transactions,
        transactions.categoryId.equalsExp(budgets.categoryId) &
            transactions.type.equals('expense') &
            transactions.date.isBiggerOrEqualValue(startOfMonth) &
            transactions.date.isSmallerOrEqualValue(endOfMonth),
      ),
    ]);
    query.where(budgets.month.equals(month) & budgets.year.equals(year));

    return query.watch().map((rows) {
      final map = <int, BudgetWithCategoryAndSpending>{};

      for (final row in rows) {
        final b = row.readTable(budgets);
        final cat = row.readTable(categories);
        final tx = row.readTableOrNull(transactions);

        if (!map.containsKey(b.id)) {
          map[b.id] = BudgetWithCategoryAndSpending(
            budget: b,
            category: cat,
            spent: 0.0,
          );
        }

        if (tx != null) {
          final current = map[b.id]!;
          map[b.id] = BudgetWithCategoryAndSpending(
            budget: current.budget,
            category: current.category,
            spent: current.spent + tx.amount,
          );
        }
      }

      return map.values.toList();
    });
  }

  Future<int> createBudget({
    required int categoryId,
    required double amount,
    required int month,
    required int year,
  }) {
    return into(budgets).insert(
      BudgetsCompanion.insert(
        categoryId: categoryId,
        amount: amount,
        month: month,
        year: year,
      ),
    );
  }

  Future<bool> updateBudget({
    required int id,
    required double amount,
    int? categoryId,
  }) {
    final companion = BudgetsCompanion(
      amount: Value(amount),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
    );
    return (update(budgets)..where((b) => b.id.equals(id)))
        .write(companion)
        .then((rows) => rows > 0);
  }

  Future<int> deleteBudget(int id) {
    return (delete(budgets)..where((b) => b.id.equals(id))).go();
  }

  // ==========================================
  // SAVINGS GOALS & CONTRIBUTIONS CRUD & WATCH
  // ==========================================
  Stream<List<SavingsGoal>> watchAllSavingsGoals() => select(savingsGoals).watch();

  Stream<List<GoalContribution>> watchContributionsForGoal(int goalId) {
    final query = select(goalContributions)
      ..where((g) => g.goalId.equals(goalId))
      ..orderBy([(g) => OrderingTerm.desc(g.date)]);
    return query.watch();
  }

  Stream<List<SavingsGoalWithDetails>> watchSavingsGoalsWithDetails() {
    final query = select(savingsGoals).join([
      leftOuterJoin(
          goalContributions, goalContributions.goalId.equalsExp(savingsGoals.id)),
    ]);
    query.orderBy([OrderingTerm.asc(savingsGoals.targetDate)]);

    return query.watch().map((rows) {
      final map = <int, SavingsGoalWithDetails>{};

      for (final row in rows) {
        final goal = row.readTable(savingsGoals);
        final contrib = row.readTableOrNull(goalContributions);

        if (!map.containsKey(goal.id)) {
          map[goal.id] = SavingsGoalWithDetails(
            goal: goal,
            savedAmount: 0.0,
            contributions: [],
          );
        }

        if (contrib != null) {
          final item = map[goal.id]!;
          item.contributions.add(contrib);
        }
      }

      return map.values.map((item) {
        item.contributions.sort((a, b) => b.date.compareTo(a.date));
        final saved =
            item.contributions.fold<double>(0.0, (sum, c) => sum + c.amount);
        return SavingsGoalWithDetails(
          goal: item.goal,
          savedAmount: saved,
          contributions: item.contributions,
        );
      }).toList();
    });
  }

  Stream<SavingsGoalWithDetails?> watchSavingsGoalDetails(int goalId) {
    final query = select(savingsGoals).join([
      leftOuterJoin(
          goalContributions, goalContributions.goalId.equalsExp(savingsGoals.id)),
    ]);
    query.where(savingsGoals.id.equals(goalId));

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final goal = rows.first.readTable(savingsGoals);
      final contribs = <GoalContribution>[];
      for (final row in rows) {
        final c = row.readTableOrNull(goalContributions);
        if (c != null) {
          contribs.add(c);
        }
      }
      contribs.sort((a, b) => b.date.compareTo(a.date));
      final saved = contribs.fold<double>(0.0, (sum, c) => sum + c.amount);
      return SavingsGoalWithDetails(
        goal: goal,
        savedAmount: saved,
        contributions: contribs,
      );
    });
  }

  Future<int> createSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
  }) {
    return into(savingsGoals).insert(
      SavingsGoalsCompanion.insert(
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
      ),
    );
  }

  Future<bool> updateSavingsGoal({
    required int id,
    required String name,
    required double targetAmount,
    required DateTime targetDate,
  }) {
    return (update(savingsGoals)..where((g) => g.id.equals(id)))
        .write(
          SavingsGoalsCompanion(
            name: Value(name),
            targetAmount: Value(targetAmount),
            targetDate: Value(targetDate),
          ),
        )
        .then((rows) => rows > 0);
  }

  Future<void> deleteSavingsGoal(int goalId) {
    return transaction(() async {
      await (delete(goalContributions)..where((c) => c.goalId.equals(goalId)))
          .go();
      await (delete(savingsGoals)..where((g) => g.id.equals(goalId))).go();
    });
  }

  Future<int> insertGoalContribution(GoalContributionsCompanion contribution) =>
      into(goalContributions).insert(contribution);

  Future<int> addGoalContribution({
    required int goalId,
    required double amount,
    required DateTime date,
    String? note,
  }) {
    return into(goalContributions).insert(
      GoalContributionsCompanion.insert(
        goalId: goalId,
        amount: amount,
        date: date,
        note: note != null && note.isNotEmpty ? Value(note) : const Value(null),
      ),
    );
  }

  Future<int> deleteGoalContribution(int id) {
    return (delete(goalContributions)..where((c) => c.id.equals(id))).go();
  }

  // ==========================================
  // RECURRING EXPENSES CRUD & WATCH METHODS
  // ==========================================
  Stream<List<RecurringExpense>> watchActiveRecurringExpenses() =>
      (select(recurringExpenses)..where((r) => r.active.equals(true))).watch();

  Stream<List<RecurringExpenseWithCategory>>
      watchAllRecurringExpensesWithCategory() {
    final query = select(recurringExpenses).join([
      innerJoin(
          categories, categories.id.equalsExp(recurringExpenses.categoryId)),
    ]);
    query.orderBy([OrderingTerm.asc(recurringExpenses.nextDate)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return RecurringExpenseWithCategory(
          recurringExpense: row.readTable(recurringExpenses),
          category: row.readTable(categories),
        );
      }).toList();
    });
  }

  Future<int> createRecurringExpense({
    required String name,
    required double amount,
    required int categoryId,
    required String frequency,
    required DateTime nextDate,
    bool active = true,
  }) {
    return into(recurringExpenses).insert(
      RecurringExpensesCompanion.insert(
        name: name,
        amount: amount,
        categoryId: categoryId,
        frequency: frequency,
        nextDate: nextDate,
        active: Value(active),
      ),
    );
  }

  Future<bool> updateRecurringExpense({
    required int id,
    required String name,
    required double amount,
    required int categoryId,
    required String frequency,
    required DateTime nextDate,
    required bool active,
  }) {
    return (update(recurringExpenses)..where((r) => r.id.equals(id)))
        .write(
          RecurringExpensesCompanion(
            name: Value(name),
            amount: Value(amount),
            categoryId: Value(categoryId),
            frequency: Value(frequency),
            nextDate: Value(nextDate),
            active: Value(active),
          ),
        )
        .then((rows) => rows > 0);
  }

  Future<bool> toggleRecurringExpenseActive(int id, bool active) {
    return (update(recurringExpenses)..where((r) => r.id.equals(id)))
        .write(RecurringExpensesCompanion(active: Value(active)))
        .then((rows) => rows > 0);
  }

  Future<int> deleteRecurringExpense(int id) {
    return (delete(recurringExpenses)..where((r) => r.id.equals(id))).go();
  }

  Future<int> payRecurringExpenseNow({
    required RecurringExpense recurring,
    required int accountId,
    DateTime? paymentDate,
  }) {
    final payDate = paymentDate ?? DateTime.now();
    return transaction(() async {
      await addExpense(
        accountId: accountId,
        categoryId: recurring.categoryId,
        amount: recurring.amount,
        description: 'Recurring: ${recurring.name}',
        date: payDate,
      );

      DateTime newNextDate;
      switch (recurring.frequency.toLowerCase()) {
        case 'daily':
          newNextDate = recurring.nextDate.add(const Duration(days: 1));
          break;
        case 'weekly':
          newNextDate = recurring.nextDate.add(const Duration(days: 7));
          break;
        case 'yearly':
          newNextDate = DateTime(
            recurring.nextDate.year + 1,
            recurring.nextDate.month,
            recurring.nextDate.day,
          );
          break;
        case 'monthly':
        default:
          newNextDate = DateTime(
            recurring.nextDate.year,
            recurring.nextDate.month + 1,
            recurring.nextDate.day,
          );
          break;
      }

      await (update(recurringExpenses)..where((r) => r.id.equals(recurring.id)))
          .write(RecurringExpensesCompanion(nextDate: Value(newNextDate)));

      return recurring.id;
    });
  }

  // Contacts
  Stream<List<Contact>> watchAllContacts() => select(contacts).watch();
  Future<List<Contact>> getAllContacts() => select(contacts).get();
  Stream<List<Contact>> searchContacts(String query) {
    if (query.trim().isEmpty) return select(contacts).watch();
    final lower = '%${query.trim().toLowerCase()}%';
    return (select(contacts)
          ..where((c) =>
              c.name.lower().like(lower) |
              c.phone.lower().like(lower) |
              c.upiId.lower().like(lower)))
        .watch();
  }

  // Payment Processing (Atomic with balance check & round-off)
  Future<int> processPayment({
    required int accountId,
    required int categoryId,
    required double amount,
    required String description,
    required DateTime date,
    double roundOffAmount = 0.0,
  }) async {
    return transaction(() async {
      final account = await (select(accounts)
            ..where((a) => a.id.equals(accountId)))
          .getSingle();
      final totalDeduction = amount + roundOffAmount;
      if (account.balance < totalDeduction) {
        throw Exception(
            'Insufficient balance in ${account.name}. Available: ₹${account.balance.toStringAsFixed(2)}, Total Required: ₹${totalDeduction.toStringAsFixed(2)}');
      }

      final updatedBalance = account.balance - totalDeduction;
      await (update(accounts)..where((a) => a.id.equals(accountId)))
          .write(AccountsCompanion(balance: Value(updatedBalance)));

      return into(transactions).insert(
        TransactionsCompanion.insert(
          accountId: accountId,
          categoryId: categoryId,
          type: 'expense',
          amount: amount,
          description: description,
          date: date,
          roundOffAmount: Value(roundOffAmount),
        ),
      );
    });
  }

  // Round-off transactions history (where roundOffAmount > 0)
  Stream<List<TransactionWithDetails>> watchRoundOffTransactions(
      {int? limit}) {
    final query = select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
    ])..where(transactions.roundOffAmount.isBiggerThanValue(0.0));

    query.orderBy([OrderingTerm.desc(transactions.date)]);
    if (limit != null) {
      query.limit(limit);
    }

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(transactions),
          category: row.readTable(categories),
          account: row.readTable(accounts),
        );
      }).toList();
    });
  }

  // ==========================================
  // DYNAMIC COMPUTED VALUES (Calculated from records)
  // ==========================================

  // Round-Off Wallet balance: SUM(transactions.roundOffAmount)
  Stream<double> watchRoundOffWalletBalance() {
    final sumRoundOff = transactions.roundOffAmount.sum();
    final query = selectOnly(transactions)..addColumns([sumRoundOff]);
    return query.watchSingle().map((row) => row.read(sumRoundOff) ?? 0.0);
  }

  // Total Income for a given date range or all time
  Stream<double> watchTotalIncome({DateTime? from, DateTime? to}) {
    final sumAmount = transactions.amount.sum();
    final query = selectOnly(transactions)..addColumns([sumAmount]);
    query.where(transactions.type.equals('income'));
    if (from != null) query.where(transactions.date.isBiggerOrEqualValue(from));
    if (to != null) query.where(transactions.date.isSmallerOrEqualValue(to));
    return query.watchSingle().map((row) => row.read(sumAmount) ?? 0.0);
  }

  // Total Expenses for a given date range or all time
  Stream<double> watchTotalExpenses({DateTime? from, DateTime? to}) {
    final sumAmount = transactions.amount.sum();
    final query = selectOnly(transactions)..addColumns([sumAmount]);
    query.where(transactions.type.equals('expense'));
    if (from != null) query.where(transactions.date.isBiggerOrEqualValue(from));
    if (to != null) query.where(transactions.date.isSmallerOrEqualValue(to));
    return query.watchSingle().map((row) => row.read(sumAmount) ?? 0.0);
  }

  // Total Savings Contributed across all goals
  Stream<double> watchTotalSavings() {
    final sumContribution = goalContributions.amount.sum();
    final query = selectOnly(goalContributions)..addColumns([sumContribution]);
    return query.watchSingle().map((row) => row.read(sumContribution) ?? 0.0);
  }

  // Savings for a specific goal
  Stream<double> watchGoalSavedAmount(int goalId) {
    final sumContribution = goalContributions.amount.sum();
    final query = selectOnly(goalContributions)
      ..addColumns([sumContribution])
      ..where(goalContributions.goalId.equals(goalId));
    return query.watchSingle().map((row) => row.read(sumContribution) ?? 0.0);
  }

  // Total Net Balance: Sum of account balances
  Stream<double> watchTotalAccountBalance() {
    final sumBalance = accounts.balance.sum();
    final query = selectOnly(accounts)..addColumns([sumBalance]);
    return query.watchSingle().map((row) => row.read(sumBalance) ?? 0.0);
  }
}
