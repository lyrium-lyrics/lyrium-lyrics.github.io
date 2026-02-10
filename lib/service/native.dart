import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';

const bool isWeb = false;

Future<QueryExecutor> openPlatformConnection(
  String name, {
  bool? memoryMode,
}) async {
  if (memoryMode ?? false) {
    return NativeDatabase.memory();
  }

  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, '$name.sqlite'));

  return NativeDatabase(file);
}

class NotificationConnection {
  static const _eventChannel = EventChannel("com.example.lyrium");
  static const _methodChannel = MethodChannel("com.example.lyrium/methods");

  static Stream<Map?> get notifications async* {
    yield* _eventChannel.receiveBroadcastStream().map((event) => event as Map?);
  }

  static Future<void> openNotificationAccessSettings() async {
    await _methodChannel.invokeMethod("openNotificationAccessSettings");
  }

  static Future<bool> update() async {
    return await _methodChannel.invokeMethod("update");
  }

  static Future<bool> seekTo(Duration position) async {
    return await _methodChannel.invokeMethod("seekTo", position.inMilliseconds);
  }

  static Future<Duration> getPosition() async {
    final data = await _methodChannel.invokeMethod<int?>("getPosition");
    return Duration(milliseconds: data ?? 0);
  }

  static Future<Image?> getImage() async {
    final bytes = await _methodChannel.invokeMethod<Uint8List>("getImageData");
    if (bytes != null) {
      return Image.memory(bytes); // ready to display
    }
    return null;
  }

  static bool imaginepause = true;
  static togglePause() {
    if (imaginepause) {
      play();
      imaginepause = !imaginepause;
    } else {
      pause();
      imaginepause = !imaginepause;
    }
  }

  static Future<bool> play() async {
    return await _methodChannel.invokeMethod("play");
  }

  static Future<bool> pause() async {
    return await _methodChannel.invokeMethod("pause");
  }

  static Future<bool> hasNotificationAccess() async {
    try {
      // Invoke the native method 'hasNotificationAccess' and await the boolean result.
      final bool result = await _methodChannel.invokeMethod(
        'hasNotificationAccess',
      );
      return result;
    } on PlatformException catch (e) {
      // Handle potential errors, such as the method not being implemented.
      print("Failed to get notification access: '${e.message}'.");
      return false;
    }
  }
}
