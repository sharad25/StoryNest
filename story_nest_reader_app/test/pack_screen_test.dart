import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/screens/pack_screen.dart';

void main() {
  testWidgets('PackScreen shows description and flower icon and bottom controls', (tester) async {
    final packJson = '''{
      "id": "pack_test",
      "title": "Test Pack",
      "description": "A nice pack",
      "image": "sample:flower",
      "stories": []
    }''';

    await tester.pumpWidget(MaterialApp(home: PackScreen(packAssetPath: 'assets/manifests/pack_test.json', packJsonOverride: packJson)));
    // Let async loads run
    await tester.pumpAndSettle();
    expect(find.text('A nice pack'), findsOneWidget);
    // Flower icon from pack image
    expect(find.byIcon(Icons.local_florist), findsOneWidget);
    // Bottom Play/Pause control present
    expect(find.text('Play'), findsOneWidget);
    // Try tapping Play (will attempt to play the asset if available)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Play'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // Tapping play exercised the onPressed handler (no further assertion)
  });

  testWidgets('PackScreen loads listed stories from assets and shows them', (tester) async {
    final packJson = '''{
      "id": "pack_with_stories",
      "title": "WithStories",
      "description": "Has stories",
      "image": "sample:flower",
      "stories": ["assets/manifests/pack1_story1.json"]
    }''';
    await tester.pumpWidget(MaterialApp(home: PackScreen(packAssetPath: 'assets/manifests/pack_with_stories.json', packJsonOverride: packJson)));
    await tester.pumpAndSettle();
    // Story from pack1_story1.json should appear
    expect(find.text('The Little Fox'), findsOneWidget);
    // Open Story button present
    expect(find.widgetWithText(ElevatedButton, 'Open Story'), findsWidgets);
    // Tap Open Story to navigate into the story (pauses pack audio)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Open Story').first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // After navigation, a page text from the story should be visible
    expect(find.textContaining('A little fox'), findsWidgets);
    // Go back to pack screen and try interacting with slider when audio is present
    await tester.pageBack();
    await tester.pumpAndSettle();
    final slider = find.byType(Slider).first;
    if (slider.evaluate().isNotEmpty) {
      await tester.drag(slider, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();
    }
  });
}
