import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Notice'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('License'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LicenseScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Notice')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Privacy Notice\n\nThis is sample privacy text. No data is collected in this prototype. Replace with your project privacy policy.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('License')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'License\n\nThis project is provided as an example. Add your license text here (e.g., MIT, Apache 2.0).',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'About\n\nStoryNest reader prototype\nVersion: 0.1.0\nDeveloper: Developer ABC\n\nThis is sample about text.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
