import 'package:flutter/widgets.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/utils/clock.dart';

class DemoNotificationService extends MusicService {
  late ClockManager _clock;
  VoidCallback? _onStateChangedCallback;

  DemoNotificationService() {
    _clock = ClockManager((d) => _triggerUpdate());
  }

  @override
  Track? track;

  void setTrack(Track? newTrack) {
    track = newTrack;
    _clock = ClockManager((d) => _triggerUpdate());
    _triggerUpdate();
  }

  void _triggerUpdate() {
    _onStateChangedCallback?.call();
  }

  @override
  Duration get duration => track?.duration ?? Duration.zero;

  @override
  bool get isPlaying => !_clock.playing;

  @override
  Duration? get elapsed => looped();

  looped() {
    if (_clock.elapsed >= track!.duration) _clock.seek(Duration.zero);
    return _clock.elapsed;
  }

  @override
  void start({
    required Function(Track track) onTrackChanged,
    required Function() onStateChanged,
    required Function() onUnsetTrack,
  }) {
    _onStateChangedCallback = onStateChanged;
  }

  @override
  Future<void> play() async {
    _clock.play();
    _triggerUpdate();
  }

  @override
  Future<void> pause() async {
    _clock.pause();
    _triggerUpdate();
  }

  @override
  Future<void> togglePause() async {
    _clock.playing ? _clock.play() : _clock.pause();
    _triggerUpdate();
  }

  @override
  Future<void> seekTo(Duration position) async {
    _clock.seek(position);
    _triggerUpdate();
  }

  // --- Stubs for unsupported features in Dummy mode ---

  @override
  Future<Image?> getImage() async => null;

  @override
  Future<Duration> getPosition() async => _clock.elapsed;

  @override
  Future<bool> hasNotificationAccess() async => true;

  @override
  Future<void> openNotificationAccessSettings() async {
    // No-op for dummy
  }

  @override
  Future<void> update() async {
    _triggerUpdate();
  }

  @override
  void dispose() {
    _clock.dispose();
  }
}
