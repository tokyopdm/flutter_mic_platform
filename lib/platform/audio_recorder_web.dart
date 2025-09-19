import 'dart:js_interop';

// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'package:record/record.dart';

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

  /*
  void saveToSessionStorage(String path) {
    web.window.sessionStorage.add()
  }
  */

  void anchorDataInWebDocument(String path) {
    if (kDebugMode) {
      print('Creating HTMLAnchorElement for data in sessionStorage');
    }
    
    // Create an HTMLAnchorElement to the 
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      //..style.display = 'none'
      //..download = 'audio.wav';
      ..href = path;
    
    debugPrint('Appending Anchor to web.document.body...');
    web.document.body!.appendChild(anchor);
    
    //anchor.click();
    //web.document.body!.removeChild(anchor);
  }
}
