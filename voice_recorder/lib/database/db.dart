import 'package:voice_recorder/recorder/dataModel/record_item.dart';
import 'package:sqflite/sqflite.dart';

class MyDatabase {
  static const String DB_NAME = "record.db";
  static const String TABLE_NAME = "record";
  static const String COLUMN_ID = "id";
  static const String COLUMN_TITLE = "title";
  static const String COLUMN_FILE_PATH = "file_path";
  static const String COLUMN_CREATED_AT = "created_at";
  static const String COLUMN_UPDATED_AT = "updated_at";

  static MyDatabase? _singletonInstance;
  final Database? database;

  MyDatabase(this.database);

  static Future<MyDatabase> getInstance() async {
    _singletonInstance ??= MyDatabase(await initialize());
    return _singletonInstance!;
  }

  static Future<Database> initialize() async {
    var databasesPath = await getDatabasesPath();
    String path = '${databasesPath}record.db';
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $TABLE_NAME($COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_TITLE TEXT, $COLUMN_FILE_PATH TEXT, $COLUMN_CREATED_AT TEXT, $COLUMN_UPDATED_AT TEXT)",
        );
      },
    );
  }

  Future<List<RecordItem>> getRecords() async {
    List<Map<String, dynamic>> data =  await database!.query(TABLE_NAME);
    return data.map((e) => RecordItem.fromMap(e)).toList();
  }

  Future<RecordItem> getRecord(int id) async {
    List<Map<String, dynamic>> data =  await database!.query(
      TABLE_NAME,
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );
    return RecordItem.fromMap(data.first);
  }

  Future<int> insertRecord(String path, String title) async {
    DateTime now = DateTime.now();
    Map<String, dynamic> newItemMap = {
      COLUMN_TITLE: title,
      COLUMN_FILE_PATH: path,
      COLUMN_CREATED_AT: now.millisecondsSinceEpoch,
      COLUMN_UPDATED_AT: now.millisecondsSinceEpoch,
    };
    int id = await database!.insert(TABLE_NAME, newItemMap);
    return id;
  }

  Future<bool> updateRecordTitle(int id, String title) async {
    int affected = await database!.update(
      TABLE_NAME,
      {COLUMN_TITLE:title},
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );
    return affected > 0;
  }

  Future<int> deleteRecord(int id) async {
    return database!.delete(
      TABLE_NAME,
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );
  }
}