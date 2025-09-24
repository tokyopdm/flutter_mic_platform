import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'audio_service.dart';

class _StubAudioService implements AudioService {
  
  @override
  AudioPlayer get player => throw UnsupportedError('Platform not supported');

  @override
  Future<void> play() => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> setAudioSource(String path, {bool autoplay = false}) => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> pause() => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> stop() => throw UnsupportedError('Platform not supported');
  
  //@override
  //Future<void> release() => throw UnsupportedError('Platform not supported');
  
  @override
  void dispose() => throw UnsupportedError('Platform not supported');
  
  @override
  void disposeAllInstances() => throw UnsupportedError('Platform not supported');
  
}


/// These methods expose the public getters from the private class to the AudioService umbrella class
AudioService getAudioService(String? playerId) => _StubAudioService();
AudioPlayer getAudioPlayer() => throw UnsupportedError('Platform not supported'); // _StubAudioService().player;
Set<AudioService> getAudioInstances() => throw UnsupportedError('Platform not supported');