import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/home.dart';
import 'package:lyrium/service/service.dart';
import 'package:lyrium/widgets/loader.dart';
import 'package:lyrium/widgets/settings.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = AppController();

  runApp(ChangeNotifierProvider(create: (_) => app, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      title: 'lyrium',
      home: InitialPage(),
    );
  }
}

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoaderWidget(
      future: _loadApp(context),
      onRoute: (access) {
        return MaterialPageRoute(builder: (c) => HomePage());
      },
      onConnection: (c, s) {
        return LinearProgressIndicator();
      },
      onError: (c, e) {
        return Center(child: Text("Unable To Start App"));
      },
    );
  }

  Future<bool> _loadApp(context) async {
    packageInfo = await PackageInfo.fromPlatform(
      baseUrl: "https://lyrium-lyrics.github.io/",
    );

    final access = await notificationService.hasNotificationAccess();
    AppController.hasNotificationAccess = access;
    // Provider.of<AppController>(context, listen: false);
    return access;
  }
}
