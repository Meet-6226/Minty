import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/database_providers.dart';
import 'package:minty/screens/add_expense_screen.dart';
import 'package:minty/screens/add_income_screen.dart';
import 'package:minty/screens/budgets_screen.dart';
import 'package:minty/screens/home_screen.dart';
import 'package:minty/screens/insights_screen.dart';
import 'package:minty/screens/pay_screen.dart';
import 'package:minty/screens/profile_screen.dart';
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

  Widget createTestApp(Widget child, ProviderContainer container,
      {ThemeData? theme}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: child,
      ),
    );
  }

  final testWidths = [
    320.0, // Small mobile (iPhone SE 1st gen)
    375.0, // Medium mobile (iPhone SE 2/3, iPhone 8)
    390.0, // Modern standard mobile (iPhone 13/14/15)
    430.0, // Large mobile (iPhone 14/15 Pro Max)
  ];

  group('Mobile Screen Responsiveness & Overflow Prevention', () {
    setUp(() {
      FlutterError.onError = (details) {
        debugPrint('OVERFLOW_DETAILS:\n${details.summary}\n${details.context}');
        for (final node in details.informationCollector?.call() ?? []) {
          debugPrint('COLLECTOR: $node');
        }
      };
    });
    for (final width in testWidths) {
      testWidgets('HomeScreen renders without overflow at ${width}px width',
          (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createTestApp(const HomeScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('PayScreen renders without overflow at ${width}px width',
          (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(createTestApp(const PayScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(PayScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('BudgetsScreen renders without overflow at ${width}px width',
          (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester
            .pumpWidget(createTestApp(const BudgetsScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(BudgetsScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'SavingsGoalsScreen renders without overflow at ${width}px width',
          (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester
            .pumpWidget(createTestApp(const SavingsGoalsScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(SavingsGoalsScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'RecurringExpensesScreen renders without overflow at ${width}px width',
          (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
            createTestApp(const RecurringExpensesScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(RecurringExpensesScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('InsightsScreen renders without overflow at ${width}px width',
          (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester
            .pumpWidget(createTestApp(const InsightsScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(InsightsScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('ProfileScreen renders without overflow at ${width}px width',
          (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester
            .pumpWidget(createTestApp(const ProfileScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          'AddExpense & AddIncome render without overflow at ${width}px width',
          (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
        );
        addTearDown(container.dispose);

        await tester
            .pumpWidget(createTestApp(const AddExpenseScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(AddExpenseScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester
            .pumpWidget(createTestApp(const AddIncomeScreen(), container));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(AddIncomeScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
