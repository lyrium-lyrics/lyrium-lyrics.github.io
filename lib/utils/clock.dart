class ClockManager {
  bool _playing = false;

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
    _playing = true;
    _startTime = DateTime.now().subtract(startfrom ?? _lastElapsed);

    _lastElapsed = Duration.zero;
    onUpdate?.call(_lastElapsed);
  }

  void pause() {
    _playing = false;
    // _timer?.cancel();
    if (_startTime != null) {
      _lastElapsed = DateTime.now().difference(_startTime!);
      _startTime = null;
    }

    onUpdate?.call(_lastElapsed);
  }

  Duration get elapsed => _startTime == null
      ? _lastElapsed
      : DateTime.now().difference(_startTime!);

  bool get playing => _playing;

  void dispose() {
    _playing = false;
  }
}
