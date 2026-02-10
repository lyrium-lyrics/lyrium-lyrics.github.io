import 'package:flutter/widgets.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/utils/clock.dart';
import 'package:lyrium/utils/duration.dart';

class DemoNotificationService implements MusicNotificationService {
  ClockManager clock = ClockManager(onUpdate);

  Track? track;

  setTrack(LyricsTrack? newtrack) {
    track = track;
    clock = ClockManager(onUpdate);
    onUpdate(clock.elapsed);
  }

  static onUpdate(Duration elapsed) {}

  @override
  Future<Image?> getImage() async {
    return null;
  }

  @override
  Future<Duration> getPosition() {
    // TODO: implement getPosition
    throw UnimplementedError();
  }

  @override
  // TODO: implement notifications
  Stream<Map<dynamic, dynamic>?> get notifications =>
      throw UnimplementedError();

  @override
  Future<void> pause() {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  Future<void> play() async {
    clock.play();
  }

  @override
  Future<void> seekTo(Duration du) async {
    clock.seek(du);
  }

  @override
  togglePause() {
    clock.paused ? clock.play() : clock.pause();
  }

  @override
  Future<dynamic> update() async {
    onUpdate(clock.elapsed);
  }

  @override
  Duration get duration => track?.duration.toDuration() ?? Duration.zero;

  @override
  Track? info;

  @override
  bool get isPlaying => !clock.paused;

  @override
  Duration? progress;

  @override
  Track parseData(Map<dynamic, dynamic> data) {
    // TODO: implement parseData
    throw UnimplementedError();
  }

  @override
  Future<void> seekFraction(double fraction) {
    // TODO: implement seekFraction
    throw UnimplementedError();
  }

  @override
  set isPlaying(bool value) {
    // TODO: implement isPlaying
  }

  @override
  set duration(Duration? value) {
    // TODO: implement duration
  }

  @override
  void start({
    required Function(Track track) onTrackChanged,
    required Function() onStateChanged,
    required Function() onUnsetTrack,
  }) {}
}
