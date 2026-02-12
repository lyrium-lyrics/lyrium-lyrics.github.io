import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lyrium/api.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/editor.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';
import 'package:lyrium/utils/demo_notification.dart';

class AppController extends ChangeNotifier {
  bool showTrack = false;

  @override
  void dispose() {
    demo_service?.dispose();
    system_service?.dispose();

    super.dispose();
  }

  static bool hasNotificationAccess = false;

  DemoNotificationService? demo_service = DemoNotificationService();
  MusicService? system_service = notificationService;

  late MusicService selectedService;

  LyricsTrack? lyrics;
  Future<Image?>? image;

  AppController() {
    _init();
  }

  _init() {
    selectedService = hasNotificationAccess ? system_service! : demo_service!;
    showTrack = hasNotificationAccess;
    system_service!.start(
      onTrackChanged: (Track track) {
        loadOnChanged(track);
        image = selectedService.getImage();
      },
      onStateChanged: () {
        notifyListeners();
      },
      onUnsetTrack: () {
        selectedService = system_service!;
      },
    );
    demo_service!.start(
      onTrackChanged: (Track track) {
        // loadOnChanged(track);
        // image = selectedService!.getImage();
      },
      onStateChanged: () {
        // notifyListeners();
      },
      onUnsetTrack: () {
        // selectedService = system_service!;
      },
    );
  }

  Future<void> loadOnChanged(Track track) async {
    final data = await DataHelper.instance.getTrack(track);
    if (data != null) {
      lyrics = data;
    }

    notifyListeners();
  }

  void setShowTrackMode(bool mode) {
    showTrack = mode;
    notifyListeners();
  }

  openEditor(context, Track? initailQuery) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (c) => LyricsEditor(track: LyricsTrack.empty(initailQuery)),
      ),
    );
  }

  static bool isalreadyfetching = false;
  Future<void> fetchLyricsData(
    Track track, {
    required Function(dynamic e) onError,
  }) async {
    if (isalreadyfetching) {
      onError("Busy...");
    }
    isalreadyfetching = true;
    try {
      final data = await RequestHandler().get(track);
      if (data.isEmpty) {
        onError("No matches found");
      } else {
        openLyrics(data.first, autoPlay: false);
      }
    } catch (e) {
      onError(e);
    } finally {
      isalreadyfetching = false;
    }
  }

  void openLyrics(LyricsTrack song, {required bool autoPlay}) {
    selectedService = demo_service!;
    demo_service?.setTrack(song.track);
    if (autoPlay) demo_service?.play();
    lyrics = song;
    showTrack = true;
    notifyListeners();
  }
}

extension on LyricsTrack {
  LyricsTrack fallBackDuration() {
    if (track.duration < Durations.extralong4) {
      return copyWith(duration: Duration(hours: 1).toDouble());
    }
    return this;
  }
}

class TempController {
  final LyricsTrack lyrics;
  final MusicService service;

  TempController({required this.lyrics, required this.service});

  Duration? get elapsed => service.elapsed;

  bool get isPlaying => service.isPlaying;

  Future<void> seek(Duration duration) => service.seekTo(duration);
  Future<void> togglePause(bool b) => service.togglePause();
  Duration get duration => lyrics.track.duration;
}
