// ignore_for_file: unused_import, depend_on_referenced_packages
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'audio_service.dart';

class _WebAudioService implements AudioService {
  final AudioPlayer _player;
  /// A static set that tracks all instances of AudioService created
  static final Set<AudioService> _audioInstances = {}; 
  String? _playerId;
  Source? _source; 
  String? mimeType;

  _WebAudioService(this._playerId) : _player = AudioPlayer(playerId: _playerId) {
    /// Configure AudioLogger level
    AudioLogger.logLevel = AudioLogLevel.info; // or .error, .none, etc.

    /// Add this instance to the set
    _audioInstances.add(this); 
    debugPrint('New web AudioService instance created. Total instances: ${_audioInstances.length}');
  }

  @override
  AudioPlayer get player => _player;

  static Set<AudioService> get instances => _audioInstances;

  /// Sets a source for the audio instance and plays it if autoplay == true
  @override
  Future<void> setAudioSource(String path, {bool autoplay = false}) async {
    /// Release the AudioPlayer so that a new source can be assigned
    if (_source != null) {
      release();
    }
    
    /// Set the Source type based on its path structure
    final source = await convertPathToSource(path);

    if (_player.source != null) {
      debugPrint('Source set to player ID: ${_player.playerId}, source: ${_player.source}');
    }

    if (autoplay) {
      debugPrint('Auto-playing audio instance...');
      /// Call the player
      await _player.play(source);
    }
  }

  /// Determine the appropriate Source type based on the path
  Future<Source> convertPathToSource(String path) async {
    String? mimeType = lookupMimeType(path);

    switch (path) {

      /// A blob url represents the path to audio data stored in the user's web browser session 
      /// Typically, it will come from the user audio stored by audio_recorder_web class
      case String p when p.startsWith('blob:'):
        debugPrint('Blob url detected...');

        /// We convert this blob url to a byte array to make it a compatible Audioplayer source data type
        try {
          debugPrint('Fetching data...');
          Uint8List? bytes = await getAudioBytesFromBlobUrl(path);

          if (bytes != null) {
            debugPrint('Setting bytes as Source type BytesSource...');
            return _source = BytesSource(bytes, mimeType: "audio/mpeg");

          } else {
            throw Exception('Attempted to fetch audio bytes from blob URL, but the data returned null');
          }

        } on Exception catch (e) {
          debugPrint('Exception converting blob url path to compatible audio source: $e');
          rethrow;
        }
      
      case String p when p.startsWith('assets/'):
        /// Removes the leading 'assets/' directory from file path because
        /// AudioPlayers searches within the assets/ folder automatically for the AssetSource subclass
        final String formattedPath = path.split('/').sublist(1).join('/'); 

        return _source = AssetSource(formattedPath, mimeType: mimeType);
        /// Web typically handles URLs differently
        /// If the above fails, uncomment and try this approach instead:
        /*
        // Web typically handles URLs differently
        if (path.startsWith('assets/')) {
          // Convert asset path to web-accessible URL
          await _player.setSourceUrl('assets/$path');
            if (_player.source != null) {

              debugPrint('Asset Source URL set ✔️');
              debugPrint('Source is set to: ${_player.source}');
            }
          return;
        }
        */

      case String p when p.startsWith('http'):
        if (kDebugMode) {
          print('Setting source to path: $path');
        }

        return _source = UrlSource(path, mimeType: mimeType);

      default:
        throw UnimplementedError('Exception: path $path is not a web-compatible Audioplayer source');
    }
  }

  /// Additonal method required by web implementation to set source from blob url
  /// Downloads byte array from browser window's sessionStorage 
  /// So it can be set as a BytesSource
  Future<Uint8List?> getAudioBytesFromBlobUrl(String blobUrl) async {
    try {
      debugPrint('Calling web.window.fetch()...');
      final response = await web.window.fetch(blobUrl.toJS).toDart;

      if (response.ok) {
        debugPrint('Response received: ${response.status} - ${response.statusText}');
        // Convert response to blob, then to bytes
        
        // Append .toDart to convert the JSPromise to a Dart Future<T> 
        final blob = await response.blob().toDart;
        final jsArrayBuffer = await blob.arrayBuffer().toDart;

        // Wrap in a Uint8List that's compatible with Audioplayers package
        final bytes = jsArrayBuffer.toDart.asUint8List();
          
        debugPrint('Returning blob as byte array, length = ${bytes.length} bytes');
        return bytes;
        
      } else {
        throw Exception('Failed to fetch blob data: ${response.status}');
      }

    } catch (e) {
      debugPrint('Error fetching blob: $e');
      rethrow;
    }
  }

 /// Play audio with an already set source
  @override
  Future<void> play() async {
    //assert(_player.source != null, 'Player Source cannot be null');

    if (_source != null) {
      debugPrint('Playing audio instance ID = ${_player.playerId}, source = $_source');
      await _player.play(_source!);
    } else {
      const errorMessage = 'No source set for this Audio Player. Call setSource() first.';
      debugPrint(errorMessage);

      throw Exception(errorMessage);
    }
  }

  Future<void> resume() async {
    debugPrint('Resuming audio playback...');
    await _player.resume();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }
  
  @override
  Future<void> stop() async {
    await _player.stop();
  }
  
  /// Release AudioPlayer resources to be fetched again when source changes
  Future<void> release() async {
    await _player.release();
    _source = null; // Clear the local value
  }
  
  @override
  void dispose() async {
    if (kDebugMode) {
      print('Disposing audio instance ID ${_player.playerId}...');
    }
    
    // Remove this instance from the tracking set before disposing
    _audioInstances.remove(this);
    
    await _player.dispose();
    
    if (kDebugMode) {
      print('Audio instance disposed. Remaining instances: ${_audioInstances.length}');
    }
  }

  static Future<void> _disposeAllInstances() async {
    if (_audioInstances.isNotEmpty) {
      debugPrint('Disposing all AudioPlayer instances (${_audioInstances.length})...');

      /// Create a copy of the set to avoid concurrent modification
      final instancesCopy = Set<AudioService>.from(_audioInstances);
      
      /// This disposes the given instance from the copy of the set
      /// and from the _audioInstances set itself
      for (final instance in instancesCopy) {
        await instance.player.dispose();
      }

      /// Clear the set (should already be empty, but just to be sure)
      _audioInstances.clear();
    }
    debugPrint('All AudioPlayer instances disposed');
  }

  @override
  void disposeAllInstances() => _disposeAllInstances();

}

/// These methods expose public getters within the private implementation class 
/// to the abstract AudioService umbrella class

/// Creates a new AudioService instance with a given playerId 
AudioService getAudioService(String? playerId) => _WebAudioService(playerId);

//// Exposes the class's AudioPlayer object for access to playerId, source, and stream data
////AudioPlayer getAudioPlayer(String? playerId) => _WebAudioService(playerId).player;

/// A static method to get all active instances of the AudioService class
Set<AudioService> getAudioInstances() => _WebAudioService.instances;