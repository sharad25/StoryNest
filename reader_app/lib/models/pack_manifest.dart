class PackManifest {
  final String id;
  final String title;
  final String? version;
  final String? description;
  final String? image;
  final int storyCount;
  final List<String> stories;

  PackManifest({
    required this.id,
    required this.title,
    this.version,
    this.description,
    this.image,
    required this.storyCount,
    required this.stories,
  });

  factory PackManifest.fromJson(Map<String, dynamic> j) {
    final storiesList = (j['stories'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
    return PackManifest(
      id: j['id'] as String? ?? '',
      title: j['title'] as String? ?? '',
      version: j['version'] as String?,
      description: j['description'] as String?,
      image: j['image'] as String?,
      storyCount: j['story_count'] as int? ?? storiesList.length,
      stories: storiesList,
    );
  }

  List<String> validate() {
    final errs = <String>[];
    if (id.isEmpty) errs.add('id missing');
    if (title.isEmpty) errs.add('title missing');
    if (storyCount < 0) errs.add('story_count < 0');
    return errs;
  }
}
