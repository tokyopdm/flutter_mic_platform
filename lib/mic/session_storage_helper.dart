
// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Helper functions for managing data stored in the browser's session storage

/// Store data to the web browser's session storage as a blob
/// that can be accessed via a given path in the form of a blob url
void anchorDataInWebDocument(String path) {
  String id = path.split('/').last; // Creates an audio ID from its filename

  if (kDebugMode) {
    print('Creating HTMLAnchorElement for data in sessionStorage');
  }
    
  /// Create an HTMLAnchorElement to the data 
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    /// Uncomment the below to add automatic downloads for web testing
    ////..download = 'audio.wav';
    ////..click()
    ..href = path
    ..id = id;
    
  if (kDebugMode) {
    print('Appending Anchor ID $id to web.document.body...');
  }
  web.document.body!.appendChild(anchor);
}

/// Free a blob data from memory  
Future<void> clearWebDataById(String id) async {
  final anchor = web.document.getElementById(id) as web.HTMLAnchorElement?;
  
  if (anchor != null) {
    // This frees the blob data from memory
    web.URL.revokeObjectURL(anchor.href);
    
    // This removes the DOM element
    web.document.body!.removeChild(anchor);
  }
}