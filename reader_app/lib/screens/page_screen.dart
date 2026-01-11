import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
// Audio playback plugin: using `just_audio` for cross-platform playback.
import '../models/story_manifest.dart';
import 'settings_screen.dart';
import '../utils/audio_utils.dart' as audio_utils;

class PageScreen extends StatefulWidget {
  final StoryManifest story;
  final int pageIndex;
  final bool forceAudioAvailable;
  final int? forceDurationMs;

  const PageScreen({super.key, required this.story, this.pageIndex = 0, this.forceAudioAvailable = false, this.forceDurationMs});

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  late int index;
  AudioPlayer? _player;
  bool _isPlaying = false;
  bool _audioAvailable = false;
  StreamSubscription? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  Duration _position = Duration.zero;
  Duration? _duration;
  // audio player removed; show placeholder behavior for Play button.

  @override
  void initState() {
    super.initState();
    index = widget.pageIndex;
    // Allow tests to force audio state without initializing real audio.
    if (widget.forceAudioAvailable) {
      _audioAvailable = true;
      _duration = Duration(milliseconds: widget.forceDurationMs ?? 5000);
      _position = Duration.zero;
    } else {
      _initAudioForPage();
    }
  }

  Future<void> _initAudioForPage() async {
    final page = widget.story.pages[index];
    final audio = page.audio;
    if (audio == null || audio.isEmpty) {
      if (mounted) setState(() => _audioAvailable = false);
      return;
    }
    try {
      _player = AudioPlayer();
      // Subscribe to position and duration updates for the progress UI.
      _positionSub = _player!.positionStream.listen((p) {
        if (!mounted) return;
        setState(() => _position = p);
      });
      _durationSub = _player!.durationStream.listen((d) {
        if (!mounted) return;
        setState(() => _duration = d);
      });
      // Listen to player state so UI reflects actual playing status.
      _playerStateSub = _player!.playerStateStream.listen((ps) {
        final playing = ps.playing;
        if (!mounted) return;
        setState(() {
          _isPlaying = playing;
        });
      });
      if (audio == 'local:sample') {
        // Generate a short sample WAV file and play it.
        final file = await audio_utils.generateLocalSampleWav();
        await _player!.setFilePath(file.path);
        if (mounted) setState(() => _audioAvailable = true);
      } else if (audio.startsWith('http')) {
        await _player!.setUrl(audio);
        if (mounted) setState(() => _audioAvailable = true);
      } else {
        // Try as asset path. Verify asset exists in bundle first to provide
        // a clearer error message if it's missing.
        // Load asset bytes from bundle and write to a temporary file, then
        // play from that file. This avoids `just_audio` "zero-length source"
        // errors that can occur with certain APK packaging/compression cases.
        ByteData bd;
        try {
          bd = await rootBundle.load(audio);
        } catch (e) {
          throw Exception('Asset not found in bundle: $audio');
        }
        final bytes = bd.buffer.asUint8List();
        final tmpDir = Directory.systemTemp;
        final ext = audio.contains('.') ? audio.split('.').last : 'mp3';
        final tmpFile = File('${tmpDir.path}/storynest_asset_${DateTime.now().millisecondsSinceEpoch}.$ext');
        await tmpFile.writeAsBytes(bytes, flush: true);
        await _player!.setFilePath(tmpFile.path);
        if (mounted) setState(() => _audioAvailable = true);
      }
      // Start playback after source set. Update playing state when started.
      await _player!.play();
      if (!mounted) return;
      setState(() => _isPlaying = true);
    } catch (e, st) {
      // If audio fails, dispose and continue silently.
      await _player?.dispose();
      _player = null;
      if (!mounted) return;
      debugPrint('Audio init error for page $index: $e\n$st');
      setState(() {
        _isPlaying = false;
        _audioAvailable = false;
      });
    }
  }

  


  // audio init removed

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player?.dispose();
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

    Widget imageWidget;
    if (image != null && image == 'sample:flower') {
      imageWidget = Icon(Icons.local_florist, size: 160, color: Theme.of(context).colorScheme.primary);
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
                icon: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha((0.18 * 255).round()),
                        child: Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary),
                      ),
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
            // Progress row: current seconds, seek slider, total seconds
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: index > 0 ? () => _goToPage(index - 1) : null,
                  child: const Text('Prev'),
                ),
                ElevatedButton(
                  onPressed: (_audioAvailable || _isPlaying)
                      ? () async {
                          if (_isPlaying) {
                            await _player!.pause();
                            setState(() {
                              _isPlaying = false;
                            });
                          } else {
                            await _player!.play();
                            setState(() {
                              _isPlaying = true;
                            });
                          }
                        }
                      : null,
                  child: Text(_isPlaying ? 'Pause' : 'Play'),
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
