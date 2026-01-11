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
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (pack?.description != null && pack!.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(pack!.description!, style: const TextStyle(fontSize: 16)),
                  ),
                ...stories.map((s) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(s.title),
                        trailing: ElevatedButton(
                          child: const Text('Open Story'),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryScreen(story: s)));
                          },
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
