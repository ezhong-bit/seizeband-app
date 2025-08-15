import 'package:audio_service/audio_service.dart';
import '../screens/audio_test_screen.dart'; // <- make sure this is your custom handler

class AudioHandlerSingleton {
  static AudioHandler? _instance;

  static Future<AudioHandler> init() async {
    if (_instance != null) return _instance!;

    _instance = await AudioService.init(
      builder: () => AlertAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'alert_sound_channel',
        androidNotificationChannelName: 'Alert Sound',
        androidNotificationOngoing: true,
      ),
    );

    return _instance!;
  }

  static AudioHandler get instance {
    if (_instance == null) {
      throw Exception("AudioHandler not initialized. Call init() first.");
    }
    return _instance!;
  }
}
