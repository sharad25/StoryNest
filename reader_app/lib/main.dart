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
    final primary = const Color(0xFF7C3AED);
    final accent = const Color(0xFFFFB4D6);
    final cream = const Color(0xFFF6F0FF);
    final colorScheme = ColorScheme.fromSeed(seedColor: primary).copyWith(primary: primary, secondary: accent, surface: cream);
    return MaterialApp(
      title: 'StoryNest Reader',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        cardColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      home: const SplashScreen(),
    );
  }
}
