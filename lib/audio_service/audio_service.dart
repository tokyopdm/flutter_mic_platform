// ignore: unused_import
import 'dart:async';

import 'audio_service_stub.dart'
    if (dart.library.js_interop) 'audio_service_web.dart'
    if (dart.library.io) 'audio_service_mobile.dart'
    as platform;

abstract class AudioService {
  // State getters
  bool get isPlaying;
  bool get isPaused;
  bool get isStopped;
  Duration get currentPosition;
  Duration get totalDuration;
  String? get currentSource;
  
  // State streams for reactive updates
  Stream<bool> get onPlayingStateChanged;
  Stream<bool> get onPausedStateChanged;
  Stream<Duration> get onPositionChanged;
  Stream<Duration> get onDurationChanged;
  Stream<void> get onPlayerComplete;
  Stream<String?> get onSourceChanged;
  //StreamSubscription<dynamic>? get onLogStreamSubscription;
  
  
  // Playback controls
  Future<void> setSource(String path);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  
  // Lifecycle
  Future<void> release();
  void dispose();
}

// Factory function implemented in platform-specific files
AudioService createAudioService() => platform.createAudioService();