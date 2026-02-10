import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lyrium/models.dart';

class RequestHandler {
  String namespace = "lrclib";
  final String baseUrl;

  RequestHandler({this.baseUrl = 'https://lrclib.net'});

  Future<T> _get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParameters);
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'lyrium/2.*.*'},
    );
    switch (response.statusCode) {
      case 200:
        break;
      case 404:
        throw Exception("This music did not match any songs");
      default:
        throw Exception("API Responded With Status ${response.statusCode}");
    }
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as T;
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<List<LyricsTrack>> searchTracks(String query) async {
    final res = await _get<List<dynamic>>(
      '/api/search',
      queryParameters: {'q': query.split("-").first},
    );
    return mapTracks(res);
  }

  Future<List<LyricsTrack>> get(Track inf) async {
    final res = await _get(
      '/api/get',
      queryParameters: {
        'artist_name': inf.artistName,
        'track_name': inf.trackName,
        'album_name': inf.albumName,
        'duration': inf.duration.toString(),
      },
    );
    return mapTracks([res]);
  }

  List<LyricsTrack> mapTracks(List<dynamic> jsonList) {
    List<LyricsTrack> tracks = [];
    for (var element in jsonList) {
      try {
        final track = LyricsTrack.fromMap(
          namespace,
          element as Map<String, dynamic>,
        );

        tracks.add(track);
      } catch (e) {
        print("Parsing Error: $e");
      }
    }

    return tracks;
  }
}
