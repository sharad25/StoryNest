import 'package:flutter/material.dart';
import '../models/story_manifest.dart';
import 'page_screen.dart';
import 'settings_screen.dart';

class StoryScreen extends StatefulWidget {
  final StoryManifest story;

  const StoryScreen({super.key, required this.story});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PageScreen(story: widget.story, pageIndex: 0)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha((0.18 * 255).round()),
              child: Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary),
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: const SizedBox.shrink(),
    );
  }
}
