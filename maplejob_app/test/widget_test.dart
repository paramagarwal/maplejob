import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplejob_app/features/applications/presentation/screens/success_screen.dart';

void main() {
  testWidgets('Success screen rendering test', (WidgetTester tester) async {
    // Set realistic mobile screen dimensions for test view bounds
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: SuccessScreen(),
      ),
    );

    expect(find.text('Application Submitted!'), findsOneWidget);
  });
}
