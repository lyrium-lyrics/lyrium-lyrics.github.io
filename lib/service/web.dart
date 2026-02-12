import 'package:drift/backends.dart';
import 'package:drift/wasm.dart';
import 'package:lyrium/utils/demo_notification.dart';

const bool isWeb = true;

Future<QueryExecutor> openPlatformConnection(
  String name, {
  bool? memoryMode,
}) async {
  // tests does not need memory mode for now.
  return WasmDatabase.open(
    databaseName: '$name.db',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.js'),
  ).then((t) {
    return t.resolvedExecutor;
  });
}

final notificationConnection = DemoNotificationService();
