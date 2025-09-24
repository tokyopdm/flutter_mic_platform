import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mic/microphone.dart';

void main() => runApp(
  // Wrap the app with ProviderScope for Riverpod
  const ProviderScope(
    child: MicrophoneApp(),
  ),
);
