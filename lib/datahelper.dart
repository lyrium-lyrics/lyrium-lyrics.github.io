import 'package:drift/drift.dart';
import 'package:lyrium/storage/local.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/search_terms.dart';

class DataHelper {
  DataHelper._privateConstructor();
  static final DataHelper instance = DataHelper._privateConstructor();

  final AppDatabase db = AppDatabase();

  static bool isUpdated = false;

  /// Insert a new track and its lyrics
  Future<int> saveTrack(LyricsTrack data, Track? extra) async {
    isUpdated = true;

    LyricsTrack? existing = await fallbackfinder(data.track);

    if (existing != null) {
      if (existing.syncedLyrics == data.syncedLyrics) {
        await insertlinked(data.track, existing.id);
        return existing.id;
      }
    }

    final lyricId = await db
        .into(db.lyrics)
        .insertReturning(
          LyricsCompanion.insert(
            originId: Value("${data.id}"),
            namespace: Value(data.track.namespace),
            title: data.track.trackName,
            artist: Value(data.track.artistName),
            album: Value(data.track.albumName),
            duration: data.track.duration,
            instrumental: Value(data.instrumental == true),
            lyrics: Value(data.syncedLyrics ?? data.plainLyrics ?? ''),
          ),
        );

    if (extra != null) {
      await insertlinked(extra, lyricId.id);
    }

    return -1;
  }

  Future<void> insertlinked(Track extra, int refid) async {
    await db
        .into(db.lyrics)
        .insert(
          LyricsCompanion.insert(
            originId: Value("local"),
            namespace: Value(extra.namespace),
            title: extra.trackName,
            artist: Value(extra.artistName),
            album: Value(extra.albumName),
            duration: extra.duration,
            interlinked: Value(refid),
          ),
        );
  }

  /// Search for tracks
  Future<List<LyricsTrack>> searchTracks(String text) async {
    if (text.trim().isEmpty) {
      return instance.db.all().then(
        (e) => e.map((e) => LyricsTrack.fromDrift(e)).toList(),
      );
    }
    final terms = SearchTerms.parse(text);

    final filter = db.buildSearchFilter(terms);

    final q = db.select(db.lyrics)..where((tbl) => filter);
    final result = await q.get();

    return result.map((e) => LyricsTrack.fromDrift(e)).toList();
  }

  Future<LyricsTrack?> getTrack(Track trackInfo) async {
    final q = db.select(db.lyrics)
      ..where(
        (t) =>
            t.title.equals(trackInfo.trackName) &
            t.artist.equals(trackInfo.artistName) &
            t.album.equals(trackInfo.albumName),
      )
      ..limit(1);

    final result = await q.getSingleOrNull();
    if (result == null) {
      return fallbackfinder(trackInfo);
    }

    return LyricsTrack.fromDrift(result);
  }

  Future<bool> updateTrack(LyricsTrack data) async {
    isUpdated = true;

    final q = db.update(db.lyrics)..where((t) => t.id.equals(data.id));

    final track = data.track;
    final updated = await q.write(
      LyricsCompanion(
        title: Value(track.trackName),
        artist: Value(track.albumName),
        album: Value(track.albumName),
        duration: Value(track.duration),
        instrumental: Value(data.instrumental ?? false),
        lyrics: Value(data.syncedLyrics ?? data.plainLyrics ?? ''),
      ),
    );

    return updated > 0;
  }

  Future<int> delete(LyricsTrack track) async {
    isUpdated = true;

    return (db.delete(db.lyrics)..where((t) => t.id.equals(track.id))).go();
  }

  /// Close database connection
  Future<void> close() => db.close();

  Future<List<Lyric>> insertDraft(title, artist, lyrics, duration) {
    isUpdated = true;

    return db
        .into(db.lyrics)
        .insert(
          LyricsCompanion.insert(
            title: title,
            artist: Value(artist),
            duration: duration,
            lyrics: Value(lyrics),
            namespace: Value("Draft"),
          ),
        )
        .then((c) {
          return (db.select(db.lyrics)..where((u) => u.id.equals(c))).get();
        });
  }

  Future<LyricsTrack?> fallbackfinder(Track trackInfo) async {
    List<Lyric> sel = await (db.select(
      db.lyrics,
    )..where((u) => u.title.contains(trackInfo.trackName))).get();

    if (sel.isEmpty) {
      sel = await db.all();
    }
    for (var element in sel) {
      if (trackInfo.trackName.contains(element.title)) {
        return LyricsTrack.fromDrift(element);
      }
    }
    return null;
  }
}
