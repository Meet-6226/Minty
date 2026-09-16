import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/database/app_database.dart';
import 'database_providers.dart';

// ==========================================
// MODELS FOR ANALYTICS & INSIGHTS
// ==========================================

class CategorySpending {
  final Category category;
  final double amount;
  final double percentage; // 0.0 to 100.0
  final int transactionCount;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
    this.transactionCount = 1,
  });
}

class MonthlyAnalyticsData {
  final DateTime monthDate;
  final double totalIncome;
  final double totalExpense;
  final double netSavings; // totalIncome - totalExpense
  final double savingsRate; // % of income saved (0 to 100)
  final double roundOffSaved;
  final int transactionCount;
  final List<CategorySpending> categorySpendings;
  final CategorySpending? topCategory;

  // Comparison with previous month
  final double prevMonthIncome;
  final double prevMonthExpense;
  final double? incomeChangePct;
  final double? expenseChangePct;

  const MonthlyAnalyticsData({
    required this.monthDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.roundOffSaved,
    required this.transactionCount,
    required this.categorySpendings,
    this.topCategory,
    this.prevMonthIncome = 0.0,
    this.prevMonthExpense = 0.0,
    this.incomeChangePct,
    this.expenseChangePct,
  });

  bool get hasData => transactionCount > 0 || totalIncome > 0 || totalExpense > 0;

  static MonthlyAnalyticsData empty(DateTime date) {
    return MonthlyAnalyticsData(
      monthDate: date,
      totalIncome: 0.0,
      totalExpense: 0.0,
      netSavings: 0.0,
      savingsRate: 0.0,
      roundOffSaved: 0.0,
      transactionCount: 0,
      categorySpendings: const [],
      topCategory: null,
      prevMonthIncome: 0.0,
      prevMonthExpense: 0.0,
      incomeChangePct: null,
      expenseChangePct: null,
    );
  }
}

enum InsightType {
  positive,
  warning,
  info,
}

class FinancialInsight {
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final InsightType type;

  const FinancialInsight({
    required this.tag,
    required this.title,
    required this.subtitle,
    this.icon = Icons.auto_awesome_rounded,
    this.type = InsightType.info,
  });
}

// ==========================================
// NOTIFIERS & STREAM PROVIDERS
// ==========================================

enum InsightsPeriod {
  thisMonth,
  lastMonth,
}

class InsightsPeriodNotifier extends Notifier<InsightsPeriod> {
  @override
  InsightsPeriod build() => InsightsPeriod.thisMonth;

  void setPeriod(InsightsPeriod period) => state = period;
  void selectThisMonth() => state = InsightsPeriod.thisMonth;
  void selectLastMonth() => state = InsightsPeriod.lastMonth;
}

final insightsPeriodProvider =
    NotifierProvider<InsightsPeriodNotifier, InsightsPeriod>(
        InsightsPeriodNotifier.new);

// Active Date corresponding to period
final activeInsightsDateProvider = Provider<DateTime>((ref) {
  final period = ref.watch(insightsPeriodProvider);
  final now = DateTime.now();
  if (period == InsightsPeriod.thisMonth) {
    return DateTime(now.year, now.month);
  } else {
    return DateTime(now.year, now.month - 1);
  }
});

// Single Stream of all transactions with details for analytics
final allTransactionsForAnalyticsProvider =
    StreamProvider<List<TransactionWithDetails>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactionsWithDetails();
});

// Budgets for Specific Date Provider
final monthlyBudgetsForDateProvider =
    StreamProvider.family<List<BudgetWithCategoryAndSpending>, DateTime>((ref, date) {
  final db = ref.watch(databaseProvider);
  return db.watchBudgetsWithSpendingForMonth(date.month, date.year);
});

