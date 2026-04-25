import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_payoff_manager/features/plan/presentation/widgets/extra_amount_sheet.dart';
import 'package:debt_payoff_manager/l10n/app_localizations.dart';

void main() {
  testWidgets('extra amount sheet keeps actions above the keyboard', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetViewInsets());

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => ExtraAmountSheet.show(context),
                child: const Text('Open sheet'),
              );
            },
          ),
        ),
      ),
    );

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final saveButtonTop = tester.getTopLeft(find.text('Save changes')).dy;
    final keyboardTop =
        tester.view.physicalSize.height / tester.view.devicePixelRatio -
        tester.view.viewInsets.bottom / tester.view.devicePixelRatio;

    expect(saveButtonTop, lessThan(keyboardTop));
    expect(find.text('Reset to \$0 (Minimum)'), findsOneWidget);
  });
}
