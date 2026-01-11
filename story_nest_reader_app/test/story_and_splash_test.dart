import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/screens/splash_screen.dart';
import 'package:reader_app/screens/story_screen.dart';
import 'package:reader_app/models/story_manifest.dart' as sm;
import 'package:reader_app/screens/page_screen.dart' as ps;

void main() {
  testWidgets('Splash Start navigates to HomeScreen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Story Nest'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    // HomeScreen shows AppBar title 'StoryNest'
    expect(find.text('StoryNest'), findsWidgets);
  });

  testWidgets('StoryScreen pushes PageScreen after init', (tester) async {
    final story = sm.StoryManifest(id: 's5', title: 'Auto', pages: [sm.Page(index: 0, text: 'First page')]);
    await tester.pumpWidget(MaterialApp(home: StoryScreen(story: story)));
    // post frame callback should replace with PageScreen
    await tester.pumpAndSettle();
    expect(find.text('First page'), findsOneWidget);
  });
}
