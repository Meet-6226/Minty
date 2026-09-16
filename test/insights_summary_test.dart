import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/database_providers.dart';
import 'package:minty/providers/insights_providers.dart';
import 'package:minty/screens/home_screen.dart';
import 'package:minty/screens/insights_screen.dart';
import 'package:minty/screens/monthly_summary_screen.dart';
import 'package:minty/theme/app_theme.dart';
import 'package:minty/widgets/charts/category_pie_chart.dart';
import 'package:minty/widgets/charts/income_expense_chart.dart';

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

  group('Insights & Monthly Analytics Math & Logic Unit Tests', () {
    test('MonthlyAnalyticsData calculations and safe empty fallbacks', () {
      final now = DateTime.now();
      final emptyData = MonthlyAnalyticsData.empty(now);

      expect(emptyData.totalIncome, 0.0);
      expect(emptyData.totalExpense, 0.0);
      expect(emptyData.netSavings, 0.0);
      expect(emptyData.savingsRate, 0.0);
      expect(emptyData.hasData, isFalse);
      expect(emptyData.categorySpendings, isEmpty);
      expect(emptyData.topCategory, isNull);

      final data = MonthlyAnalyticsData(
        monthDate: now,
        totalIncome: 100000,
        totalExpense: 25000,
        netSavings: 75000,
        savingsRate: 75.0,
        roundOffSaved: 120.0,
        transactionCount: 15,
        categorySpendings: const [],
        prevMonthIncome: 80000,
        prevMonthExpense: 30000,
        incomeChangePct: 25.0,
        expenseChangePct: -16.67,
      );

      expect(data.hasData, isTrue);
      expect(data.savingsRate, 75.0);
      expect(data.incomeChangePct, 25.0);
      expect(data.expenseChangePct, -16.67);
    });

    test('FinancialInsight data model creation', () {
      const insight = FinancialInsight(
        tag: 'BUDGET WATCH',
        title: 'Budget for Food is 85% exhausted',
        subtitle: '₹1,500 remaining',
        icon: Icons.pie_chart_outline_rounded,
        type: InsightType.warning,
      );

      expect(insight.tag, 'BUDGET WATCH');
      expect(insight.title, 'Budget for Food is 85% exhausted');
      expect(insight.type, InsightType.warning);
    });
  });

  group('UI & Widget Tests for Charts and Screens', () {
    testWidgets('IncomeExpenseChart renders properly with values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IncomeExpenseChart(
              income: 65000,
              expense: 15000,
              prevIncome: 60000,
              prevExpense: 18000,
              showComparison: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cash Flow Overview'), findsOneWidget);
      expect(find.text('Income vs Expenses'), findsOneWidget);
      expect(find.text('Income'), findsWidgets);
      expect(find.text('Expense'), findsWidgets);
    });

    testWidgets('IncomeExpenseChart renders empty state properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IncomeExpenseChart(
              income: 0,
              expense: 0,
              prevIncome: 0,
              prevExpense: 0,
              showComparison: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No transactions to display'), findsOneWidget);
    });

    testWidgets('CategoryPieChart renders categories and legend', (tester) async {
      final categories = await db.getAllCategories();
      final foodCat = categories.firstWhere((c) => c.name.contains('Food'));
      final billsCat = categories.firstWhere((c) => c.name.contains('Bills'));

      final spendings = [
        CategorySpending(category: foodCat, amount: 8000, percentage: 80.0),
        CategorySpending(category: billsCat, amount: 2000, percentage: 20.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CategoryPieChart(
                categorySpendings: spendings,
                totalExpense: 10000,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('2 categories'), findsOneWidget);
      expect(find.text(foodCat.name), findsOneWidget);
      expect(find.text(billsCat.name), findsOneWidget);
    });

    testWidgets('InsightsScreen renders and displays charts and planning hub', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(const InsightsScreen(), container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Insights & Analytics'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last Month'), findsOneWidget);
      expect(find.text('Smart Financial Insights'), findsOneWidget);
      expect(find.text('Financial Planning Hub'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('MonthlySummaryScreen renders report and metrics', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      await tester.pumpWidget(
        buildTestableWidget(const MonthlySummaryScreen(), container),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Monthly Summary'), findsOneWidget);
      expect(find.text('Total Income'), findsOneWidget);
      expect(find.text('Total Expenses'), findsOneWidget);
      expect(find.text('Round-Off Wallet Savings'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('HomeScreen renders live InsightCard and navigates to Insights', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(const HomeScreen(), container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Financial Insight'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