// Monthly Analytics Provider computed synchronously from transaction list
final monthlyAnalyticsProvider =
    Provider.family<AsyncValue<MonthlyAnalyticsData>, DateTime>((ref, monthDate) {
  final allTxAsync = ref.watch(allTransactionsForAnalyticsProvider);

  return allTxAsync.whenData((allTx) {
    // Month date range
    final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final endOfMonth =
        DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);

    // Previous month date range
    final prevMonthDate = DateTime(monthDate.year, monthDate.month - 1, 1);
    final startOfPrevMonth = DateTime(prevMonthDate.year, prevMonthDate.month, 1);
    final endOfPrevMonth =
        DateTime(prevMonthDate.year, prevMonthDate.month + 1, 0, 23, 59, 59);

    // Current month transactions
    final currentTx = allTx
        .where((tx) =>
            !tx.transaction.date.isBefore(startOfMonth) &&
            !tx.transaction.date.isAfter(endOfMonth))
        .toList();

    // Prev month transactions
    final prevTx = allTx
        .where((tx) =>
            !tx.transaction.date.isBefore(startOfPrevMonth) &&
            !tx.transaction.date.isAfter(endOfPrevMonth))
        .toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    double roundOffSaved = 0.0;
    final Map<int, CategorySpendingBuilder> catMap = {};

    for (final item in currentTx) {
      final tx = item.transaction;
      final cat = item.category;

      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
        roundOffSaved += tx.roundOffAmount;

        final existing = catMap[cat.id];
        if (existing == null) {
          catMap[cat.id] = CategorySpendingBuilder(
            category: cat,
            amount: tx.amount,
            count: 1,
          );
        } else {
          existing.amount += tx.amount;
          existing.count += 1;
        }
      }
    }

    // Previous month totals
    double prevMonthIncome = 0.0;
    double prevMonthExpense = 0.0;
    for (final item in prevTx) {
      if (item.transaction.type == 'income') {
        prevMonthIncome += item.transaction.amount;
      } else if (item.transaction.type == 'expense') {
        prevMonthExpense += item.transaction.amount;
      }
    }

    // Category spendings with safe percentages
    final List<CategorySpending> categorySpendings = catMap.values.map((b) {
      final pct = totalExpense > 0 ? (b.amount / totalExpense) * 100.0 : 0.0;
      return CategorySpending(
        category: b.category,
        amount: b.amount,
        percentage: pct.clamp(0.0, 100.0),
        transactionCount: b.count,
      );
    }).toList();

    categorySpendings.sort((a, b) => b.amount.compareTo(a.amount));
    final topCategory =
        categorySpendings.isNotEmpty ? categorySpendings.first : null;

    final netSavings = totalIncome - totalExpense;
    final savingsRate = (totalIncome > 0 && netSavings > 0)
        ? ((netSavings / totalIncome) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    // Percentage changes vs previous month
    double? incomeChangePct;
    if (prevMonthIncome > 0) {
      incomeChangePct =
          ((totalIncome - prevMonthIncome) / prevMonthIncome) * 100.0;
    }

    double? expenseChangePct;
    if (prevMonthExpense > 0) {
      expenseChangePct =
          ((totalExpense - prevMonthExpense) / prevMonthExpense) * 100.0;
    }

    return MonthlyAnalyticsData(
      monthDate: monthDate,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRate: savingsRate,
      roundOffSaved: roundOffSaved,
      transactionCount: currentTx.length,
      categorySpendings: categorySpendings,
      topCategory: topCategory,
      prevMonthIncome: prevMonthIncome,
      prevMonthExpense: prevMonthExpense,
      incomeChangePct: incomeChangePct,
      expenseChangePct: expenseChangePct,
    );
  });
});

class CategorySpendingBuilder {
  final Category category;
  double amount;
  int count;

  CategorySpendingBuilder({
    required this.category,
    required this.amount,
    required this.count,
  });
}

// Active Month Analytics Provider
final activeMonthAnalyticsProvider =
    Provider<AsyncValue<MonthlyAnalyticsData>>((ref) {
  final activeDate = ref.watch(activeInsightsDateProvider);
  return ref.watch(monthlyAnalyticsProvider(activeDate));
});

// Previous Month Analytics Provider
final previousMonthAnalyticsProvider =
    Provider<AsyncValue<MonthlyAnalyticsData>>((ref) {
  final activeDate = ref.watch(activeInsightsDateProvider);
  final prevDate = DateTime(activeDate.year, activeDate.month - 1);
  return ref.watch(monthlyAnalyticsProvider(prevDate));
});

// ==========================================
// DETERMINISTIC RULE-BASED INSIGHTS ENGINE
// ==========================================

