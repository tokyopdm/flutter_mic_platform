import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio_button.dart';
import '../audio_service/audio_service_provider.dart';
import 'mic_recorder.dart';
import 'mic_player.dart';

/*
void main() => runApp(
  // Wrap the app with ProviderScope for Riverpod
  const ProviderScope(
    child: MicrophoneApp(),
  ),
);
*/

class MicrophoneApp extends ConsumerStatefulWidget {
  const MicrophoneApp({super.key});

  @override
  ConsumerState<MicrophoneApp> createState() => _MicrophoneAppState();
}

class _MicrophoneAppState extends ConsumerState<MicrophoneApp> {
  bool showPlayer = false;
  String? _timestamp;
  String? _audioPath;
  String? _playerId;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Microphone App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Microphone Recorder'),
          centerTitle: true,
          actions: [
            AudioPlayerButton(
              key: ValueKey(_playerId), // Triggers a rebuild when the _playerId value changes onSend
              id: _playerId,
              onPressed: _handleAudioButtonPress
            ),
            SizedBox(width: 4,)
          ],
        ),
        body: Center(
          child: showPlayer
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: MicPlayer(
                    timestamp: _timestamp!,
                    source: _audioPath!,
                    onDelete: () {
                      debugPrint('Delete button pressed');
                      setState(() => showPlayer = false);
                    },
                    onSend: (playerId) => _handleOnSendButtonPressed(playerId),
                  ),
                )
              : MicRecorder(
                  onStop: (path) {
                    if (kDebugMode) print('Recorded file path: $path');
                    setState(() {
                      _timestamp = DateTime.now().toString();
                      _audioPath = path;
                      showPlayer = true;
                    });
                  },
                ),
        ),
      ),
    );
  }
  
  void _handleOnSendButtonPressed(String playerId) async {
    debugPrint('Send button pressed');

    final String? currentPlayerId = _playerId;
    final String newPlayerId = playerId;

    if (currentPlayerId != null) {
      final buttonAudio = ref.read(audioServiceInstanceProvider(currentPlayerId));
      
      debugPrint('Releasing audioplayer...');
      await buttonAudio.release();

      debugPrint('Clearing playerId $currentPlayerId from ButtonAudio state...');
    }
    
    /// Set the playerID returned by the mic_player onSend callback to _playerId
    /// So it's passed to the AudioPlayerButton widget
    debugPrint('Passing playerId $newPlayerId to AudioPlayerButton widget...');
    setState(() {
      _playerId = newPlayerId;
    });

    resetMicrophone();
  }

  Future<void> _handleAudioButtonPress() async {
    debugPrint('Audio Player button pressed');
    if (mounted) {
      if (_playerId != null) {
        debugPrint('Retrieving AudioService instance for playerId $_playerId');
        final buttonAudio = ref.read(audioServiceInstanceProvider(_playerId));
        await buttonAudio.play();
      } else {
        await Future.delayed(Duration(milliseconds: 100));
        debugPrint('Button audio has not been set');
      }
    }
  }

  void resetMicrophone() {
    debugPrint('Resetting microphone...');
    if (mounted) {
      setState(() {
        showPlayer = false;
        _timestamp = null;
        _audioPath = null;
        
      });
      debugPrint('Mic memory cleared: timestamp = $_timestamp, audioPath = $_audioPath');
    }
  }
}