import 'package:flutter_test/flutter_test.dart';
import 'package:minty/main.dart';
import 'package:minty/screens/splash_screen.dart';

void main() {
  testWidgets('MintyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MintyApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Minty'), findsOneWidget);
  });
}
