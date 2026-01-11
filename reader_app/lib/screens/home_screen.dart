import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/pack_manifest.dart';
import '../models/story_manifest.dart';
import 'story_screen.dart';
import 'pack_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PackManifest> packs = [];

  @override
  void initState() {
    super.initState();
    _loadPacks();
  }

  Future<void> _loadPacks() async {
    final packPaths = [
      'assets/manifests/pack1_manifest.json',
      'assets/manifests/pack2_manifest.json'
    ];
    final loaded = <PackManifest>[];
    for (final p in packPaths) {
      try {
        final jsonStr = await rootBundle.loadString(p);
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        loaded.add(PackManifest.fromJson(json));
      } catch (_) {}
    }
    setState(() => packs = loaded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StoryNest')),
      body: packs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: packs.length,
              itemBuilder: (context, idx) {
                final p = packs[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(p.title),
                    subtitle: Text('Stories: ${p.storyCount}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PackScreen(packAssetPath: 'assets/manifests/${p.id}_manifest.json')));
                      },
                      child: const Text('Open Story Pack'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
