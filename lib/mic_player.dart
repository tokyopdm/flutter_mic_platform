import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio_service/audio_service_provider.dart';

class MicPlayer extends ConsumerStatefulWidget {
  /// Path from where to play recorded audio
  final String source;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button
  final VoidCallback onDelete;

  const MicPlayer({
    super.key,
    required this.source,
    required this.onDelete,
  });

  @override
  ConsumerState<MicPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends ConsumerState<MicPlayer> {
  static const double _controlSize = 56;
  static const double _deleteBtnSize = 24;

  late String _playerKey;

  @override
  void initState() {
    super.initState();
    // Create a unique key for this player instance
    _playerKey = '${widget.source.hashCode}';
    
    // Set the source when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(audioServiceProvider(_playerKey));
      service.setSource(widget.source);
    });
  }

  @override
  void dispose() {
    // The service will be automatically disposed by Riverpod's autoDispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.watch(audioServiceProvider(_playerKey));
    final durationAsync = ref.watch(durationProvider(_playerKey));
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildControl(),
                _buildSlider(constraints.maxWidth),
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: Color(0xFF73748D), size: _deleteBtnSize),
                  onPressed: () async {
                    if (audioService.isPlaying) {
                      await audioService.stop();
                    }
                    widget.onDelete();
                  },
                ),
              ],
            ),
            durationAsync.when(
              data: (duration) => Text('$duration'),
              loading: () => const Text('0:00'),
              error: (_, __) => const Text('0:00'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControl() {
    final service = ref.watch(audioServiceProvider(_playerKey));
    final isPlaying = ref.watch(isPlayingProvider(_playerKey));

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
                  await service.pause();
                } else {
                  debugPrint('Play button pressed');
                  await service.play();
                }
              },
            ),
          ),
        );
    }

  Widget _buildSlider(double widgetWidth) {

    final service = ref.watch(audioServiceProvider(_playerKey));
    final positionAsync = ref.watch(positionProvider(_playerKey));
    final durationAsync = ref.watch(durationProvider(_playerKey));

    return positionAsync.when(
      data: (position) => durationAsync.when(
        data: (duration) {
          bool canSetValue = false;
          
          if (duration != Duration.zero && position != Duration.zero) {
            canSetValue = position.inMilliseconds > 0;
            canSetValue &= position.inMilliseconds < duration.inMilliseconds;
          }

          double width = widgetWidth - _controlSize - _deleteBtnSize;
          width -= _deleteBtnSize;

          return SizedBox(
            width: width,
            child: Slider(
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).colorScheme.secondary,
              onChanged: (v) {
                if (duration != Duration.zero) {
                  final newPosition = v * duration.inMilliseconds;
                  service.seek(Duration(milliseconds: newPosition.round()));
                }
              },
              value: canSetValue && duration != Duration.zero && position != Duration.zero
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0,
            ),
          );
        },
        loading: () => _buildLoadingSlider(widgetWidth),
        error: (_, __) => _buildLoadingSlider(widgetWidth),
      ),
      loading: () => _buildLoadingSlider(widgetWidth),
      error: (_, __) => _buildLoadingSlider(widgetWidth),
    );
  }

  Widget _buildLoadingSlider(double widgetWidth) {
    double width = widgetWidth - _controlSize - _deleteBtnSize;
    width -= _deleteBtnSize;

    return SizedBox(
      width: width,
      child: Slider(
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).colorScheme.secondary,
        onChanged: null,
        value: 0.0,
      ),
    );
  }
}