// ignore: unused_import
import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'audio_service.dart';

class _MobileAudioService implements AudioService {
  final AudioPlayer _player = AudioPlayer();
  String? _currentSource;
  
  // Stream controllers for custom streams
  final StreamController<bool> _playingController = StreamController.broadcast();
  final StreamController<bool> _pausedController = StreamController.broadcast();
  final StreamController<String?> _sourceController = StreamController.broadcast();
  
  _MobileAudioService() {
    _setupListeners();
  }
  
  void _setupListeners() {
    // Listen to player state changes and emit to our custom streams
    _player.onPlayerStateChanged.listen((state) {
      _playingController.add(state == PlayerState.playing);
      _pausedController.add(state == PlayerState.paused);
    });
  }
  
  @override
  bool get isPlaying => _player.state == PlayerState.playing;
  
  @override
  bool get isPaused => _player.state == PlayerState.paused;
  
  @override
  bool get isStopped => _player.state == PlayerState.stopped;
  
  @override
  Duration get currentPosition => Duration.zero; // Would need to be fetched async
  
  @override
  Duration get totalDuration => Duration.zero; // Would need to be fetched async
  
  @override
  String? get currentSource => _currentSource;
  
  // Stream getters that delegate to audioplayers streams
  @override
  Stream<bool> get onPlayingStateChanged => _playingController.stream;
  
  @override
  Stream<bool> get onPausedStateChanged => _pausedController.stream;
  
  @override
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  
  @override
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;
  
  @override
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;
  
  @override
  Stream<String?> get onSourceChanged => _sourceController.stream;
  
  @override
  Future<void> setSource(String path) async {
    _currentSource = path;
    _sourceController.add(path);
    
    if (path.startsWith('http://') || path.startsWith('https://')) {
      await _player.setSourceUrl(path);
    } else {
      await _player.setSourceAsset(path);
    }
  }
  
  @override
  Future<void> play() async {
    await _player.resume();
  }
  
  @override
  Future<void> pause() async {
    await _player.pause();
  }
  
  @override
  Future<void> stop() async {
    await _player.stop();
    _currentSource = null;
    _sourceController.add(null);
  }
  
  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }
  
  @override
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }
  
  @override
  Future<void> release() async {
    await _player.release();
    _currentSource = null;
    _sourceController.add(null);
  }
  
  @override
  void dispose() {
    _playingController.close();
    _pausedController.close();
    _sourceController.close();
    _player.dispose();
  }
}

AudioService createAudioService() => _MobileAudioService();