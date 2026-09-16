import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/database_providers.dart';
import 'package:minty/screens/activity_screen.dart';
import 'package:minty/screens/add_expense_screen.dart';
import 'package:minty/screens/add_income_screen.dart';
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

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('Expense & Income Management Flow Tests', () {
    testWidgets('AddExpenseScreen validates required fields and amount',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const AddExpenseScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('EXPENSE AMOUNT'), findsOneWidget);
      expect(find.text('Save Expense'), findsOneWidget);

      // Attempt to save without entering amount
      await tester.ensureVisible(find.text('Save Expense'));
      await tester.tap(find.text('Save Expense'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Enter amount'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('AddIncomeScreen validates required fields and amount',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const AddIncomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add Income'), findsOneWidget);
      expect(find.text('INCOME AMOUNT'), findsOneWidget);
      expect(find.text('Save Income'), findsOneWidget);

      // Attempt to save without entering amount
      await tester.ensureVisible(find.text('Save Income'));
      await tester.tap(find.text('Save Income'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Enter amount'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('ActivityScreen displays header, search, and filter chips',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(const ActivityScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Spare Change'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('TransactionDetailsScreen renders details and delete dialog',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Use the first seeded transaction ID (1)
      await tester.pumpWidget(
        buildTestableWidget(const TransactionDetailsScreen(transactionId: 1)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Transaction Details'), findsOneWidget);
      // Tap Delete Transaction
      await tester.tap(find.byTooltip('Delete Transaction'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Are you sure you want to delete "Starbucks Coffee"?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Transaction Details'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
