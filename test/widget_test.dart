import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const DebtPayoffApp());
    // Basic smoke test — app should render
    expect(find.text('Welcome Page'), findsOneWidget);
  });
}
