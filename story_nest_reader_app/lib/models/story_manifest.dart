class Page {
  final int index;
  final String text;
  final String? image;
  final String? audio;
  final int? durationMs;

  Page({required this.index, required this.text, this.image, this.audio, this.durationMs});

  factory Page.fromJson(Map<String, dynamic> j) => Page(
        index: j['index'] as int? ?? 0,
        text: j['text'] as String? ?? '',
        image: j['image'] as String?,
        audio: j['audio'] as String?,
        durationMs: j['duration_ms'] as int?,
      );
}

class StoryManifest {
  final String id;
  final String title;
  final List<Page> pages;

  StoryManifest({required this.id, required this.title, required this.pages});

  factory StoryManifest.fromJson(Map<String, dynamic> j) {
    final pagesJson = (j['pages'] as List<dynamic>?) ?? [];
    return StoryManifest(
      id: j['id'] as String? ?? '',
      title: j['title'] as String? ?? '',
      pages: pagesJson.map((e) => Page.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  List<String> validate() {
    final errs = <String>[];
    if (id.isEmpty) errs.add('id missing');
    if (title.isEmpty) errs.add('title missing');
    if (pages.isEmpty) errs.add('no pages');
    return errs;
  }
}
