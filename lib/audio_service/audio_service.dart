// ignore: unused_import
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import 'audio_service_stub.dart'
    if (dart.library.js_interop) 'audio_service_web.dart'
    if (dart.library.io) 'audio_service_mobile.dart'
    as platform;

abstract class AudioService {

  AudioPlayer get player;

  // Playback controls
  Future<void> setAudioSource(String path, {bool autoplay = false});
  Future<void> play();
  Future<void> pause();
  Future<void> stop();

  // Lifecycle
  Future<void> release();
  void dispose();
  void disposeAllInstances();

}

/// Factory functions implemented in platform-specific files:
/// 
/// Get the global AudioService class or create one if it doesn't exist yet 
AudioService getAudioService(String? playerId) => platform.getAudioService(playerId);

/// Get all active instances of the AudioService class created
Set<AudioService> getAudioInstances() => platform.getAudioInstances();