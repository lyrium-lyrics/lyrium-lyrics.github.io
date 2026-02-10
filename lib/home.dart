import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/main.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/search.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/widgets/app_drawer.dart';
import 'package:lyrium/widgets/submit_form.dart';
import 'package:provider/provider.dart';
import 'package:lyrium/viewer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (BuildContext context, AppController app, Widget? child) {
        return Builder(
          builder: (context) {
            if (app.showTrack) {
              return Scaffold(
                drawer: AppDrawer(),
                appBar: buildLyricsAppBar(app),
                body: buildcontent(app),
              );
            } else {
              return QuickSearch(initailQuery: app.track);
            }
          },
        );
      },
    );
  }

  AppBar buildLyricsAppBar(AppController app) {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () => app.setShowTrackMode(false),
          icon: RotatedBox(quarterTurns: 1, child: Icon(Icons.chevron_right)),
        ),
      ],
      leading: FutureBuilder(
        future: app.image,
        builder: (c, s) => Padding(
          padding: EdgeInsetsGeometry.all(8.0),
          child: SizedBox(
            width: 30,
            height: 30,
            child: s.data ?? Icon(Icons.music_note),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            app.track?.trackName ?? "No Track",
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            app.track?.artistName ?? "No Artist",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildcontent(AppController app) {
    return Builder(
      builder: (context) {
        if (app.lyrics == null) {
          return Center(
            child: Builder(
              builder: (context) {
                if (AppController.hasNotificationAccess) {
                  if (app.track != null) {
                    return _buildFetcher(context, app);
                  } else {
                    return _buildNoMusic();
                  }
                } else {
                  return _buildAccessRequired(context, app);
                }
              },
            ),
          );
        }

        final track = app.lyrics;
        final isPlaying = app.selectedService.isPlaying;
        final atPosition = app.selectedService.progress;

        final textColor =
            Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

        var textStyle = TextStyle(
          fontSize: 40,

          fontWeight: FontWeight.w800,
          color: textColor.withAlpha(127),
        );
        var highlighttextStyle = TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: textColor,
        );

        return SizedBox(
          // width: 500,
          // height: 500,
          child: LyricsView(
            controller: TempController(
              lyrics: track ?? LyricsTrack.empty(),
              isPlaying: isPlaying,
              atPosition: atPosition,
              onTogglePause: (b) => app.selectedService.togglePause(),
              onSeek: app.seekTo,
            ),
            textStyle: textStyle,
            highlightTextStyle: highlighttextStyle,
            completedTextStyle: highlighttextStyle.copyWith(
              color: highlighttextStyle.color?.withAlpha(200),
            ),
            onSave: () => opensubmitform(
              context,
              DraftTrack.from(app.lyrics!, app.lyrics!.syncedLyrics!),
            ),
          ),
        );
      },
    );
  }

  PreferredSize buildnotificationpr(AppController app) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(5),
      child: LinearProgressIndicator(
        value: app.progressValue,
        backgroundColor: app.lyrics != null ? null : Colors.transparent,
      ),
    );
  }

  bool busyFeching = false;

  Widget _buildFetcher(BuildContext context, AppController app) {
    return GestureDetector(
      onTap: () async {
        app.fetchLyricsData(
          app.track,
          onError: (dynamic e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error Fetching: $e")));
          },
        );
        // if (busyFeching) return;
        // try {
        //   busyFeching = true;
        //   setState(() {});
        //   await app.loadOnChanged();
        // } catch (e) {

        //   app.setShowTrackMode(false);
        // } finally {
        //   setState(() {});
        //   busyFeching = false;
        // }
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedPadding(
              padding: busyFeching
                  ? EdgeInsetsGeometry.all(20)
                  : EdgeInsetsGeometry.all(0),
              duration: Durations.long1,
              child: FutureBuilder(
                future: app.image,
                builder: (c, s) {
                  return s.data ??
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                          child: Icon(
                            Icons.music_note,
                            size: 300,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      );
                },
              ),
            ),
            SizedBox(height: 30),
            FittedBox(
              child: Text(
                app.track?.trackName ?? "",
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Text(app.track?.artistName ?? ""),
            busyFeching
                ? LinearProgressIndicator()
                : Text(
                    "Search",
                    style: TextStyle(color: Colors.grey.withAlpha(100)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMusic() => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.select_all, size: 80, color: Colors.deepPurple),
      SizedBox(height: 16),
      Text(
        'No Music Playing',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),
      Text('Start playing a song to see info here.'),
    ],
  );

  Widget _buildAccessRequired(BuildContext context, AppController? app) {
    if (app == null) {
      return LinearProgressIndicator();
    }
    if (AppController.hasNotificationAccess) {
      return IconButton(onPressed: () {}, icon: Icon(Icons.search));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_off, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        const Text("Enable Notification Access?"),
        ElevatedButton(
          onPressed: () => openSettingsThenRestart(context),
          child: const Text("Grant Access"),
        ),
      ],
    );
  }
}

extension on AppController {
  Future<void> Function(Duration) get seekTo => selectedService.seekTo;

  // Future<Duration> Function() get position =>
  //     () => selectedService.progress ?? Duration.zero;

  double? get progressValue => 0.0;

  get track => selectedService.track;
}

Future<void> openSettingsThenRestart(BuildContext context) async {
  await MusicNotificationService.openNotificationAccessSettings();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (c) => InitialPage()),
  );
}
