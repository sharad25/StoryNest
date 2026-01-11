// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reader_app/main.dart';

void main() {
  testWidgets('Splash shows title and Start navigates to packs', (WidgetTester tester) async {
    await tester.pumpWidget(const StoryNestApp());

    // Splash should show the app title and a Start button.
    expect(find.text('Story Nest'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    // Tap Start and navigate to HomeScreen.
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // Home should list the packs (Animals Pack and Seasons Pack)
    expect(find.text('Animals Pack'), findsOneWidget);
    expect(find.text('Seasons Pack'), findsOneWidget);
  });
}
