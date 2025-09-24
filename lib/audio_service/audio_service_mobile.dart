// ignore: unused_import
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

import 'package:audioplayers/audioplayers.dart';

import 'audio_service.dart';

class _MobileAudioService implements AudioService {
  final AudioPlayer _player;
  static final Set<AudioService> _audioInstances = {}; // Track all instances of the Audio Service created
  // ignore: unused_field, prefer_final_fields
  //String? _playerId;
  ValueKey<String> audioKey;
  Source? _source;
  String? mimeType;

  _MobileAudioService(this._playerId) : _player = AudioPlayer(playerId: _playerId) {
    /// Configure AudioLogger level
    AudioLogger.logLevel = AudioLogLevel.info; /// or .error, .none, etc.
    
    /// Add this instance to the set
    _audioInstances.add(this); 
    debugPrint('New io AudioService instance created. Total instances: ${_audioInstances.length}');

  }
  
  @override
  AudioPlayer get player => _player;
  
  static Set<AudioService> get instances => _audioInstances;

  /// Determine the appropriate Source data type based on its path
  Source convertPathToSource(String path) {
    String? mimeType = lookupMimeType(path);
    
    switch (path) {

      /// Remove the leading 'assets/' directory from file path because
      /// AudioPlayers searches within the assets/ folder automatically
      /// for the AssetSource type
      case String p when p.startsWith('assets/'):
        final String formattedPath = path.split('/').sublist(1).join('/'); 
        return _source = AssetSource(formattedPath, mimeType: mimeType);

      //TODO: download the save as DeviceFileSource type
      case String p when p.startsWith('http'):
        return _source = UrlSource(path, mimeType: mimeType);
        
      default:
        return _source = DeviceFileSource(path, mimeType: mimeType);
    }
  }

  /// Play audio with an already set source
  @override
  Future<void> play() async {
    //assert(_player.source != null, 'Player Source cannot be null');

    if (_source != null) {
      debugPrint('Playing audio instance ID = ${_player.playerId}, source = ${_player.source}');
      await _player.play(_source!);
    } else {
      const errorMessage = 'No source set for this Audio Player. Call setSource() first.';
      debugPrint(errorMessage);

      throw Exception(errorMessage);
    }
  }

  /// Sets a source for the audio instance and plays it if autoplay == true
  @override
  Future<void> setAudioSource(String path, {bool autoplay = false}) async {
    /// Release the AudioPlayer so that a new source can be assigned
    //TODO: need to check if this is necessary
    if (_source != null) {
      release();
    }
    
    /// Set the Source type based on its path structure
    final source = convertPathToSource(path);

    _player.setSource(source); //Might need to wrap this or convertPathToSource in a try-catch block

    if (_player.source != null) {
      debugPrint('Source set to player ID: ${_player.playerId}, source: ${_player.source}');
    }

    if (autoplay) {
      /// Call the player
      await _player.play(source); 
    }
  }

  Future<void> resume() async {
    debugPrint('Resuming audio playback...');
    await _player.resume();
  }
  
  @override
  Future<void> pause() async {
    debugPrint('Pausing audio playback...');
    await _player.pause();
  }
  
  @override
  Future<void> stop() async {
    debugPrint('Stopping audio playback');
    await _player.stop();
  }
  
  /// Release AudioPlayer resources to be fetched again when source changes
  @override
  Future<void> release() async {
    debugPrint('Releasing AudioPlayer source');
    await _player.release();
  }
  
  @override
  void dispose() async {
    debugPrint('Disposing audio instance ID ${_player.playerId}...');
    
    /// Remove this instance from the tracking set before disposing
    _audioInstances.remove(this);
    
    await _player.dispose();
    
    debugPrint('Audio instance disposed. Remaining instances: ${_audioInstances.length}');
    
  }
  
  void _disposeAllInstances() {
    for (final instance in instances) {
      instance.player.dispose();
    }
  }

  @override
  void disposeAllInstances() => _disposeAllInstances();
}

/// These methods expose public getters from the private platform class
/// to the abstract AudioService umbrella class

/// Creates a new AudioService instance with a given playerId 
AudioService getAudioService(String? playerId) => _MobileAudioService(playerId);

//// Exposes the class's AudioPlayer object for access to playerId, source, and stream data
//// AudioPlayer getAudioPlayer(String? playerId) => _MobileAudioService(playerId).player;

/// A static method to get all active instances of the AudioService class
Set<AudioService> getAudioInstances() => _MobileAudioService.instances;