import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/screens/settings_screen.dart';
import 'package:reader_app/main.dart';

void main() {
  testWidgets('Settings screen navigation and feedback copy', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    // Tap Privacy
    await tester.tap(find.text('Privacy Notice'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy Notice'), findsWidgets);
    // Back
    await tester.pageBack();
    await tester.pumpAndSettle();
    // Tap License
    await tester.tap(find.text('License'));
    await tester.pumpAndSettle();
    expect(find.text('License'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    // Tap Feedback and copy suggestion email using trailing icon
    await tester.tap(find.text('Feedback'));
    await tester.pumpAndSettle();
    expect(find.text('Contact us'), findsOneWidget);
    // Tap copy button
    await tester.tap(find.byIcon(Icons.copy).first);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    // Tap About
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('About'), findsWidgets);
  });

  testWidgets('App builds StoryNestApp and shows splash', (tester) async {
    await tester.pumpWidget(const StoryNestApp());
    await tester.pump();
    expect(find.text('Story Nest'), findsOneWidget);
  });
}
