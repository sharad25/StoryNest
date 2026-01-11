import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';

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
  AudioPlayer? _player;
  bool _isPlaying = false;
  bool _audioAvailable = false;
  StreamSubscription? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  Duration _position = Duration.zero;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _loadPack();
  }

  Future<void> _initAudio() async {
    const audio = 'assets/audio/sample_audio_narration_1.mp3';
    try {
      _player = AudioPlayer();
      _positionSub = _player!.positionStream.listen((p) {
        if (!mounted) return;
        setState(() => _position = p);
      });
      _durationSub = _player!.durationStream.listen((d) {
        if (!mounted) return;
        setState(() => _duration = d);
      });
      _playerStateSub = _player!.playerStateStream.listen((ps) {
        final playing = ps.playing;
        if (!mounted) return;
        setState(() => _isPlaying = playing);
      });

      // load asset bytes to temp file then play
      final bd = await rootBundle.load(audio);
      final bytes = bd.buffer.asUint8List();
      final tmpDir = Directory.systemTemp;
      final tmpFile = File('${tmpDir.path}/storynest_pack_asset_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await tmpFile.writeAsBytes(bytes, flush: true);
      await _player!.setFilePath(tmpFile.path);
      if (mounted) setState(() => _audioAvailable = true);
      await _player!.play();
    } catch (e, st) {
      debugPrint('Pack audio init error: $e\n$st');
      await _player?.dispose();
      _player = null;
      if (!mounted) return;
      setState(() => _audioAvailable = false);
    }
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
    // Start pack narration audio after pack is loaded.
    _initAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pack?.title ?? 'Story Pack'),
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
      body: pack == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (pack?.description != null && pack!.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Text(pack!.description!, style: const TextStyle(fontSize: 16))),
                              const SizedBox(width: 12),
                              if (pack?.image != null && pack!.image == 'sample:flower')
                                Icon(Icons.local_florist, size: 48, color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ),
                      ...stories.map((s) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(s.title),
                              trailing: ElevatedButton(
                                child: const Text('Open Story'),
                                onPressed: () {
                                  // Pause pack narration when opening a story.
                                  try {
                                    _player?.pause();
                                  } catch (_) {}
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => StoryScreen(story: s)));
                                },
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                // Bottom controls: progress + play/pause similar to story pages
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.0)]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text('${_position.inSeconds}s'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              min: 0.0,
                              max: (_duration?.inMilliseconds ?? 0).toDouble().clamp(1.0, double.infinity),
                              value: (_duration != null)
                                  ? _position.inMilliseconds.clamp(0, _duration!.inMilliseconds).toDouble()
                                  : 0.0,
                              onChanged: (_audioAvailable && _duration != null)
                                  ? (v) {
                                      setState(() => _position = Duration(milliseconds: v.round()));
                                    }
                                  : null,
                              onChangeEnd: (_audioAvailable && _duration != null)
                                  ? (v) async {
                                      await _player?.seek(Duration(milliseconds: v.round()));
                                    }
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${_duration?.inSeconds ?? 0}s'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: (_audioAvailable || _isPlaying)
                                ? () async {
                                    if (_isPlaying) {
                                      await _player?.pause();
                                    } else {
                                      await _player?.play();
                                    }
                                  }
                                : null,
                            child: Text(_isPlaying ? 'Pause' : 'Play'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player?.dispose();
    super.dispose();
  }
}
