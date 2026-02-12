import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/datahelper.dart';
import 'package:lyrium/models.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/widgets/settings.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            onTap: () => Provider.of<AppController>(
              context,
              listen: false,
            ).setShowTrackMode(true),
            leading: Icon(Icons.play_arrow),
            title: Text("Now Playing"),
          ),
          ListTile(
            onTap: () => shareDB(context),
            leading: Icon(Icons.copy),
            title: Text("Export"),
          ),
          ListTile(
            onTap: () => importDB(context),
            leading: Icon(Icons.paste),
            title: Text("Import"),
          ),

          ListTile(
            onTap: () => showAboutDialog(
              context: context,
              applicationVersion: packageInfo.version,
              children: [
                isWebsite
                    ? CopyValueButton(
                        value:
                            "https://github.com/fsdtmr/lyrium/releases/latest",
                        label: Text("Latest Release"),
                        icon: Icon(Icons.file_open),
                      )
                    : CopyValueButton(
                        value: "https://lyrium-lyrics.github.io/index.html",
                        label: Text("Web Version"),
                        icon: Icon(Icons.web),
                      ),
                CopyValueButton(
                  value: "https://github.com/fsdtmr/lyrium",
                  label: Text("Github"),
                  icon: Icon(Icons.storage),
                ),
                // Text(
                //   packageInfo.buildSignature,
                //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                //     color: Colors.grey.withAlpha(100),
                //   ),
                // ),
              ],
            ),
            leading: Icon(Icons.info),
            title: Text("About"),
          ),
        ],
      ),
    );
  }

  void shareDB(context) {
    DataHelper.instance
        .searchTracks("")
        .then((e) {
          final exportable = e.map((e) => e.toMap()).toList();

          final value = jsonEncode(exportable);

          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${exportable.length} Items Exported to Clipboard"),
            ),
          );
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to Export $e"),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  Future<void> importDB(context) async {
    int importcount = 0;
    Clipboard.getData("text/plain").then((d) {
      try {
        final decoded = jsonDecode(d!.text!);

        decoded.map((e) {
          try {
            final track = LyricsTrack.fromMap("imported", e);

            DataHelper.instance.insert(track);

            importcount++;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to Read $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }).toList();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to Import $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        ScaffoldMessenger.of(context).showSnackBar(
          (SnackBar(
            content: importcount != 0
                ? Text("$importcount Items Imported")
                : Text("Nothing Imported"),
          )),
        );
      }
    });
  }
}

class CopyValueButton extends StatelessWidget {
  final Widget label;
  final String value;
  final Widget icon;
  const CopyValueButton({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Copied to Clipboard")));
      },
      label: label,
      icon: icon,
    );
  }
}
