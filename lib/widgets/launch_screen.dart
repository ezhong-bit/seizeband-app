import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seize_appios/screens/home_screen.dart';
import 'package:seize_appios/screens/start_screen.dart';  // your onboarding screen

class LaunchScreen extends StatefulWidget {
   const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  bool? _seenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;
    setState(() {
      _seenOnboarding = seen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_seenOnboarding == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_seenOnboarding == false) {
      return GettingStartedScreen(
        onContinue: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('seenOnboarding', true);
          setState(() {
            _seenOnboarding = true;
          });
        },
      );
    }

    return const HomeScreen();
  }
}
