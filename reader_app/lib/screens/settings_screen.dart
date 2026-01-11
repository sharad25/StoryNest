import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Privacy Notice'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('License'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LicenseScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.emoji_people),
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

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied $text')));
  }

  @override
  Widget build(BuildContext context) {
    const suggestionEmail = 'suggestions@storynest.example';
    const feedbackEmail = 'feedback@storynest.example';
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Contact us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: const Text('Suggest a new story'),
              subtitle: const Text(suggestionEmail),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copy(context, suggestionEmail),
              ),
              onTap: () => _copy(context, suggestionEmail),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('App feedback'),
              subtitle: const Text(feedbackEmail),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copy(context, feedbackEmail),
              ),
              onTap: () => _copy(context, feedbackEmail),
            ),
          ],
        ),
      ),
    );
  }
}
