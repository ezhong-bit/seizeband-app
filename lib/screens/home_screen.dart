import 'package:flutter/material.dart';
import '../widgets/rounded_button.dart';
import 'history_screen.dart';
import 'emergency_screen.dart';
import 'help_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'audio_test_screen.dart';
// import '../widgets/simple_button.dart';
// import 'package:seize_appios/alert_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Seize Band',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    RoundedButton(
                      icon: Icons.history,
                      label: 'Activity History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                    RoundedButton(
                      icon: Icons.phone_forwarded,
                      label: 'Emergency Contacts',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmergencyScreen(),
                          ),
                        );
                      },
                    ),
                    RoundedButton(
                      icon: Icons.help_outline,
                      label: 'Help and Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpScreen(),
                          ),
                        );
                      },
                    ),
                    RoundedButton(
                      icon: Icons.rss_feed,
//wifi, phonelink_ring_rounded, contactless_outlined, link, rss_feed
                      label: 'Connect Device',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connect Device tapped'),
                          ),
                        );
                      },
                    ),

/*                    SimpleRoundedButton(
                      label: 'List Test', 
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListScreen(),
                          )
                        );
                      },
                    )
*/                ],
                ),
              ),
              const SizedBox(height: 16),
              RoundedButton(
                icon: Icons.not_interested,
                label: '  Manual Override',
                subtitle: 'False alarm',
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userName = prefs.getString('user_name');

                  if (userName == null || userName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Username not found. Please log in again.')),
                    );
                    return;
                  }

                  try {
                    final url = Uri.parse("https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/manual-override");
                    final response = await http.post(
                      url,
                      body: jsonEncode({"user_name": userName}),
                      headers: {"Content-Type": "application/json"},
                    );

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Manual override sent successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❌ Failed to send manual override')),
                      );
                    }
                  } catch (e) {
                    print("Error sending manual override: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('⚠️ Error sending manual override')),
                    );
                  }
                },
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
