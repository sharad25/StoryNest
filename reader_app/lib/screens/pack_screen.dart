import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/pack_manifest.dart';
import '../models/story_manifest.dart';
import 'story_screen.dart';
import 'settings_screen.dart';

class PackScreen extends StatefulWidget {
  final String packAssetPath;

  const PackScreen({super.key, required this.packAssetPath});

  @override
  State<PackScreen> createState() => _PackScreenState();
}

class _PackScreenState extends State<PackScreen> {
  PackManifest? pack;
  List<StoryManifest> stories = [];

  @override
  void initState() {
    super.initState();
    _loadPack();
  }

  Future<void> _loadPack() async {
    final str = await rootBundle.loadString(widget.packAssetPath);
    final j = jsonDecode(str) as Map<String, dynamic>;
    final p = PackManifest.fromJson(j);
    final loaded = <StoryManifest>[];
    for (final s in p.stories) {
      try {
        final sj = jsonDecode(await rootBundle.loadString(s)) as Map<String, dynamic>;
        loaded.add(StoryManifest.fromJson(sj));
      } catch (_) {}
    }
    setState(() {
      pack = p;
      stories = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pack?.title ?? 'Story Pack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: pack == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, idx) {
                final s = stories[idx];
                return ListTile(
                  title: Text(s.title),
                  trailing: ElevatedButton(
                    child: const Text('Open Story'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryScreen(story: s)));
                    },
                  ),
                );
              },
            ),
    );
  }
}
