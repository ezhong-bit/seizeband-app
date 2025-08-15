import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:audio_service/audio_service.dart';
import '../widgets/audio_handler_single.dart';
import '../screens/audio_test_screen.dart';
import 'package:geolocator/geolocator.dart';

class MonitoringService {
  static final MonitoringService _instance = MonitoringService._internal();
  factory MonitoringService() => _instance;
  MonitoringService._internal();

  AlertAudioHandler? _audioHandler;

  Timer? _pollingTimer;
  Timer? _heartbeatTimer;
  Timer? _instructionTimer;
  String? _userName;
  DateTime? _lastHeartbeat;
  String? _lastAudioState;

  Future<void> init() async {
    _audioHandler = await AudioHandlerSingleton.init() as AlertAudioHandler;

    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name');

    if (_userName != null && _userName!.isNotEmpty) {
      _startMonitoring();
    } else {
      print('No username found. Monitoring not started.');
    }
  }

  void _startMonitoring() {
    print('📡 Monitoring started for $_userName');

    _pollingTimer?.cancel();
    _heartbeatTimer?.cancel();

    _pollingTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      await _pollAudioState();
      await _sendHeartbeat();
    });

    _heartbeatTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (_lastHeartbeat == null || DateTime.now().difference(_lastHeartbeat!).inSeconds > 15) {
        print("⚠️ Heartbeat timeout — app may not be running properly.");
      }
    });
  }

  Future<void> _sendLocationToBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name');
      if (userName == null || userName.isEmpty) return;

      final position = await Geolocator.getCurrentPosition();
      final latitude = position.latitude;
      final longitude = position.longitude;

      final response = await http.post(
        Uri.parse('https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/set-location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': userName,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        print("📍 Location sent to backend");
      } else {
        print("❌ Failed to send location: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending location: $e");
    }
  }

Future<void> _pollAudioState() async {
    try {
      final url = Uri.parse("https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/audio-state/$_userName");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final state = jsonDecode(response.body)["audio_state"];
        if (state == "alarm") {
          await _audioHandler?.playUrl('https://raw.githubusercontent.com/ezhong-bit/seizeband-audio-host/main/alert_sound.mp3');
        } else if (state == "instruction") {
          await _audioHandler?.playUrl('https://raw.githubusercontent.com/ezhong-bit/seizeband-audio-host/main/instructions.mp3');
        } else {
          await _audioHandler?.stop();
        }
      }
    } catch (e) {
      print("Polling error: $e");
    }
  }

 /*       final newState = jsonDecode(response.body)["audio_state"];

        if (newState != _lastAudioState) {
          print("🔄 Audio state changed: $_lastAudioState ➡️ $newState");

          if (newState == "alarm") {
          // Stop any prior instruction timer
          _instructionTimer?.cancel();
          await _sendLocationToBackend();
          await _audioHandler?.playUrl('https://raw.githubusercontent.com/ezhong-bit/seizeband-audio-host/main/alert_sound.mp3');
        } else if (newState == "instruction") {
          _instructionTimer?.cancel(); // Prevent overlap
          await _audioHandler?.playUrl('https://raw.githubusercontent.com/ezhong-bit/seizeband-audio-host/main/audio_instructions.mp3');
            
            _instructionTimer = Timer(Duration(minutes: 2), () async {
            print("⏹️ Instruction audio timeout reached. Stopping playback.");
            await _audioHandler?.stop();
          });
          } else {
          _instructionTimer?.cancel(); // Cancel timer if state changes
          await _audioHandler?.stop();
        }
        _lastAudioState = newState;
        }
      }
    } catch (e) {
      print("Polling error: $e");
    }
  }
*/

  Future<void> _sendHeartbeat() async {
    try {
      final url = Uri.parse("https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/heartbeat");
      await http.post(url,
          body: jsonEncode({"user_name": _userName}),
          headers: {"Content-Type": "application/json"});
      _lastHeartbeat = DateTime.now();
      print("💓 Heartbeat sent");
    } catch (e) {
      print("Heartbeat error: $e");
    }
  }

  void stopMonitoring() {
    _pollingTimer?.cancel();
    _heartbeatTimer?.cancel();
    _audioHandler?.stop();
  }
}
