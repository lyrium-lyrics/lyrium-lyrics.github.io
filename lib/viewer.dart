import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/editor.dart';
import 'package:lyrium/utils/clock.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/utils/duration.dart';
import 'package:lyrium/utils/lrc.dart';
import 'package:collection/collection.dart';

class LyricsView extends StatefulWidget {
  final NonListeningController controller;

  final Future<void> Function() onSave;

  final TextStyle? textStyle;
  final TextStyle? highlightTextStyle;
  final TextStyle? completedTextStyle;
  final bool? editMode;
  const LyricsView({
    super.key,
    required this.controller,
    required this.onSave,
    this.textStyle,
    this.highlightTextStyle,
    this.editMode,
    this.completedTextStyle,
  });

  bool get isEditMode => editMode ?? false;

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  late List<LRCLine> lyrics;

  late Duration duration = const Duration(seconds: 0);
  double position = 0.0;
  Duration newPosition = const Duration(seconds: 0);
  int lyindex = -1;
  late ClockManager watchManager;

  late List<GlobalKey> keys;

  @override
  void initState() {
    duration = widget.controller.duration;

    lyrics = widget.controller.lyrics.lines.withDuration;
    keys = List<GlobalKey>.generate(lyrics.length, (i) => GlobalKey());

    buildSpans();

    // watchManager = ClockManager((Duration elapsed) {
    //   if (mounted) {
    //     if (elapsed > duration) {
    //       elapsed = duration;
    //       watchManager.pause();
    //     }

    //     setState(() {
    //       newPosition = elapsed;
    //       position = elapsed.inMilliseconds / duration.inMilliseconds;

    //       lyindex = lyrics.position(newPosition, lyindex);
    //     });
    //     scrollto(lyindex);
    //   }
    // });
    // Future.microtask(() async {
    //   watchManager.seek(await widget.controller.getPosition());
    //   if (widget.controller.isPlaying) {
    //     watchManager.play(startfrom: widget.controller.atPosition);
    //   }
    // });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LyricsView oldWidget) {
    if (widget.controller.isPlaying != oldWidget.controller.isPlaying) {
      if (oldWidget.controller.isPlaying != widget.controller.isPlaying) {
        if (widget.controller.isPlaying) {
          watchManager.play();
          watchManager.seek(
            widget.controller.atPosition ?? watchManager.elapsed,
          );
        } else {
          watchManager.pause();
          // Bug: seeking creates a invalid state
          // watchManager.seek(widget.controller.atPosition ?? watchManager.elapsed);
        }
      }
    } else if (widget.controller.atPosition !=
        oldWidget.controller.atPosition) {
      watchManager.seek(widget.controller.atPosition ?? watchManager.elapsed);
    }

    super.didUpdateWidget(oldWidget);
  }

  late List<TextSpan> spans;

  buildSpans() {
    spans = lyrics
        .mapIndexed(
          (index, line) => TextSpan(
            children: [
              WidgetSpan(
                child: SizedBox.fromSize(size: Size.zero, key: keys[index]),
              ),
              TextSpan(
                text: "${line.text}\n",
                recognizer: TapGestureRecognizer()
                  ..onTap = () => incrementLyric(index - lyindex),
                style: index == lyindex
                    ? widget.highlightTextStyle
                    : index < lyindex
                    ? widget.completedTextStyle
                    : widget.textStyle,
              ),
            ],
          ),
        )
        .toList();
  }

  higlight() {
    buildSpans();
  }

  TextStyle textDectoration = TextStyle(height: 1.5);

  @override
  Widget build(BuildContext context) {
    if (lyrics.isEmpty) {
      return const Center(child: Text("No lyrics available"));
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              if (animating) {
                notification.disallowIndicator();
              }
              return true;
            },
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(style: textDectoration, children: spans),
              ),
            ),
          ),
        ),

        bottomNavigationBar: buildControls(context),
      ),
    );
  }

  SizedBox buildControls(BuildContext context) {
    return SizedBox(
      height: 120, // Increased height
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(width: 8.0),
              Text(
                newPosition.toShortString(),
                style: const TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(value: position, onChanged: onSeeked),
              ),
              Text(
                widget.controller.lyrics.track.duration.toShortString() ??
                    "-----",
                style: const TextStyle(fontSize: 12),
              ),

              SizedBox(width: 8.0),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: () {
                  widget.isEditMode
                      ? Navigator.pop(context)
                      : Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (c) =>
                                LyricsEditor(track: widget.controller.lyrics),
                          ),
                        );
                },
              ),
              Spacer(),
              IconButton(
                icon: const Icon(Icons.fast_rewind),
                onPressed: () {
                  incrementLyric(-1);
                },
              ),
              IconButton(
                icon: Icon(
                  watchManager.paused ? Icons.play_arrow : Icons.pause,
                ),
                onPressed: () {
                  watchManager.paused
                      ? watchManager.play()
                      : watchManager.pause();

                  widget.controller.togglePause(watchManager.paused);
                },
              ),
              IconButton(
                icon: const Icon(Icons.fast_forward),
                onPressed: () {
                  incrementLyric(1);
                },
              ),

              Spacer(),

              IconButton(
                onPressed: () => widget.onSave(),
                icon: Icon(Icons.bookmark_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onSeeked(double value) {
    newPosition = duration * value;

    setState(() {
      position = value;

      lyindex = lyrics.position(newPosition, lyindex); //findlyric(newPosition);
    });

    watchManager.seek(newPosition);

    widget.controller.seek(newPosition);
  }

  void incrementLyric(int i) {
    var nextindex = (lyindex += i)
        .remainder(lyrics.length)
        .clamp(0, lyrics.length - 1);
    setState(() {
      lyindex = nextindex;
      newPosition = lyrics[lyindex].timestamp;
      position = newPosition.inMilliseconds / duration.inMilliseconds;
      higlight();
    });

    watchManager.seek(newPosition);

    widget.controller.seek(newPosition);
  }

  int animatingto = -1;
  bool animating = false;

  void scrollto(int lyindex) {
    if (animatingto == lyindex) return;
    higlight();
    animating = true;

    final context = keys[lyindex].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Durations.short4,
        alignment: .3,
        curve: Curves.easeInOut,
      ).then((q) {
        animating = false;
      });
    }
    // }
    animatingto = lyindex;
  }
}

extension on List<Line> {
  List<LRCLine> get withDuration => whereType<LRCLine>().toList();
}

extension LyricsTrackExt on LyricsTrack? {
  List<Line> get lines =>
      toLRCLineList(this?.syncedLyrics ?? "", musicNoteString);
  String get editable => this?.syncedLyrics ?? this?.plainLyrics ?? "";
}
