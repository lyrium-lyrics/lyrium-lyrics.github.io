// connection.dart
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';

import "none.dart"
    if (dart.library.js_interop) "web.dart"
    if (dart.library.io) "native.dart";

bool isWebsite = isWeb;

LazyDatabase openConnection(String name, {bool? memoryMode}) {
  return LazyDatabase(
    () => openPlatformConnection(name, memoryMode: memoryMode),
  );
}

class MusicNotificationService {
  Stream<Map?> get notifications => NotificationConnection.notifications;
  Future<Image?> getImage() => NotificationConnection.getImage();
  Future<Duration> getPosition() => NotificationConnection.getPosition();
  static Future<bool?> hasNotificationAccess() =>
      NotificationConnection.hasNotificationAccess();
  static Future<void> openNotificationAccessSettings() =>
      NotificationConnection.openNotificationAccessSettings();
  Future<void> pause() => NotificationConnection.pause();
  Future<void> play() => NotificationConnection.play();
  Future<void> seekFraction(double fraction) async {
    if (duration == null) return;
    await seekTo(duration! * fraction);
  }

  Future<void> seekTo(Duration du) async {
    await NotificationConnection.seekTo(du);
    return;
  }

  togglePause() => NotificationConnection.togglePause();
  Future<dynamic> update() => NotificationConnection.update();

  static var IS_PLAYING = 'isPlaying';
  Duration? duration;
  Duration? progress;
  bool isPlaying = false;
  Track? track;

  Track parseData(Map<dynamic, dynamic> data) {
    duration = Duration(milliseconds: (data["duration"] as int?) ?? 0);
    progress = Duration(milliseconds: (data["position"] as int?) ?? 0);
    isPlaying = data[IS_PLAYING] as bool? ?? false;
    return Track(
      namespace: data["package"] ?? "Device",
      artistName: data["artist"] ?? "Invalid",
      trackName: data["title"] ?? "Invalid",
      albumName: data["album"] ?? "Invalid",
      duration: duration?.inDouble ?? 1,
    );
  }

  void start({
    required Function(Track track) onTrackChanged,
    required Function() onStateChanged,
    required Function() onUnsetTrack,
  }) {
    notifications.listen((data) {
      if (data == null) {
        track = null;
        return;
      } else {
        final prevName = track?.trackName;

        track = parseData(data);

        if (prevName != track?.trackName) {
          if (track == null) {
            onUnsetTrack();
          } else {
            onTrackChanged(track!);
          }
        } else {
          onStateChanged();
        }
      }
    });
  }
}
