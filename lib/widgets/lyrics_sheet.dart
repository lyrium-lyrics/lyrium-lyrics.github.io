import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/models.dart';
import 'package:provider/provider.dart';

void showLyricsSheet(
  BuildContext context,
  LyricsTrack song,
  bool isSaved,
  onParentChanged,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scroll) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final ctrl = Provider.of<AppController>(
                          context,
                          listen: false,
                        );
                        ctrl.openLyrics(song, autoPlay: true);

                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.play_arrow),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.artist,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scroll,
                    child: Text(
                      song.lyrics,
                      style: const TextStyle(height: 1.45, fontSize: 15),
                    ),
                  ),
                ),

                Row(
                  children: [
                    isSaved
                        ? IconButton(
                            onPressed: () =>
                                DataHelper.instance.delete(song).then((c) {
                                  if (c != 0) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Deleted')),
                                    );
                                    onParentChanged();
                                  }
                                }),
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                          )
                        : IconButton(
                            onPressed: () => DataHelper.instance
                                .saveTrack(song, null)
                                .then((c) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved')),
                                  );
                                }),
                            icon: const Icon(Icons.save_outlined),
                            tooltip: 'Save',
                          ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}

extension on LyricsTrack {
  String get lyrics => syncedLyrics ?? plainLyrics ?? "";

  String get title => track.trackName;

  String get artist => track.artistName;
}
