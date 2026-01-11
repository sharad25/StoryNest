import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/pack_manifest.dart';
import 'package:reader_app/models/story_manifest.dart';

void main() {
  group('PackManifest', () {
    test('fromJson parses fields and validate reports missing', () {
      final j = {
        'id': 'pack1',
        'title': 'Pack One',
        'version': '1.0',
        'description': 'A set of stories',
        'image': 'sample:flower',
        'stories': ['assets/manifests/story1.json']
      };
      final p = PackManifest.fromJson(j);
      expect(p.id, 'pack1');
      expect(p.title, 'Pack One');
      expect(p.version, '1.0');
      expect(p.description, 'A set of stories');
      expect(p.image, 'sample:flower');
      expect(p.storyCount, 1);
      expect(p.stories, isNotEmpty);
      expect(p.validate(), isEmpty);
    });

    test('validate returns errors for missing fields', () {
      final p = PackManifest.fromJson({});
      final errs = p.validate();
      expect(errs, contains('id missing'));
      expect(errs, contains('title missing'));
    });
  });

  group('StoryManifest and Page', () {
    test('fromJson and validate', () {
      final j = {
        'id': 'story1',
        'title': 'The Tale',
        'pages': [
          {'index': 0, 'text': 'First page', 'image': null},
          {'index': 1, 'text': 'Second page', 'image': 'sample:flower'}
        ]
      };
      final s = StoryManifest.fromJson(j);
      expect(s.id, 'story1');
      expect(s.title, 'The Tale');
      expect(s.pages.length, 2);
      expect(s.validate(), isEmpty);
    });

    test('validate returns errors when missing', () {
      final s = StoryManifest.fromJson({});
      final errs = s.validate();
      expect(errs, contains('id missing'));
      expect(errs, contains('title missing'));
      expect(errs, contains('no pages'));
    });
  });
}
