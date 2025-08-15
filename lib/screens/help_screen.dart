import 'package:flutter/material.dart';
import 'package:seize_appios/seizure_alert_system.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/simple_button.dart';
import '../screens/audio_test_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _chatIdController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('user_name') ?? '';
    final savedChatId = prefs.getString('telegram_chat_id') ?? '';

    _usernameController.text = savedUsername;
    _chatIdController.text = savedChatId;

    setState(() => _isLoading = false);
  }

  Future<void> _saveUserData() async {
    final newUsername = _usernameController.text.trim();
    final newChatId = _chatIdController.text.trim();

    if (newUsername.isEmpty || newChatId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Chat ID cannot be empty')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUsername);
    await prefs.setString('telegram_chat_id', newChatId);

    // 🔁 Send updated info to backend
    try {
      final response = await http.post(
        Uri.parse('https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/register-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': newUsername,
          'chat_id': newChatId,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update backend: ${response.body}')),
        );
      }
    } catch (e) {
      print('❌ Error updating backend: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    }
  }

  Future<void> _resetAppData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App data reset! Restart app to see onboarding.')),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Instructions for connecting your emergency contacts:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'To make sure your emergency contacts get notified after a seizure detection, please have them follow these steps:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const Text('1. Download the Telegram app from the App Store or Google Play.'),
              const SizedBox(height: 6),
              const Text('2. Search for our bot: @SeizureBandAlertBot'),
              const SizedBox(height: 6),
              const Text('3. Open a chat with the bot and click "Start" or send "Hi" to begin.'),
              const SizedBox(height: 12),
              const Text(
                'Make sure your contacts do this so they can get seizure alerts when needed.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _chatIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Your Telegram Chat ID',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveUserData,
                child: const Text('Save Name & Chat ID'),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _resetAppData(context),
                child: const Text('Reset App Data (for testing)'),
              ),

              const SizedBox(height: 40),
              SimpleRoundedButton(
                icon: Icons.audio_file,
                label: 'Test audio',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AudioTestScreen(),
                    ),
                  );
                },
              ),

              SimpleRoundedButton(
                label: 'Seizure HTTP post test',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeizureMonitoringScreen(),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
