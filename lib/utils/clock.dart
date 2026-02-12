import 'dart:async';

class ClockManager {
  Timer? _timer;

  final Function(Duration elapsed)? onUpdate;
  DateTime? _startTime;
  Duration _lastElapsed = Duration.zero;

  ClockManager(this.onUpdate);

  void seek(Duration seekto) {
    _startTime = DateTime.now().subtract(seekto);
    _lastElapsed = Duration.zero;

    onUpdate?.call(elapsed);
  }

  void play({Duration? startfrom}) {
    _timer = Timer.periodic(const Duration(milliseconds: 556), (timer) {
      onUpdate?.call(elapsed);
    });

    _startTime = DateTime.now().subtract(startfrom ?? _lastElapsed);

    _lastElapsed = Duration.zero;
  }

  void pause() {
    _timer?.cancel();
    if (_startTime != null) {
      _lastElapsed = DateTime.now().difference(_startTime!);
      _startTime = null;
    }

    onUpdate?.call(_lastElapsed);
  }

  Duration get elapsed => _startTime == null
      ? _lastElapsed
      : DateTime.now().difference(_startTime!);

  bool get paused => _timer == null ? true : !_timer!.isActive;

  void dispose() {
    _timer?.cancel();
  }
}
