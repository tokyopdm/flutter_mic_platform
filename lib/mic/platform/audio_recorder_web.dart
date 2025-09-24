// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import '../session_storage_helper.dart';

mixin AudioRecorderMixin {
  Future<void> recordFile(AudioRecorder recorder, RecordConfig config) {
    return recorder.start(config, path: '');
  }

  Future<void> recordStream(AudioRecorder recorder, RecordConfig config) async {
    final bytes = <int>[];
    final stream = await recorder.startStream(config);

    stream.listen(
      (data) => bytes.addAll(data),
      onDone: () => anchorDataInWebDocument(web.URL.createObjectURL(
        web.Blob(<JSUint8Array>[Uint8List.fromList(bytes).toJS].toJS),
      ),
    ));
  }
}

