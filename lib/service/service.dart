// connection.dart
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:lyrium/models.dart';

import "none.dart"
    if (dart.library.js_interop) "web.dart"
    if (dart.library.io) "native.dart";

bool isWebsite = isWeb;

LazyDatabase openConnection(String name, {bool? memoryMode}) {
  return LazyDatabase(
    () => openPlatformConnection(name, memoryMode: memoryMode),
  );
}

abstract class MusicService {
  Track? track;
  Duration? duration;
  Duration? progress;
  bool isPlaying = false;

  /// Starts listening to state changes.
  void start({
    required Function(Track track) onTrackChanged,
    required Function() onStateChanged,
    required Function() onUnsetTrack,
  });

  Future<void> play();
  Future<void> pause();
  Future<void> togglePause(); // Added for convenience
  Future<void> seekTo(Duration position);
  Future<Duration> getPosition();
  Future<Image?> getImage();

  // Platform specific settings
  Future<bool> hasNotificationAccess();
  Future<void> openNotificationAccessSettings();
  Future<void> update();
  void dispose();
}

final MusicService notificationService = notificationConnection;
