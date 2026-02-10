import 'package:drift/backends.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/widgets.dart';

const bool isWeb = true;

Future<QueryExecutor> openPlatformConnection(
  String name, {
  bool? memoryMode,
}) async {
  // tests does not need memory mode for now.
  return WasmDatabase.open(
    databaseName: '$name.db',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  ).then((t) {
    return t.resolvedExecutor;
  });
}

class NotificationConnection {
  static Stream<Map?> get notifications async* {
    throw UnimplementedError();
  }

  static Future<void> openNotificationAccessSettings() async {
    throw UnimplementedError();
  }

  static Future<dynamic> update() => NotificationConnection.update();

  static Future<bool> seekTo(Duration position) async {
    return false;
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
    return true;
  }
}
