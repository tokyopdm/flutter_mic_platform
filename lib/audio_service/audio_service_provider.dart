import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'audio_service.dart';

// Provider family for multiple audio player instances
final audioPlayerServiceProvider = Provider.autoDispose.family<AudioService, String>((ref, key) {
  final service = createAudioService();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});


// Stream providers for reactive state updates (Riverpod 2.0 syntax)
final isPlayingProvider = StreamProvider.autoDispose.family<bool, String>((ref, key) {
  final service = ref.watch(audioPlayerServiceProvider(key));
  return service.onPlayingStateChanged;
});

final isPausedProvider = StreamProvider.autoDispose.family<bool, String>((ref, key) {
  final service = ref.watch(audioPlayerServiceProvider(key));
  return service.onPausedStateChanged;
});

final positionProvider = StreamProvider.autoDispose.family<Duration, String>((ref, key) {
  final service = ref.watch(audioPlayerServiceProvider(key));
  return service.onPositionChanged;
});

final durationProvider = StreamProvider.autoDispose.family<Duration, String>((ref, key) {
  final service = ref.watch(audioPlayerServiceProvider(key));
  return service.onDurationChanged;
});

final playerCompleteProvider = StreamProvider.autoDispose.family<void, String>((ref, key) {
  final service = ref.watch(audioPlayerServiceProvider(key));
  return service.onPlayerComplete;
});

final currentSourceProvider = StreamProvider.autoDispose.family<String?, String>((ref, key) {
  final service = ref.watch(audioPlayerServiceProvider(key));
  return service.onSourceChanged;
});

// Combined state provider for convenience
@immutable
class AudioPlayerState {
  final bool isPlaying;
  final bool isPaused;
  final Duration position;
  final Duration duration;
  final String? currentSource;
  
  const AudioPlayerState({
    this.isPlaying = false,
    this.isPaused = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentSource,
  });
  
  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isPaused,
    Duration? position,
    Duration? duration,
    String? currentSource,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentSource: currentSource ?? this.currentSource,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioPlayerState &&
          runtimeType == other.runtimeType &&
          isPlaying == other.isPlaying &&
          isPaused == other.isPaused &&
          position == other.position &&
          duration == other.duration &&
          currentSource == other.currentSource;

  @override
  int get hashCode => Object.hash(isPlaying, isPaused, position, duration, currentSource);
}

// Combined stream provider that merges all state streams (Riverpod 2.0)
final audioPlayerStateProvider = StreamProvider.autoDispose.family<AudioPlayerState, String>((ref, key) {
  final service = ref.watch(audioPlayerServiceProvider(key));
  
  return service.onPlayingStateChanged.asyncMap((isPlaying) async {
    return AudioPlayerState(
      isPlaying: isPlaying,
      isPaused: service.isPaused,
      position: service.currentPosition,
      duration: service.totalDuration,
      currentSource: service.currentSource,
    );
  });
});