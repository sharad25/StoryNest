import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4C6EF5), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text('StoryNest', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Developer ABC', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                        onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen())),
                        child: const Text('Start', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.settings),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
