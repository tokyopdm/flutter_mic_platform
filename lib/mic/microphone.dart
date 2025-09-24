import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class MicrophoneApp extends StatefulWidget {
  const MicrophoneApp({super.key});

  @override
  State<MicrophoneApp> createState() => _MicrophoneAppState();
}

class _MicrophoneAppState extends State<MicrophoneApp> {
  bool showPlayer = false;
  String? _playerId;
  String? _audioPath;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microphone App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Microphone Recorder'),
        ),
        body: Center(
          child: showPlayer
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: MicPlayer(
                    playerId: _playerId!,
                    source: _audioPath!,
                    onDelete: () {
                      // TODO: delete the blob from the window
                      debugPrint('Delete button pressed');
                      setState(() => showPlayer = false);
                    },
                    onSend: () => debugPrint('Send button pressed'),
                  ),
                )
              : MicRecorder(
                  onStop: (path) {
                    if (kDebugMode) print('Recorded file path: $path');
                    setState(() {
                      _playerId = DateTime.now().toString();
                      _audioPath = path;
                      showPlayer = true;
                    });
                  },
                ),
        ),
      ),
    );
  }
}