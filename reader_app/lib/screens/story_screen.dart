import 'package:flutter/material.dart';
import '../models/story_manifest.dart';
import 'page_screen.dart';

class StoryScreen extends StatelessWidget {
  final StoryManifest story;

  const StoryScreen({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Immediately open the first page in the story as a dedicated screen.
    Future.microtask(() {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PageScreen(story: story, pageIndex: 0)));
    });
    return Scaffold(appBar: AppBar(title: Text(story.title)), body: const SizedBox.shrink());
  }
}
