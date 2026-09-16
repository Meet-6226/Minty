import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';

// Database Singleton Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Current User Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCurrentUser();
});

// Accounts Provider
final accountsProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllAccounts();
});

// Categories Provider
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllCategories();
});

// Categories by Type Provider
final expenseCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCategoriesByType('expense');
});

final incomeCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCategoriesByType('income');
});

// All Transactions Stream Provider (Ordered newest first)
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions();
});

// Recent Transactions with Joined Details (Limit 5)
final recentTransactionsWithDetailsProvider =
    StreamProvider<List<TransactionWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRecentTransactionsWithDetails(limit: 5);
});

// Transaction Filter model
class TransactionFilter {
  final String searchQuery;
  final int? categoryId;
  final String typeFilter; // 'all', 'expense', 'income'
  final bool roundOffOnly;

  const TransactionFilter({
    this.searchQuery = '',
    this.categoryId,
    this.typeFilter = 'all',
    this.roundOffOnly = false,
  });

  TransactionFilter copyWith({
    String? searchQuery,
    int? categoryId,
    bool clearCategory = false,
    String? typeFilter,
    bool? roundOffOnly,
  }) {
    return TransactionFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      typeFilter: typeFilter ?? this.typeFilter,
      roundOffOnly: roundOffOnly ?? this.roundOffOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionFilter &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          categoryId == other.categoryId &&
          typeFilter == other.typeFilter &&
          roundOffOnly == other.roundOffOnly;

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      categoryId.hashCode ^
      typeFilter.hashCode ^
      roundOffOnly.hashCode;
}

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void updateFilter(TransactionFilter Function(TransactionFilter) update) {
    state = update(state);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTypeFilter(String typeFilter, {bool roundOffOnly = false}) {
    state = state.copyWith(typeFilter: typeFilter, roundOffOnly: roundOffOnly);
  }

  void setCategoryId(int? categoryId) {
    state = categoryId == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(categoryId: categoryId);
  }
}

// Active Transaction Filter Provider
final activeTransactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
        TransactionFilterNotifier.new);

// Filtered Transactions Provider
final filteredTransactionsProvider =
    StreamProvider<List<TransactionWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  final filter = ref.watch(activeTransactionFilterProvider);

  return db.watchAllTransactionsWithDetails(
    searchQuery: filter.searchQuery,
    categoryId: filter.categoryId,
    typeFilter: filter.typeFilter,
    roundOffOnly: filter.roundOffOnly,
  );
});

// Single Transaction Details Provider
final transactionDetailsProvider =
    StreamProvider.family<TransactionWithDetails?, int>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.watchTransactionDetails(id);
});

// Budgets Provider for Current Month & Year
// Budget Month/Year Notifier
class BudgetMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime date) {
    state = DateTime(date.year, date.month);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }
}

final selectedBudgetMonthProvider =
    NotifierProvider<BudgetMonthNotifier, DateTime>(BudgetMonthNotifier.new);

// Budgets Provider for Current Month & Year
final currentMonthBudgetsProvider = StreamProvider<List<Budget>>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  return db.watchBudgetsForMonth(now.month, now.year);
});

// Monthly Budgets with Spending & Remaining (calculated dynamically)
final monthlyBudgetsWithSpendingProvider =
    StreamProvider<List<BudgetWithCategoryAndSpending>>((ref) {
  final db = ref.watch(databaseProvider);
  final selectedMonth = ref.watch(selectedBudgetMonthProvider);
  return db.watchBudgetsWithSpendingForMonth(
      selectedMonth.month, selectedMonth.year);
});

// Savings Goals Provider
final savingsGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllSavingsGoals();
});

// Savings Goals with Details Provider (sums contributions dynamically)
final savingsGoalsWithDetailsProvider =
    StreamProvider<List<SavingsGoalWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSavingsGoalsWithDetails();
});

// Goal Contributions Provider (for a specific goal)
final goalContributionsProvider =
    StreamProvider.family<List<GoalContribution>, int>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return db.watchContributionsForGoal(goalId);
});