final financialInsightsProvider =
    Provider<AsyncValue<List<FinancialInsight>>>((ref) {
  final activeDate = ref.watch(activeInsightsDateProvider);
  final currentAnalyticsAsync = ref.watch(activeMonthAnalyticsProvider);
  final prevAnalyticsAsync = ref.watch(previousMonthAnalyticsProvider);
  final budgetsAsync = ref.watch(monthlyBudgetsForDateProvider(activeDate));

  if (currentAnalyticsAsync is AsyncLoading ||
      prevAnalyticsAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  final current =
      currentAnalyticsAsync.value ?? MonthlyAnalyticsData.empty(activeDate);
  final prev =
      prevAnalyticsAsync.value ?? MonthlyAnalyticsData.empty(DateTime(activeDate.year, activeDate.month - 1));
  final budgets = budgetsAsync.value ?? const [];

  final List<FinancialInsight> insights = [];

  // 1. Budget Alerts / Exhaustion Check (Highest Priority)
  for (final b in budgets) {
    if (b.isExceeded) {
      final overspent = b.spent - b.budget.amount;
      insights.add(
        FinancialInsight(
          tag: 'BUDGET ALERT',
          title:
              'Budget for ${b.category.name} exceeded by ₹${NumberFormat('#,##0').format(overspent)}.',
          subtitle:
              'You have spent ₹${NumberFormat('#,##0').format(b.spent)} of ₹${NumberFormat('#,##0').format(b.budget.amount)} limit.',
          icon: Icons.error_outline_rounded,
          type: InsightType.warning,
        ),
      );
    } else if (b.isApproaching) {
      insights.add(
        FinancialInsight(
          tag: 'BUDGET WATCH',
          title:
              'Budget for ${b.category.name} is ${(b.progress * 100).toInt()}% exhausted.',
          subtitle:
              '₹${NumberFormat('#,##0').format(b.remaining)} remaining for the rest of this month.',
          icon: Icons.pie_chart_outline_rounded,
          type: InsightType.warning,
        ),
      );
    }
  }

  // 2. Month-over-Month Category Spending Comparison
  if (current.topCategory != null) {
    final topCatId = current.topCategory!.category.id;
    final prevCatMatch = prev.categorySpendings
        .where((c) => c.category.id == topCatId)
        .firstOrNull;

    if (prevCatMatch != null && prevCatMatch.amount > 0) {
      final diffPct = ((current.topCategory!.amount - prevCatMatch.amount) /
              prevCatMatch.amount *
              100.0)
          .round();

      if (diffPct < 0) {
        insights.add(
          FinancialInsight(
            tag: 'CATEGORY SAVINGS',
            title:
                'You spent ${diffPct.abs()}% less on ${current.topCategory!.category.name} this month.',
            subtitle:
                'Reduced from ₹${NumberFormat('#,##0').format(prevCatMatch.amount)} to ₹${NumberFormat('#,##0').format(current.topCategory!.amount)}.',
            icon: Icons.trending_down_rounded,
            type: InsightType.positive,
          ),
        );
      } else if (diffPct > 0) {
        insights.add(
          FinancialInsight(
            tag: 'CATEGORY SPENDING',
            title:
                'Spending on ${current.topCategory!.category.name} increased by $diffPct% this month.',
            subtitle:
                'Total expense is ₹${NumberFormat('#,##0').format(current.topCategory!.amount)} vs ₹${NumberFormat('#,##0').format(prevCatMatch.amount)} last month.',
            icon: Icons.trending_up_rounded,
            type: InsightType.info,
          ),
        );
      }
    } else {
      // Top Spending Category Announcement
      insights.add(
        FinancialInsight(
          tag: 'HIGHEST SPENDING',
          title:
              '${current.topCategory!.category.name} is your highest spending category.',
          subtitle:
              'Accounts for ${current.topCategory!.percentage.toStringAsFixed(1)}% (₹${NumberFormat('#,##0').format(current.topCategory!.amount)}) of total expenses.',
          icon: Icons.donut_small_rounded,
          type: InsightType.info,
        ),
      );
    }
  }

  // 3. Savings Rate Achievement
  if (current.totalIncome > 0) {
    if (current.savingsRate >= 20.0) {
      insights.add(
        FinancialInsight(
          tag: 'SAVINGS WIN',
          title:
              'You saved ${current.savingsRate.toStringAsFixed(0)}% of your income this month!',
          subtitle:
              'Retained ₹${NumberFormat('#,##0').format(current.netSavings)} from ₹${NumberFormat('#,##0').format(current.totalIncome)} earnings.',
          icon: Icons.savings_outlined,
          type: InsightType.positive,
        ),
      );
    } else if (current.savingsRate > 0) {
      insights.add(
        FinancialInsight(
          tag: 'SAVINGS RATE',
          title:
              'You saved ${current.savingsRate.toStringAsFixed(0)}% of your income this month.',
          subtitle:
              'Total net savings: ₹${NumberFormat('#,##0').format(current.netSavings)}.',
          icon: Icons.account_balance_wallet_outlined,
          type: InsightType.info,
        ),
      );
    } else if (current.netSavings < 0) {
      insights.add(
        FinancialInsight(
          tag: 'CASH FLOW WATCH',
          title:
              'Expenses exceeded income by ₹${NumberFormat('#,##0').format(current.netSavings.abs())} this month.',
          subtitle:
              'Review discretionary spending to restore a positive monthly savings rate.',
          icon: Icons.trending_down_rounded,
          type: InsightType.warning,
        ),
      );
    }
  }

  // 4. Overall Spending Trend (Month over Month)
  if (current.expenseChangePct != null && current.prevMonthExpense > 0) {
    final change = current.expenseChangePct!.round();
    if (change < 0) {
      insights.add(
        FinancialInsight(
          tag: 'MONTHLY TREND',
          title:
              'Your total spending decreased by ${change.abs()}% compared with last month.',
          subtitle:
              '₹${NumberFormat('#,##0').format(current.totalExpense)} this month vs ₹${NumberFormat('#,##0').format(current.prevMonthExpense)} last month.',
          icon: Icons.thumb_up_alt_outlined,
          type: InsightType.positive,
        ),
      );
    } else if (change > 0) {
      insights.add(
        FinancialInsight(
          tag: 'SPENDING TREND',
          title:
              'Your spending increased by $change% compared with last month.',
          subtitle:
              'Monthly outflow is ₹${NumberFormat('#,##0').format(current.totalExpense)} vs ₹${NumberFormat('#,##0').format(current.prevMonthExpense)}.',
          icon: Icons.trending_up_rounded,
          type: InsightType.info,
        ),
      );
    }
  }

  // 5. Round-Off Micro-savings
  if (current.roundOffSaved > 0) {
    insights.add(
      FinancialInsight(
        tag: 'SPARE CHANGE SAVED',
        title:
            '₹${NumberFormat('#,##0.00').format(current.roundOffSaved)} saved effortlessly with Round-Off.',
        subtitle:
            'Auto-saved spare change accumulated from recent payments.',
        icon: Icons.stars_rounded,
        type: InsightType.positive,
      ),
    );
  }

  // Fallback if no specific insights generated
  if (insights.isEmpty) {
    if (current.hasData) {
      insights.add(
        FinancialInsight(
          tag: 'MONTHLY HIGHLIGHT',
          title:
              'You recorded ${current.transactionCount} transactions this month.',
          subtitle:
              'Total expense: ₹${NumberFormat('#,##0').format(current.totalExpense)}.',
          icon: Icons.insights_rounded,
          type: InsightType.info,
        ),
      );
    } else {
      insights.add(
        const FinancialInsight(
          tag: 'GET STARTED',
          title: 'Add transactions to unlock personalized insights.',
          subtitle:
              'Log your daily expenses and income to see smart financial analysis.',
          icon: Icons.auto_awesome_rounded,
          type: InsightType.info,
        ),
      );
    }
  }

  return AsyncData(insights);
});

// Single Highlight Insight for Home Screen
final homeHighlightInsightProvider =
    Provider<AsyncValue<FinancialInsight>>((ref) {
  final insightsAsync = ref.watch(financialInsightsProvider);
  return insightsAsync.whenData((list) => list.first);
});
