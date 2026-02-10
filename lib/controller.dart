import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyrium/api.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/editor.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';
import 'package:lyrium/utils/demo_notification.dart';
import 'package:lyrium/widgets/submit_form.dart';

class AppController extends ChangeNotifier {
  // void submitLyrics(BuildContext context) {
  //   if (lyrics is DraftTrack) opensubmitform(context, lyrics as DraftTrack);
  // }

  // void openLyrics(LyricsTrack song, [autoplay = false]) {
  //   setLyrics(song);

  //   if (hasNotificationAccess) {
  //     demo_service.setTrack(song);
  //     setShowTrackMode(true);
  //   }

  //   if (autoplay) {
  //     selectedService.play();
  //   }

  //   notifyListeners();
  // }

  // void setHasAccess(bool? ac) {
  //   hasNotificationAccess = ac ?? false;

  //   notifyListeners();
  // }

  // // Future<void> rebuildUntil(bool Function() param0) async {
  // //   while (param0()) {
  // //     hasNotificationAccess =
  // //         await selectedService.hasNotificationAccess();
  // //     notifyListeners();
  // //     Future.delayed(Durations.extralong4);
  // //   }
  // // }

  // StreamSubscription? _notificationSubscription;
  // Timer? _polling;

  // // bool isReady = false;

  bool showTrack = false;

  // late GlobalKey rebuildKey;

  // Future<void> _init() async {
  //   await Future.delayed(Duration(seconds: 2));
  //   await _checkAccessAndStream();
  //   _startPolling();
  // }

  // void _startPolling() {
  //   _polling = Timer.periodic(const Duration(seconds: 5), (t) async {
  //     try {
  //       await selectedService.update();
  //     } catch (e) {
  //       debugPrint('Polling error: $e');
  //       t.cancel();
  //     }
  //   });
  // }

  // Future<void> _checkAccessAndStream() async {
  //   try {
  //     late Function(Map<dynamic, dynamic>? data) reader;

  //     reader = (Map<dynamic, dynamic>? data) {
  //       _setData(data);

  //       // if (isPlaying) {
  //       //   showTrack = true;
  //       // }

  //       reader = (Map<dynamic, dynamic>? data) => _setData(data);
  //     };

  //     if (hasNotificationAccess) {
  //       _notificationSubscription = selectedService.notifications.listen(
  //         (m) => reader(m),
  //       );
  //     }
  //   } on PlatformException catch (e) {
  //     debugPrint("Access check failed: ${e.message}");
  //   }
  // }

  // Future<void> startLyricsSaved(
  //   LyricsTrack track, [
  //   bool attached = false,
  // ]) async {
  //   await DataHelper.instance.saveTrack(track, info);
  //   setLyrics(track, attached);
  // }

  // // var unattachedMode = false;
  // void setLyrics(LyricsTrack? track, [bool attached = false]) {
  //   lyrics = track?.fallBackDuration();
  //   // unattachedMode = !attached;
  //   notifyListeners();
  // }

  // /// Control playback
  // Future<void> play() async => await selectedService.play();
  // Future<void> pause() async => await selectedService.pause();
  // Future<void> togglePause({bool? pause}) async => pause == null
  //     ? selectedService.togglePause()
  //     : pause
  //     ? selectedService.pause()
  //     : selectedService.play();

  // Future<void> seekTo(Duration? du) async {
  //   if (du == null) return;
  //   await selectedService.seekTo(du);
  // }

  // Future<Duration> position() async {
  //   return await selectedService.getPosition();
  // }

  // /// Open system settings for access
  // Future<void> openNotificationAccessSettings() async {
  //   await MusicNotificationService.openNotificationAccessSettings();
  //   await _checkAccessAndStream();
  // }

  // // double get progressValue => duration != null && duration!.inMilliseconds > 0
  // //     ? (progress?.inMilliseconds ?? 0) / (duration!.inMilliseconds)
  // //     : 0.0;

  // // String formatDuration(Duration? d) {
  // //   if (d == null) return '00:00';
  // //   final minutes = d.inMinutes.toString().padLeft(2, '0');
  // //   final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
  // //   return "$minutes:$seconds";
  // // }

  // @override
  // void dispose() {
  //   _polling?.cancel();
  //   _notificationSubscription?.cancel();
  //   super.dispose();
  // }

  static bool hasNotificationAccess = false;

  DemoNotificationService? demo_service = DemoNotificationService();
  MusicNotificationService? system_service = MusicNotificationService();

  late MusicNotificationService selectedService;

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
        image = selectedService!.getImage();
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

  // // void setInfo(Track? newinfo) {
  // //   info = newinfo;
  // //   notifyListeners();
  // // }

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
    demo_service?.setTrack(song);
    if (autoPlay) demo_service?.play();
    showTrack = true;
    notifyListeners();
  }
}

extension on LyricsTrack {
  LyricsTrack fallBackDuration() {
    if (track.duration.toDuration() < Durations.extralong4) {
      return copyWith(duration: Duration(hours: 1).toDouble());
    }
    return this;
  }
}

abstract class NonListeningController {
  final LyricsTrack lyrics;

  NonListeningController({required this.lyrics});
  Future<void> togglePause(bool b);
  Future<void> seek(Duration duration);

  bool get isPlaying;
  Duration? get atPosition;
  Duration get duration;
}

class TempController extends NonListeningController {
  final Future<void> Function(bool) onTogglePause;
  final Future<void> Function(Duration) onSeek;
  @override
  final Duration? atPosition;
  @override
  final bool isPlaying;
  TempController({
    required super.lyrics,
    required this.onTogglePause,
    required this.onSeek,
    required this.isPlaying,
    this.atPosition,
  });

  @override
  Future<void> seek(Duration duration) => onSeek(duration);
  @override
  Future<void> togglePause(bool b) => onTogglePause(b);
  @override
  Duration get duration => lyrics.track.duration.toDuration();
}

class NoOpController extends NonListeningController {
  NoOpController({required super.lyrics});

  @override
  Duration? get atPosition => Duration.zero;

  @override
  bool get isPlaying => true;

  @override
  Future<void> seek(Duration duration) async {}

  @override
  Future<void> togglePause(bool b) async {}

  @override
  Duration get duration => lyrics.track.duration.toDuration();
}
