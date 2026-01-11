import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/story_manifest.dart' as sm;
import 'package:reader_app/screens/page_screen.dart' show PageScreen;
import 'package:reader_app/utils/audio_utils.dart' show generateLocalSampleWav;

void main() {
  group('PageScreen widget', () {
    testWidgets('shows text and disables Play when no audio', (tester) async {
      final story = sm.StoryManifest(id: 's1', title: 'T', pages: [sm.Page(index: 0, text: 'Hello world')]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      expect(find.text('Hello world'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      // Play button should be disabled because audio not available
      final playBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Play'));
      expect(playBtn.onPressed, isNull);
    });

    testWidgets('shows sample flower icon when image marker present', (tester) async {
      final story = sm.StoryManifest(id: 's2', title: 'With Image', pages: [sm.Page(index: 0, text: 'P', image: 'sample:flower')]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      expect(find.byIcon(Icons.local_florist), findsOneWidget);
    });

    testWidgets('shows Image.memory for data URL images', (tester) async {
      // 1x1 PNG pixel base64
      final base64Pixel = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';
      final dataUrl = 'data:image/png;base64,$base64Pixel';
      final story = sm.StoryManifest(id: 's3', title: 'DataImg', pages: [sm.Page(index: 0, text: 'P', image: dataUrl)]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      expect(find.byType(Image), findsOneWidget);
    });
    testWidgets('plays audio from bundled asset if available', (tester) async {
      final story = sm.StoryManifest(id: 's6', title: 'AudioAsset', pages: [sm.Page(index: 0, text: 'With audio', audio: 'assets/audio/sample_audio_narration_1.mp3')]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      // Allow async audio init to run
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Play/Pause button exists (may be enabled if audio was initialized)
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('http audio path handled without crashing', (tester) async {
      final story = sm.StoryManifest(id: 's7', title: 'HttpAudio', pages: [sm.Page(index: 0, text: 'Remote', audio: 'http://example.invalid/audio.mp3')]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Remote'), findsOneWidget);
    });

    testWidgets('handles missing asset image with image_not_supported icon', (tester) async {
      final story = sm.StoryManifest(id: 's8', title: 'MissingImg', pages: [sm.Page(index: 0, text: 'P', image: 'assets/images/nonexistent.png')]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('local:sample audio path initializes and shows controls', (tester) async {
      final story = sm.StoryManifest(id: 's9', title: 'LocalSample', pages: [sm.Page(index: 0, text: 'P', audio: 'local:sample')]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Play control should be present; audio init attempted
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('slider becomes interactive when forced audio available', (tester) async {
      final story = sm.StoryManifest(id: 's10', title: 'SliderTest', pages: [sm.Page(index: 0, text: 'P')]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0, forceAudioAvailable: true, forceDurationMs: 3000)));
      await tester.pumpAndSettle();
      // Slider should be present and enabled; attempt to drag it
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(100.0, 0.0));
      await tester.pumpAndSettle();
    });

    testWidgets('navigate between pages from an asset story', (tester) async {
      final json = await rootBundle.loadString('assets/manifests/pack1_story1.json');
      final j = jsonDecode(json) as Map<String, dynamic>;
      final story = sm.StoryManifest.fromJson(j);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Next button should be enabled and navigate to second page
      expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('The fox learned'), findsOneWidget);
    });

    test('generateLocalSampleWav creates a file with WAV header', () async {
      final f = await generateLocalSampleWav();
      expect(await f.exists(), isTrue);
      final bytes = await f.readAsBytes();
      // RIFF header present
      final riff = ascii.decode(bytes.sublist(0, 4));
      expect(riff, 'RIFF');
      expect(bytes.length, greaterThan(44));
    });

    testWidgets('Prev/Next navigation buttons disabled/enabled correctly', (tester) async {
      final story = sm.StoryManifest(id: 's4', title: 'Nav', pages: [
        sm.Page(index: 0, text: 'One'),
        sm.Page(index: 1, text: 'Two'),
      ]);
      await tester.pumpWidget(MaterialApp(home: PageScreen(story: story, pageIndex: 0)));
      // Prev disabled on first page
      final prev = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Prev'));
      expect(prev.onPressed, isNull);
      // Next enabled
      final next = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Next'));
      expect(next.onPressed, isNotNull);
      // Tap Next and rebuild
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.text('Two'), findsOneWidget);
    });
  });
}
