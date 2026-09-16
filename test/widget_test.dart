import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minty/screens/home_screen.dart';
import 'package:minty/screens/login_screen.dart';
import 'package:minty/screens/register_screen.dart';
import 'package:minty/screens/splash_screen.dart';
import 'package:minty/theme/app_theme.dart';
import 'package:minty/widgets/bottom_navigation.dart';

import 'package:minty/widgets/savings_goal_card.dart';

void main() {
  testWidgets('SplashScreen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Minty'), findsOneWidget);
    expect(find.text('Fresh finance, made simple.'), findsOneWidget);
  });

  testWidgets('LoginScreen UI and navigation to RegisterScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProviderScope(child: LoginScreen()),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    // Tap Register link
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Create your account'), findsOneWidget);
  });

  testWidgets('HomeScreen bottom navigation tab switching',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(MintyBottomNav), findsOneWidget);

    // Initial tab: Home (contains savings goal card)
    expect(find.byType(SavingsGoalCard), findsOneWidget);

    // Tap Activity tab
    await tester.tap(find.text('Activity'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap Pay tab
    await tester.tap(find.text('Pay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Payments & UPI'), findsOneWidget);

    // Tap Insights tab
    await tester.tap(find.text('Insights'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Insights & Analytics'), findsOneWidget);

    // Tap Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Settings & Preferences'), findsOneWidget);


    // Tap Home tab to return
    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SavingsGoalCard), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
