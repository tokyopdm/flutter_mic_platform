import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service/audio_service_provider.dart';

class AudioPlayerButton extends ConsumerStatefulWidget {
  final bool isDisabled;
  final String? id;
  final String? path;
  final VoidCallback onPressed;

  const AudioPlayerButton({
    super.key,
    this.id,
    this.path,
    bool? isDisabled,
    required this.onPressed,
    }) : isDisabled = isDisabled ?? false;

  @override
  ConsumerState<AudioPlayerButton> createState() => _AudioPlayerButtonState();
}

class _AudioPlayerButtonState extends ConsumerState<AudioPlayerButton> {

  late String? _id;
  late String? _path;
  late bool _isDisabled;
  late ValueKey? _audioKey;
  late VoidCallback _onPressed;
  

  @override
  void initState() {
    super.initState();
    _id = widget.id; 
    _path = widget.path;
    _isDisabled = widget.isDisabled;
    _onPressed = widget.onPressed;
    _audioKey = ValueKey('${_id}__$_path');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final audioInstance = ref.read(audioServiceInstanceProvider(_playerId));

        debugPrint('Fetching audio instance for playerId: $_playerId...');
        if (audioInstance.player.source != null) {
          debugPrint('Found AudioPlayer instance $_playerId');
        } else {
          debugPrint('Player source not found');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: ShapeDecoration(color: Color.fromRGBO(219, 226, 232, _isDisabled ? 0.1 : 1), /// Per Material3Design, disabled state - 10% opacity
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: IconButton(icon: Icon(Icons.volume_up_rounded), color: Color.fromRGBO(110, 194, 177, _isDisabled ? 0.38 : 1), /// Per Material3Design, disabled state - 38% opacity
        iconSize: 20,
        padding: EdgeInsets.all(6),
        alignment: Alignment.center,  
        onPressed: _onPressed,
      ),
    );
  }
}