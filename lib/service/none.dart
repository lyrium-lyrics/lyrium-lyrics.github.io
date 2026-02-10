import 'package:flutter/widgets.dart';

const bool isWeb = false;

openPlatformConnection(String name, {bool? memoryMode}) {
  throw UnimplementedError();
}

class NotificationConnection {
  static Stream<Map?> get notifications async* {
    throw UnimplementedError();
  }

  static Future<void> openNotificationAccessSettings() async {
    throw UnimplementedError();
  }

  static Future<List<Map<String, dynamic>>?> getActiveSessions() async {
    throw UnimplementedError();
  }

  static Future<bool> seekTo(Duration position) async {
    throw UnimplementedError();
  }

  static Future<Duration> getPosition() async {
    throw UnimplementedError();
  }

  static Future<Image?> getImage() async {
    throw UnimplementedError();
  }

  static bool imaginepause = true;
  static togglePause() {
    throw UnimplementedError();
  }

  static Future<bool> play() async {
    throw UnimplementedError();
  }

  static Future<bool> pause() async {
    throw UnimplementedError();
  }

  static Future<bool> hasNotificationAccess() async {
    throw UnimplementedError();
  }

  static Future<List<Map<String, dynamic>>?> update() async {
    throw UnimplementedError();
  }
}
