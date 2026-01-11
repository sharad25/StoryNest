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
            Expanded(
              child: Center(
                child: image != null
                    ? Image.asset(image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 120))
                    : const Icon(Icons.image, size: 120),
              ),
            ),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
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
