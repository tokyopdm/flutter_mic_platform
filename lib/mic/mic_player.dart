import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mic_platform/mic/session_storage_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio_service/audio_service_provider.dart';

class MicPlayer extends ConsumerStatefulWidget {
  
  final String timestamp; // DateTime stamp of the audio recording
  final String source; // Path from where to play recorded audio

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  final VoidCallback onDelete;

  /// Returns the AudioInstance playerId to the parent widget
  final void Function(String playerId) onSend;

  const MicPlayer({
    super.key,
    required this.timestamp,
    required this.source,
    required this.onDelete,
    required this.onSend,
  });

  @override
  ConsumerState<MicPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends ConsumerState<MicPlayer> {
  static const double _controlSize = 56;
  static const double _deleteBtnSize = 24;

  String? _anchorId; 
  late String _playerId;
  

  @override
  void initState() {
    super.initState();

    /// Create the unique key for this AudioPlayer instance _playerId
    if (kIsWeb) {
      /// Parse the anchor ID from the path so it can be used later 
      /// to delete the audio from browser memory on the web
      _anchorId = getAnchorIdFromSourcePath(widget.source);
      _playerId = '${widget.timestamp}_$_anchorId';
    } else {
      _playerId = '${widget.timestamp}_${widget.timestamp.hashCode}';
    }
    
    /// Set the source when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Creating audio instance for playerId: $_playerId...');

      final audioInstance = ref.read(audioServiceInstanceProvider(_playerId));
      audioInstance.setAudioSource(widget.source);
    });
  }

  @override
  void dispose() {
    // The service will be automatically disposed by Riverpod's autoDispose
    super.dispose();
  }

  String? getAnchorIdFromSourcePath(String path) {
    debugPrint('Creating anchordId from path $path');
    /// Return the file name after the final / to use for the anchorId 
    return path.split('/').last;

  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioServiceInstanceProvider(_playerId));
    final isPlaying = ref.watch(audioInstanceIsPlayingProvider(_playerId));
    final duration = Duration(seconds: 0);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                /// Delete button
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: Color(0xFF73748D), size: _deleteBtnSize),
                  onPressed: () async {
                    if (isPlaying) {
                      await audio.stop();
                    }
                    widget.onDelete(); 
                    /// Clear audio data from browser session storage
                    if (_anchorId != null) {
                      clearWebDataById(_anchorId!); 
                    }
                    /// Trigger AudioService dispose method for this instance
                    audio.dispose();
                  },
                ),
                /// Play Button
                _buildControl(),
                /// Send Button
                IconButton(
                  icon: const Icon(Icons.send_rounded,
                      color: Color(0xFF73748D), size: _deleteBtnSize),
                  onPressed: () async {
                    if (isPlaying) {
                      await audio.stop();
                    }
                    widget.onSend(_playerId); // Passing the concatenated AudioInstance

                    /// Trigger AudioService release method for this instance
                    audio.release();
                  },
                      )
              ],
            ),
            Text('$duration'),
          ],
        );
      },
    );
  }

  Widget _buildControl() {
    final audio = ref.watch(audioServiceInstanceProvider(_playerId));
    final isPlaying = ref.watch(audioInstanceIsPlayingProvider(_playerId));

    Icon icon;
    Color color;

        if (isPlaying) {
          icon = const Icon(Icons.pause, color: Colors.red, size: 30);
          color = Colors.red.withValues(alpha: 0.1);
        } else {
          final theme = Theme.of(context);
          icon = Icon(Icons.play_arrow, color: theme.primaryColor, size: 30);
          color = theme.primaryColor.withValues(alpha: 0.1);
        }

        return ClipOval(
          child: Material(
            color: color,
            child: InkWell(
              child: SizedBox(
                width: _controlSize,
                height: _controlSize,
                child: icon,
              ),
              onTap: () async {
                if (isPlaying) {
                  await audio.pause();
                } else {
                  debugPrint('Play button pressed');
                  await audio.play();
                }
              },
            ),
          ),
        );
    }
}