import 'package:lyrium/storage/local.dart';
import 'package:lyrium/utils/duration.dart';

class Track {
  final String namespace;
  final String artistName;
  final String trackName;
  final String albumName;
  final Duration duration; // ss.mss

  Track({
    required this.namespace,
    required this.artistName,
    required this.trackName,
    required this.albumName,
    required this.duration,
  });

  static Track fromMap(Map<String, dynamic> map) {
    return Track(
      namespace: map['namespace'] ?? "",
      trackName: map['trackName'] ?? "",
      artistName: map['artistName'] ?? "",
      albumName: map['albumName'] ?? "",
      duration: map['duration'] ?? 0.0,
    );
  }

  static Track fromDrift(Lyric lyric) {
    return Track(
      trackName: lyric.title,
      artistName: lyric.artist ?? "Unknown",
      albumName: lyric.album ?? "Unknown",
      duration: lyric.duration.toDuration(),
      namespace: lyric.namespace,
    );
  }

  Track copyWith({
    String? namespace,
    String? trackName,
    String? artistName,
    String? albumName,
    Duration? duration,
  }) {
    return Track(
      namespace: namespace ?? this.namespace,
      trackName: trackName ?? this.trackName,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      duration: duration ?? this.duration,
    );
  }
}

class LyricsTrack {
  final int id;
  final Track track;
  final bool? instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsTrack({
    required this.id,
    required this.track,
    this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
  });
  @override
  String toString() {
    return toMap().toString();
  }

  static LyricsTrack fromMap(String namespace, Map<String, dynamic> map) {
    return LyricsTrack(
      id: map['id'],
      instrumental: map['instrumental'] == 1,
      plainLyrics: map['plainLyrics'],
      syncedLyrics: map['syncedLyrics'],
      track: Track.fromMap(map),
    );
  }

  Map<String, dynamic> toMap({Track? info}) {
    return {
      'id': id,
      'trackName': info?.trackName ?? track.trackName,
      'artistName': info?.artistName ?? track.artistName,
      'albumName': info?.albumName ?? track.albumName,
      'duration': info?.duration ?? track.duration,
      'instrumental': instrumental == true ? 1 : 0,
      'plainLyrics': plainLyrics,
      'syncedLyrics': syncedLyrics,
    };
  }

  static LyricsTrack fromDrift(Lyric lyric) {
    return LyricsTrack(
      id: lyric.id,
      track: Track.fromDrift(lyric),
      instrumental: lyric.instrumental ?? false,
      plainLyrics: lyric.lyrics,
      syncedLyrics: lyric.lyrics,
    );
  }

  Track toInfo() {
    return track;
  }

  static LyricsTrack empty([Track? initailQuery]) {
    return LyricsTrack(id: -1, track: initailQuery ?? Track.fromMap({}));
  }

  LyricsTrack copyWith({
    int? id,
    String? namespace,
    String? trackName,
    String? artistName,
    String? albumName,
    double? duration,
    bool? instrumental,
    String? plainLyrics,
    String? syncedLyrics,
  }) {
    return LyricsTrack(
      id: id ?? this.id,
      track: track.copyWith(
        namespace: namespace,
        trackName: trackName,
        artistName: artistName,
        albumName: albumName,
        duration: duration.toDuration(),
      ),

      instrumental: instrumental ?? this.instrumental,
      plainLyrics: plainLyrics ?? this.plainLyrics,
      syncedLyrics: syncedLyrics ?? this.syncedLyrics,
    );
  }
}

class DraftTrack extends LyricsTrack {
  final String newText;

  DraftTrack({
    required super.id,

    required this.newText,
    super.instrumental,
    super.plainLyrics,
    super.syncedLyrics,
    required super.track,
  });

  factory DraftTrack.from(LyricsTrack track, String s) {
    return DraftTrack(
      newText: s,

      id: track.id,

      instrumental: track.instrumental,
      plainLyrics: track.plainLyrics,
      syncedLyrics: track.syncedLyrics,
      track: track.track,
    );
  }
}
