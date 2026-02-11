import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/widgets/settings.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

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
          // ListTile(
          //   onTap: () => shareDB(),
          //   leading: Icon(Icons.import_export),
          //   title: Text("Export"),
          // ),
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

  void shareDB() {
    // SharePlus.instance.share(ShareParams(files: [
    //   D
    //   XFile(path)
    // ]));
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
