const _kDefault = "--:--";

extension DoubleDuration on double? {
  Duration toDuration() {
    if (this == null) return const Duration();
    final totalSeconds = this!;
    final seconds = totalSeconds.truncate();
    final milliseconds = ((totalSeconds - seconds) * 1000).round();
    return Duration(seconds: seconds, milliseconds: milliseconds);
  }

  toShortString() {
    if (this == null) return _kDefault;
    final totalSeconds = this!;
    final seconds = totalSeconds.truncate();
    return intDisplay(seconds);
  }
}

intDisplay(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

extension DynamicDuration on int? {
  Duration fromLongInt() => Duration(milliseconds: this ?? 0);
}

extension DurationDouble on Duration? {
  double get inDouble => toDouble();
  double toDouble() {
    if (this == null) return 0.0;
    final duration = this!;
    return duration.inSeconds +
        duration.inMilliseconds.remainder(1000) / 1000.0;
  }

  String toShortString() =>
      this == null ? _kDefault : intDisplay(this!.inSeconds);
}
