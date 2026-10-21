import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openHistoraDatabase({
  required Future<void> Function(Database db) onCreate,
}) async {
  return openDatabase(
    join(await getDatabasesPath(), 'histora.db'),
    version: 1,
    onCreate: (db, _) => onCreate(db),
  );
}
