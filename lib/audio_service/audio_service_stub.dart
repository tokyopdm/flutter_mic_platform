import 'dart:async';
import 'audio_service.dart';

class _StubAudioService implements AudioService {
  @override
  bool get isPlaying => throw UnsupportedError('Platform not supported');
  
  @override
  bool get isPaused => throw UnsupportedError('Platform not supported');
  
  @override
  bool get isStopped => throw UnsupportedError('Platform not supported');
  
  @override
  Duration get currentPosition => throw UnsupportedError('Platform not supported');
  
  @override
  Duration get totalDuration => throw UnsupportedError('Platform not supported');
  
  @override
  String? get currentSource => throw UnsupportedError('Platform not supported');
  
  @override
  Stream<bool> get onPlayingStateChanged => throw UnsupportedError('Platform not supported');
  
  @override
  Stream<bool> get onPausedStateChanged => throw UnsupportedError('Platform not supported');
  
  @override
  Stream<Duration> get onPositionChanged => throw UnsupportedError('Platform not supported');
  
  @override
  Stream<Duration> get onDurationChanged => throw UnsupportedError('Platform not supported');
  
  @override
  Stream<void> get onPlayerComplete => throw UnsupportedError('Platform not supported');
  
  @override
  Stream<String?> get onSourceChanged => throw UnsupportedError('Platform not supported');
  
  //@override
  //StreamSubscription<dynamic>? get onLogStreamSubscription => throw UnsupportedError('Platform not supported');

  @override
  Future<void> setSource(String path) => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> play() => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> pause() => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> stop() => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> seek(Duration position) => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> setVolume(double volume) => throw UnsupportedError('Platform not supported');
  
  @override
  Future<void> release() => throw UnsupportedError('Platform not supported');
  
  @override
  void dispose() => throw UnsupportedError('Platform not supported');
}

AudioService createAudioService() => _StubAudioService();
