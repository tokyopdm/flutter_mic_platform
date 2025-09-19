// ignore_for_file: unused_import
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'audio_service.dart';

class _WebAudioService implements AudioService {
  // Stream controllers for custom streams
  final AudioPlayer _player = AudioPlayer();
  String? _currentSource;

  // Stream controllers for custom streams
  final StreamController<bool> _playingController = StreamController.broadcast();
  final StreamController<bool> _pausedController = StreamController.broadcast();
  final StreamController<String?> _sourceController = StreamController.broadcast();

  late final StreamSubscription _playerStateSubscription;

  _WebAudioService() {
    _setupListeners();
    
  }

  void _setupListeners() {
    AudioLogger.logLevel = AudioLogLevel.info;

    //debugPrint('AudioLogger Level = ${AudioLogger.logLevel}');
    
    _playerStateSubscription = _player.onPlayerStateChanged.listen((state) {
      
      if (!_playingController.isClosed) {
        _playingController.add(state == PlayerState.playing);
      }
      if (!_pausedController.isClosed) {
        _pausedController.add(state == PlayerState.paused);
      }
    });
  }
  
  @override
  bool get isPlaying => _player.state == PlayerState.playing;
  
  @override
  bool get isPaused => _player.state == PlayerState.paused;
  
  @override
  bool get isStopped => _player.state == PlayerState.stopped;
  
  @override
  Duration get currentPosition => Duration.zero;
  
  @override
  Duration get totalDuration => Duration.zero;
  
  @override
  String? get currentSource => _currentSource;
  
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

  //@override
  //StreamSubscription? get onLogStreamSubscription => _playerStateSubscription;
  
  @override
  Future<void> setSource(String path) async {

    debugPrint('Setting MicPlayer source as $path');
    _currentSource = path;
    if (!_sourceController.isClosed) {
      _sourceController.add(path);
    }

    // Web typically handles URLs differently
    if (path.startsWith('assets/')) {
      // Convert asset path to web-accessible URL
      await _player.setSourceUrl('assets/$path');
        if (_player.source != null) {

          debugPrint('Asset Source URL set ✔️');
          debugPrint('Source is set to: ${_player.source}');
        }
      return;
    } else if (path.startsWith('blob:')) {
        debugPrint('Blob url detected...');
        // Convert the blob url to a bytes array
        try {
          Uint8List? bytes = await getAudioBytesFromBlobUrl(path);

          if (bytes != null) {
            debugPrint('Setting bytes as Source type BytesSource...');
            await _player.setSourceBytes(bytes, mimeType: "audio/mpeg");
            
            if (_player.source != null) {
              debugPrint('Source set to ${_player.source}');
            } else {
              throw Exception('Exception setting bytes as BytesSource');
            }

          } else {
            throw Exception('Exception getting bytes from blob URL: null returned');
          }

        } on Exception catch (e) {
          debugPrint('Exception converting byte array to Audio Service source from blob url: $e');
          rethrow;
        }
      } else {

      if (kDebugMode) {
        print('Setting source to path: $path');
      }

      await _player.setSourceUrl(path);
    }

  }

  // Better approach for handling blob URLs
Future<Uint8List?> getAudioBytesFromBlobUrl(String blobUrl) async {
  debugPrint('Fetching blob data...');

  //final localPath = web.window.sessionStorage.getItem(blobUrl); // No need to recreate the blob url since we already have it
    
  //if (localPath != null) {
      //debugPrint('localPath to blob in web.window.sessionStorage = $localPath');
      try {
        // Use fetch API instead of http.Client for blob URLs
        debugPrint('Calling web.window.fetch()...');
        final response = await web.window.fetch(blobUrl.toJS).toDart;
        
        if (response.ok) {
          debugPrint('Response received: ${response.status} - ${response.statusText}');
          // Convert response to blob, then to bytes
          final blob = await response.blob().toDart;
          final jsArrayBuffer = await blob.arrayBuffer().toDart;
      
          final bytes = jsArrayBuffer.toDart.asUint8List();
          
          debugPrint('Returning blob as byte array of length: ${bytes.length}');
          return bytes;
        } else {
          throw Exception('Failed to fetch blob: ${response.status}');
        }
      } catch (e) {
        debugPrint('Error fetching blob: $e');
        rethrow;
      }
    }
    //debugPrint('localPath is null');
    //return null;

  String? getPathFromBlobUrl(String blobUrl) {
      try {
        final web.HTMLAnchorElement anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = blobUrl;
        return anchor.nodeValue;
      } on Exception catch (e) {
        debugPrint('Exception getting path from blob URL: $e');
        rethrow;
      }
    }

  /*
  void downloadFileFromBlobUrl(String blobUrl, String fileName) {
      final web.HTMLAnchorElement anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = blobUrl;
      anchor.download = fileName; // Specify the desired filename for the download
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(blobUrl); // Revoke the object URL to free up resources
    }
  */
  
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
    if (!_sourceController.isClosed) {
      _sourceController.add(null);
    }
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
    if (!_sourceController.isClosed) {
      _sourceController.add(null);
    }
  }
  
  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _playingController.close();
    _pausedController.close();
    _sourceController.close();
    _player.dispose();
  }
}

AudioService createAudioService() => _WebAudioService();