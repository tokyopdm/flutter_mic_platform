import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_service.dart';

// Family provider that creates a unique AudioService instance for each playerId
final audioServiceInstanceProvider = Provider.autoDispose.family<AudioService, String?>((ref, playerId) {
  final service = getAudioService(playerId);
  
  // Dispose the AudioService when the exam session is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Global provider that returns true if any AudioService instance is playing
/// TODO: Update the microphone to disable onPress if any audio is playing
final globalAudioIsPlayingProvider = Provider<bool>((ref) {
  /// Access all AudioService instances
  final instances = getAudioInstances();

  /// Listen to state changes on all instances to ensure provider updates
  for (final instance in instances) {
    instance.player.onPlayerStateChanged.listen((_) {
      ref.invalidateSelf();
    });
  }

  /// Return true if any of the instances are currently playing
  return instances.any((instance) =>
    instance.player.state == PlayerState.playing);
});


/// Returns true when a given audio instance is currently playing
final audioInstanceIsPlayingProvider = Provider.family<bool, String>((ref, playerId) {
  /// Access the specific AudioService instance for a given playerId 
  /// and get its AudioPlayer object
  final player = ref.watch(audioServiceInstanceProvider(playerId)).player;

  player.onPlayerStateChanged.listen((_) {
    //Force provider to rebuild
    ref.invalidateSelf();

  });
  return player.state == PlayerState.playing;
});

/// Provider Notifier that deletes an audio instance and cleans it up 