/*  Future<void> _sendSeizureAlert() async {
  final prefs = await SharedPreferences.getInstance();
  final userName = prefs.getString('user_name');

  if (userName == null || userName.isEmpty) {
    print("Username not found.");
    return;
  }

  try {
    // 🔹 Get location first
    final position = await Geolocator.getCurrentPosition();
    final latitude = position.latitude;
    final longitude = position.longitude;

    // 🔹 Send location to backend
    await http.post(
      Uri.parse('$backendBaseUrl/set-location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': userName,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    // 🔹 Now send the seizure alert
    final timestamp = DateTime.now().toIso8601String();
    await http.post(
      Uri.parse('$backendBaseUrl/api/seizure-alert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': userName,
        'timestamp': timestamp,
      }),
    );

    print("🚨 Seizure alert sent successfully.");

  } catch (e) {
    print("Error sending seizure alert: $e");
  }
}*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class SeizureMonitoringScreen extends StatefulWidget {
  const SeizureMonitoringScreen({super.key});

  @override
  _SeizureMonitoringScreenState createState() => _SeizureMonitoringScreenState();
}

class _SeizureMonitoringScreenState extends State<SeizureMonitoringScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserName = prefs.getString('user_name');
    if (savedUserName != null && savedUserName.isNotEmpty) {
      setState(() {
        userName = savedUserName;
      });
    } else {
      print('Username not found in SharedPreferences');
    }
  }

  Future<void> sendManualOverride(String userName) async {
    try {
      final url = Uri.parse("https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/manual-override");
      final response = await http.post(
        url,
        body: jsonEncode({"user_name": userName}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Manual override sent successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send manual override.")),
        );
      }
    } catch (e) {
      print("Error sending manual override: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending manual override.")),
      );
    }
  }

  Future<void> triggerTestSeizureAlert(String userName) async {
    final url = Uri.parse("https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/api/seizure-alert");

    final payload = {
      "user_name": userName,
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🔥 Test seizure alert triggered")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to trigger alert")),
        );
      }
    } catch (e) {
      print("Error triggering seizure alert: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error triggering test alert")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seizure Monitoring - ${userName ?? "Loading..."}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: userName == null
                  ? null
                  : () => sendManualOverride(userName!),
              child: Text("Manual Override / False Alarm"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: userName == null
                  ? null
                  : () => triggerTestSeizureAlert(userName!),
              child: Text("🔥 Trigger Test Seizure Alert"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/* import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/audio_test_screen.dart';
import '../widgets/audio_handler_single.dart';


class SeizureMonitoringScreen extends StatefulWidget {

  const SeizureMonitoringScreen({super.key});

  @override
  _SeizureMonitoringScreenState createState() => _SeizureMonitoringScreenState();
}

class _SeizureMonitoringScreenState extends State<SeizureMonitoringScreen> {
  AlertAudioHandler? _audioHandler;
  Timer? pollingTimer;
  String? userName;
  DateTime? lastHeartbeatTime;
  Timer? heartbeatCheckTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initAudioHandler();
    await _loadUserName();
  }

  Future<void> _initAudioHandler() async {
    _audioHandler = await AudioHandlerSingleton.init() as AlertAudioHandler;
  }


  @override
  void dispose() {
    pollingTimer?.cancel();
    _audioHandler?.stop();    heartbeatCheckTimer?.cancel();
    super.dispose();
  }


    Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserName = prefs.getString('user_name');
    if (savedUserName != null && savedUserName.isNotEmpty) {
      setState(() {
        userName = savedUserName;
      });
      startPolling(savedUserName);
    } else {
      print('Username not found in SharedPreferences');
      // Optionally: show error UI or redirect
    }
  }

  Future<void> pollAudioState(String userName) async {
    try {
      final url = Uri.parse(
          "https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/audio-state/$userName");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final state = jsonDecode(response.body)["audio_state"];
        if (state == "alarm") {
          await playAlarm();
        } else if (state == "instruction") {
          await playInstruction();
        } else {
          await stopAudio();
        }
      }
    } catch (e) {
      print("Error polling audio state: $e");
    }
  }

  void startPolling(String userName) {
    pollingTimer?.cancel();
    pollingTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      await pollAudioState(userName);
      await sendHeartbeat(userName);

            heartbeatCheckTimer?.cancel();
      heartbeatCheckTimer = Timer.periodic(Duration(seconds: 5), (_) {
        if (lastHeartbeatTime == null || DateTime.now().difference(lastHeartbeatTime!).inSeconds > 15) {
          // Show a warning to user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Seize Band app might not be running properly. Please keep it open and enable background activity.",
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      });


    });
  }

  Future<void> sendHeartbeat(String userName) async {
    try {
      final url = Uri.parse("https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/heartbeat");
      await http.post(url,
          body: jsonEncode({"user_name": userName}),
          headers: {"Content-Type": "application/json"});
          lastHeartbeatTime = DateTime.now();
      print("Heartbeat sent");
    } catch (e) {
      print("Error sending heartbeat: $e");
    }
  }

  Future<void> sendManualOverride(String userName) async {
    try {
      final url = Uri.parse("https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/manual-override");
      final response = await http.post(url,
          body: jsonEncode({"user_name": userName}),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Manual override sent successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send manual override.")),
        );
      }
    } catch (e) {
      print("Error sending manual override: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending manual override.")),
      );
    }
  }

  Future<void> triggerTestSeizureAlert(String userName) async {
  final url = Uri.parse("https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/api/seizure-alert");

  final payload = {
    "user_name": userName,
    "timestamp": DateTime.now().toIso8601String(),
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🔥 Test seizure alert triggered")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to trigger alert")),
      );
    }
  } catch (e) {
    print("Error triggering seizure alert: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error triggering test alert")),
    );
  }
}


  Future<void> playAlarm() async {
    if (_audioHandler == null) return;
    await _audioHandler!.playUrl(
      'https://raw.githubusercontent.com/ezhong-bit/seizeband-audio-host/main/alert_sound.mp3',
    );
  }

  Future<void> playInstruction() async {
    if (_audioHandler == null) return;
    await _audioHandler!.playUrl(
      'https://raw.githubusercontent.com/ezhong-bit/seizeband-audio-host/main/audio_instructions.mp3',
    );
  }

  Future<void> stopAudio() async {
    await _audioHandler!.stop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seizure Monitoring - ${userName}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: userName == null
                  ? null
                  : () => sendManualOverride(userName!),
              child: Text("Manual Override / False Alarm"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: userName == null
                  ? null
                  : () => triggerTestSeizureAlert(userName!),
              child: Text("🔥 Trigger Test Seizure Alert"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
*/