// Single Savings Goal Details Provider
final singleGoalDetailsProvider =
    StreamProvider.family<SavingsGoalWithDetails?, int>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return db.watchSavingsGoalDetails(goalId);
});

// Goal Saved Amount Provider (calculated dynamically)
final goalSavedAmountProvider =
    StreamProvider.family<double, int>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return db.watchGoalSavedAmount(goalId);
});

// Primary / Featured Savings Goal Provider (e.g. MacBook Air M3)
final primarySavingsGoalProvider = StreamProvider<SavingsGoal?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllSavingsGoals().map((goals) => goals.isNotEmpty ? goals.first : null);
});

final primarySavingsGoalWithDetailsProvider =
    StreamProvider<SavingsGoalWithDetails?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSavingsGoalsWithDetails().map(
      (goals) => goals.isNotEmpty ? goals.first : null);
});

// Active Recurring Expenses Provider
final recurringExpensesProvider = StreamProvider<List<RecurringExpense>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchActiveRecurringExpenses();
});

// Recurring Expenses with Category Provider (all items)
final recurringExpensesWithCategoryProvider =
    StreamProvider<List<RecurringExpenseWithCategory>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllRecurringExpensesWithCategory();
});

// Total Monthly Recurring Expense Provider (Sum of active monthly equivalents)
final totalMonthlyRecurringProvider = Provider<AsyncValue<double>>((ref) {
  final recurringAsync = ref.watch(recurringExpensesWithCategoryProvider);
  return recurringAsync.whenData((list) {
    return list
        .where((item) => item.recurringExpense.active)
        .fold<double>(0.0, (sum, item) => sum + item.monthlyEquivalent);
  });
});

// Contact Search Query Notifier
class ContactSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final contactSearchQueryProvider =
    NotifierProvider<ContactSearchNotifier, String>(ContactSearchNotifier.new);

// Contacts Provider (for Quick Pay / UPI)
final contactsProvider = StreamProvider<List<Contact>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = ref.watch(contactSearchQueryProvider);
  return db.searchContacts(query);
});

// Round-Off Transactions Provider
final roundOffTransactionsProvider =
    StreamProvider<List<TransactionWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRoundOffTransactions();
});

// ==========================================
// COMPUTED / DYNAMIC FINANCIAL METRICS
// (Never stored in DB, calculated on the fly)
// ==========================================

// Round-Off Wallet Balance Provider: SUM(transactions.roundOffAmount)
final roundOffWalletBalanceProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchRoundOffWalletBalance();
});

// Total Bank & Cash Account Balances
final totalAccountBalanceProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTotalAccountBalance();
});

// Current Month Total Income Provider
final currentMonthIncomeProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return db.watchTotalIncome(from: startOfMonth, to: endOfMonth);
});

// Current Month Total Expense Provider
final currentMonthExpenseProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return db.watchTotalExpenses(from: startOfMonth, to: endOfMonth);
});

// Total Savings Across All Goals
final totalSavingsProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTotalSavings();
});

// Net Worth Provider (Accounts + Total Savings + Round-off Wallet)
final netWorthProvider = Provider<AsyncValue<double>>((ref) {
  final accountBalanceAsync = ref.watch(totalAccountBalanceProvider);
  final savingsAsync = ref.watch(totalSavingsProvider);
  final roundOffAsync = ref.watch(roundOffWalletBalanceProvider);

  if (accountBalanceAsync is AsyncLoading ||
      savingsAsync is AsyncLoading ||
      roundOffAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  if (accountBalanceAsync is AsyncError) {
    return AsyncError(accountBalanceAsync.error!, accountBalanceAsync.stackTrace!);
  }
  if (savingsAsync is AsyncError) {
    return AsyncError(savingsAsync.error!, savingsAsync.stackTrace!);
  }
  if (roundOffAsync is AsyncError) {
    return AsyncError(roundOffAsync.error!, roundOffAsync.stackTrace!);
  }

  final total = (accountBalanceAsync.value ?? 0.0) +
      (savingsAsync.value ?? 0.0) +
      (roundOffAsync.value ?? 0.0);

  return AsyncData(total);
});
