import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<Database> openHistoraDatabase({
required Future<void> Function(Database db) onCreate,
}) {
return databaseFactoryFfiWeb.openDatabase(
'histora_web.db',
options: OpenDatabaseOptions(
version: 1,
onCreate: (db, version) => onCreate(db),
),
);
}
