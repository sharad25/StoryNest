import 'dart:convert';
import 'package:flutter/material.dart';
// Audio playback plugin removed to avoid build-time Android namespace issues.
import '../models/story_manifest.dart';
import 'settings_screen.dart';

class PageScreen extends StatefulWidget {
  final StoryManifest story;
  final int pageIndex;

  const PageScreen({super.key, required this.story, this.pageIndex = 0});

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  late int index;
  // audio player removed; show placeholder behavior for Play button.

  @override
  void initState() {
    super.initState();
    index = widget.pageIndex;
    // no-op
  }

  // audio init removed

  @override
  void dispose() {
    // no audio player to dispose
    super.dispose();
  }

  void _goToPage(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.story.pages.length) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => PageScreen(story: widget.story, pageIndex: newIndex),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.story.pages[index];
    final text = page.text;
    final image = page.image;
    final audio = page.audio;

    Widget imageWidget;
    if (image != null && image == 'sample:flower') {
      imageWidget = Icon(Icons.local_florist, size: 160, color: Colors.deepOrange);
    } else if (image != null && image.startsWith('data:image')) {
      try {
        final base64Part = image.split(',').last;
        final bytes = base64Decode(base64Part);
        imageWidget = Image.memory(bytes, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 120));
      } catch (_) {
        imageWidget = const Icon(Icons.image_not_supported, size: 120);
      }
    } else if (image != null && image.isNotEmpty) {
      imageWidget = Image.asset(image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 120));
    } else {
      imageWidget = const Icon(Icons.image, size: 120);
    }

    final hasImage = image != null && image.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasImage) ...[
              Expanded(child: Center(child: imageWidget)),
              const SizedBox(height: 12),
              Text(text, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
            ] else ...[
              Expanded(child: SingleChildScrollView(child: Text(text, style: const TextStyle(fontSize: 18)))),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: index > 0 ? () => _goToPage(index - 1) : null,
                  child: const Text('Prev'),
                ),
                ElevatedButton(
                  onPressed: (audio != null && audio.isNotEmpty)
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio playback not enabled in this build.')));
                        }
                      : null,
                  child: const Text('Play'),
                ),
                ElevatedButton(
                  onPressed: index < widget.story.pages.length - 1 ? () => _goToPage(index + 1) : null,
                  child: const Text('Next'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Compatibility shim: small wrapper type used by the app models.
class PagePlaceholder {
  final int index;
  final String text;
  final String? image;
  final String? audioPath;

  PagePlaceholder({required this.index, required this.text, this.image, this.audioPath});
}
