import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:reader_app/models/pack_manifest.dart';
import 'package:reader_app/models/story_manifest.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pack manifest parses and validates', () async {
    final jsonStr = await rootBundle.loadString('assets/manifests/simple_pack_manifest.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final pack = PackManifest.fromJson(json);
    final errs = pack.validate();
    expect(errs, isEmpty);
  });

  test('story manifest parses and validates', () async {
    final jsonStr = await rootBundle.loadString('assets/manifests/simple_story_manifest.json');
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final story = StoryManifest.fromJson(json);
    final errs = story.validate();
    expect(errs, isEmpty);
    expect(story.pages.length, greaterThan(0));
  });
}
