import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
// `HomeScreen` is loaded from the splash flow; avoid unused import

void main() {
  runApp(const StoryNestApp());
}

class StoryNestApp extends StatelessWidget {
  const StoryNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryNest Reader',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const SplashScreen(),
    );
  }
}
