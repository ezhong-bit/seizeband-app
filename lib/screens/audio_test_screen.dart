import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/simple_button.dart';
import 'package:flutter/services.dart' show rootBundle;

/// This screen is for testing alert audio playback
class AudioTestScreen extends StatefulWidget {
  const AudioTestScreen({super.key});

  @override
  State<AudioTestScreen> createState() => _AudioTestScreenState();
}

class _AudioTestScreenState extends State<AudioTestScreen> {
  late final AudioHandler _audioHandler;


void checkAsset() async {
  try {
    final data = await rootBundle.load('assets/sounds/alert_sound.mp3');
    print('Asset loaded successfully, size: ${data.lengthInBytes}');
  } catch (e) {
    print('Asset load failed: $e');
  }
}
  
  @override
  void initState() {
    super.initState();
    checkAsset();
    _initAudioHandler();
  }

  Future<void> _initAudioHandler() async {
    _audioHandler = await AudioService.init(
      builder: () => AlertAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'alert_sound_channel',
        androidNotificationChannelName: 'Alert Sound',
        androidNotificationOngoing: true,
      ),
    );
  }

  @override
  void dispose() {
    _audioHandler.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert Audio Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SimpleRoundedButton(
              label: 'Start Alert Sound',
              icon: Icons.volume_up,
              backgroundColor: Colors.red[100],
              onTap: () async {
                try {
                  await _audioHandler.play();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playing alert sound')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error playing sound: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            SimpleRoundedButton(
              label: 'Stop Alert Sound',
              icon: Icons.stop_circle,
              backgroundColor: Colors.grey[300],
              onTap: () async {
                try {
                  await _audioHandler.stop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Stopped alert sound')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error stopping sound: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The new AudioHandler that uses just_audio internally
class AlertAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  AlertAudioHandler() {
    _init();
  }

  Future<void> playUrl(String url) async {
    try {
      await _player.setUrl(url);
      _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

/*
class AlertAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  AlertAudioHandler() {
    _init();
  }

*/

Future<void> _init() async {
  try {
    await _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
//    await _player.setAudioSource(
//      AudioSource.asset('assets/sounds/alert_sound.mp3'),

    _player.setLoopMode(LoopMode.one);

    _player.playerStateStream.listen((playerState) {
      playbackState.add(_transformEvent(playerState));
    });
  } catch (e) {
    // You can also log or handle errors here
    debugPrint('Error loading audio asset: $e');
  }
}

  PlaybackState _transformEvent(PlayerState playerState) {
    return PlaybackState(
      controls: [
        MediaControl.pause,
        MediaControl.stop,
        MediaControl.play,
      ],
      systemActions: const {
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.play,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[playerState.processingState]!,
      playing: playerState.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: null,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop(); // Just stop playback
    return super.stop();
  }
}