import 'package:flutter/services.dart';

class NativeAiService {
  static const MethodChannel _methodChannel = MethodChannel('com.vsign.app/ai_camera');
  static const EventChannel _eventChannel = EventChannel('com.vsign.app/ai_landmark_stream');

  /// Starts the native camera feed and MediaPipe gesture landmark extraction.
  Future<bool> startLandmarkExtraction({required String targetLabel}) async {
    try {
      final bool result = await _methodChannel.invokeMethod('startScan', {
        'targetLabel': targetLabel,
      });
      return result;
    } on PlatformException catch (_) {
      // Platform exception handling
      return false;
    }
  }

  /// Stops the camera feed and landmark extraction.
  Future<bool> stopLandmarkExtraction() async {
    try {
      final bool result = await _methodChannel.invokeMethod('stopScan');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Stream of coordinates received from the native side.
  /// Emits a [List<double>] representing the 258 landmarks:
  /// - Pose: 33 * 4 (x, y, z, visibility) = 132
  /// - Left Hand: 21 * 3 (x, y, z) = 63
  /// - Right Hand: 21 * 3 (x, y, z) = 63
  /// Total size: 258 coordinates
  Stream<List<double>> get landmarkStream {
    return _eventChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is List) {
        return event.cast<double>();
      }
      throw const FormatException('Expected List<double> from native platform channel');
    });
  }
}
