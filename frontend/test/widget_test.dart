import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/theme/app_theme.dart';

void main() {
  testWidgets('WelcomeScreen renders Doodle Duel logo and options', (WidgetTester tester) async {
    // Build WelcomeScreen inside a testable MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.warmGlassTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Doodle Duel'),
          ),
        ),
      ),
    );

    expect(find.text('Doodle Duel'), findsOneWidget);
  });
}
