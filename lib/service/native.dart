import 'dart:async';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/utils/demo_notification.dart';
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

final MusicService notificationConnection = Platform.isAndroid
    ? SupportedConnection()
    : DemoNotificationService();

class SupportedConnection extends MusicService {
  static const _eventChannel = EventChannel("com.example.lyrium");
  static const _methodChannel = MethodChannel("com.example.lyrium/methods");
  static const _kIsPlaying = 'isPlaying';

  @override
  Duration? duration;
  @override
  Duration? elapsed;
  @override
  bool isPlaying = false;
  @override
  Track? track;

  /// Stream of raw data from the native platform
  Stream<Map?> get _notifications async* {
    yield* _eventChannel.receiveBroadcastStream().map((event) => event as Map?);
  }

  late StreamSubscription _subscription;
  @override
  void start({
    required Function(Track track) onTrackChanged,
    required Function() onStateChanged,
    required Function() onUnsetTrack,
  }) {
    _subscription = _notifications.listen((data) {
      if (data == null) {
        track = null;
        onUnsetTrack();
        return;
      }

      final prevName = track?.trackName;
      track = _parseData(data);

      if (prevName != track?.trackName) {
        // Track changed
        if (track == null) {
          onUnsetTrack();
        } else {
          onTrackChanged(track!);
        }
      } else {
        // Only state (play/pause/progress) changed
        onStateChanged();
      }
    });
  }

  Track _parseData(Map<dynamic, dynamic> data) {
    duration = Duration(milliseconds: (data["duration"] as int?) ?? 0);
    elapsed = Duration(milliseconds: (data["position"] as int?) ?? 0);
    isPlaying = data[_kIsPlaying] as bool? ?? false;

    return Track(
      namespace: data["package"] ?? "Device",
      artistName: data["artist"] ?? "Invalid",
      trackName: data["title"] ?? "Invalid",
      albumName: data["album"] ?? "Invalid",
      duration: duration ?? Duration(days: 100),
    );
  }

  @override
  Future<void> play() async => await _methodChannel.invokeMethod("play");

  @override
  Future<void> pause() async => await _methodChannel.invokeMethod("pause");

  @override
  Future<void> togglePause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _methodChannel.invokeMethod("seekTo", position.inMilliseconds);
  }

  @override
  Future<Duration> getPosition() async {
    final data = await _methodChannel.invokeMethod<int?>("getPosition");
    return Duration(milliseconds: data ?? 0);
  }

  @override
  Future<Image?> getImage() async {
    final bytes = await _methodChannel.invokeMethod<Uint8List>("getImageData");
    return bytes != null ? Image.memory(bytes) : null;
  }

  @override
  Future<bool> hasNotificationAccess() async {
    try {
      return await _methodChannel.invokeMethod('hasNotificationAccess');
    } on PlatformException catch (e) {
      print("Failed to get notification access: '${e.message}'.");
      return false;
    }
  }

  @override
  Future<void> openNotificationAccessSettings() async {
    await _methodChannel.invokeMethod("openNotificationAccessSettings");
  }

  @override
  Future<bool> update() async {
    return await _methodChannel.invokeMethod("update");
  }

  @override
  void dispose() {
    _subscription.cancel();
  }
}
