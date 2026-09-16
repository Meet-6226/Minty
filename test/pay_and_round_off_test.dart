import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/data/database/app_database.dart';
import 'package:minty/providers/database_providers.dart';
import 'package:minty/screens/pay_screen.dart';
import 'package:minty/screens/payment_success_screen.dart';
import 'package:minty/screens/round_off_wallet_screen.dart';
import 'package:minty/theme/app_theme.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Round-Off Calculation & Logic Unit Tests', () {
    double calculateRoundOff(double amount) {
      if (amount <= 0) return 0.0;
      final remainder = amount % 10;
      return remainder > 0 ? (10 - remainder) : 0.0;
    }

    test('Round payment UP to nearest ₹10 examples', () {
      expect(calculateRoundOff(990.0), 0.0);
      expect(calculateRoundOff(275.0), 5.0); // 275 -> 280 (round-off 5)
      expect(calculateRoundOff(421.0), 9.0); // 421 -> 430 (round-off 9)
      expect(calculateRoundOff(1000.0), 0.0); // 1000 -> 1000 (round-off 0)
      expect(calculateRoundOff(991.0), 9.0); // 991 -> 1000 (round-off 9)
      expect(calculateRoundOff(999.0), 1.0); // 999 -> 1000 (round-off 1)
      expect(calculateRoundOff(280.0), 0.0);
    });

    test(
        'processPayment successfully deducts total payment and records round-off',
        () async {
      final accounts = await db.getAllAccounts();
      final hdfcAccount = accounts.firstWhere((a) => a.name.contains('HDFC'));
      final initialBalance = hdfcAccount.balance;

      final categories = await db.getAllCategories();
      final cat = categories.firstWhere((c) => c.type == 'expense');

      final initialWalletBalance =
          await db.watchRoundOffWalletBalance().first;

      final actualPayment = 991.0;
      final roundOff = 9.0; // 991 + 9 = 1000 total

      final txId = await db.processPayment(
        accountId: hdfcAccount.id,
        categoryId: cat.id,
        amount: actualPayment,
        description: 'Paid to Priya Patel',
        date: DateTime.now(),
        roundOffAmount: roundOff,
      );

      expect(txId, isPositive);

      // Verify Account balance was reduced by TOTAL (actualPayment + roundOff)
      final updatedAccounts = await db.getAllAccounts();
      final updatedHdfc =
          updatedAccounts.firstWhere((a) => a.id == hdfcAccount.id);
      expect(updatedHdfc.balance, initialBalance - (actualPayment + roundOff));

      // Verify Round-Off Wallet balance increased by roundOff amount
      final updatedWalletBalance =
          await db.watchRoundOffWalletBalance().first;
      expect(updatedWalletBalance, initialWalletBalance + roundOff);

      // Verify Transaction record
      final txDetails = await db.watchTransactionDetails(txId).first;
      expect(txDetails, isNotNull);
      expect(txDetails?.transaction.amount, actualPayment);
      expect(txDetails?.transaction.roundOffAmount, roundOff);
    });

    test('processPayment rejects when account has insufficient balance',
        () async {
      final accounts = await db.getAllAccounts();
      final hdfcAccount = accounts.firstWhere((a) => a.name.contains('HDFC'));

      final categories = await db.getAllCategories();
      final cat = categories.firstWhere((c) => c.type == 'expense');

      // Attempt to pay more than account balance
      final excessiveAmount = hdfcAccount.balance + 10000.0;

      expect(
        () async => await db.processPayment(
          accountId: hdfcAccount.id,
          categoryId: cat.id,
          amount: excessiveAmount,
          description: 'Payment Too Large',
          date: DateTime.now(),
          roundOffAmount: 10.0,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('searchContacts filters by name, phone and UPI ID', () async {
      final allContacts = await db.searchContacts('').first;
      expect(allContacts.length, greaterThanOrEqualTo(5));

      final searchByName = await db.searchContacts('Sneha').first;
      expect(searchByName.length, 1);
      expect(searchByName.first.name, 'Sneha Reddy');

      final searchByUpi = await db.searchContacts('@okhdfcbank').first;
      expect(searchByUpi.length, 1);
      expect(searchByUpi.first.name, 'Rohan Sharma');

      final searchByPhone = await db.searchContacts('98765').first;
      expect(searchByPhone.length, 1);
      expect(searchByPhone.first.name, 'Priya Patel');
    });
  });

  group('Pay & Round-Off Wallet UI Widget Tests', () {
    testWidgets('PayScreen displays contacts list and search bar',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PayScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Payments & UPI'), findsOneWidget);
      expect(find.text('Saved Contacts'), findsOneWidget);
      expect(find.text('Rohan Sharma'), findsOneWidget);
      expect(find.text('Priya Patel'), findsOneWidget);
      expect(find.text('Sneha Reddy'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('PayScreen updates breakdown when typing 201 then 2011',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final contacts = await db.getAllContacts();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: PayScreen(initialContact: contacts.first),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final amountField = find.ancestor(
        of: find.text('0.00'),
        matching: find.byType(TextFormField),
      );
      expect(amountField, findsOneWidget);

      // Enter 201
      await tester.enterText(amountField, '201');
      await tester.pump();
      expect(find.text('₹201.00'), findsOneWidget);
      expect(find.text('+₹9.00'), findsOneWidget);
      expect(find.text('₹210.00'), findsOneWidget);

      // Now enter 2011 (round-off remains 9.0, but actual payment must update to 2011.00)
      await tester.enterText(amountField, '2011');
      await tester.pump();
      expect(find.text('₹2,011.00'), findsOneWidget);
      expect(find.text('+₹9.00'), findsOneWidget);
      expect(find.text('₹2,020.00'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('RoundOffWalletScreen displays total balance and history',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const RoundOffWalletScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Round-Off Wallet'), findsOneWidget);
      expect(find.text('TOTAL SAVED VIA ROUND-OFF'), findsOneWidget);
      expect(find.text('Round-Off History'), findsOneWidget);
      expect(find.text('Starbucks Coffee'), findsOneWidget);

      // Tap back button
      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets(
        'PaymentSuccessScreen displays recipient and spare change saved',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final dummyContact = Contact(
        id: 1,
        name: 'Sneha Reddy',
        phone: '+91 99887 76655',
        upiId: 'sneha.reddy@icici',
        avatar: 'S',
      );
      final dummyAccount = Account(
        id: 1,
        name: 'HDFC Bank (Primary)',
        type: 'Savings',
        balance: 38500.0,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: PaymentSuccessScreen(
            contact: dummyContact,
            account: dummyAccount,
            amount: 990.0,
            roundOffAmount: 10.0,
            note: 'Dinner split',
            date: DateTime.now(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Payment Successful'), findsOneWidget);
      expect(find.text('₹1,000.00'), findsOneWidget);
      expect(find.text('Paid to Sneha Reddy'), findsOneWidget);
      expect(find.text('₹10 added to Round-Off Wallet'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
