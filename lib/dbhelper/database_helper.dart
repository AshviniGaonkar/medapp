import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "events.db";
  static const _databaseVersion = 1;

  static const table = 'events';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnTime = 'time';
  static const columnLocation = 'location';
  static const columnDate = 'date';
  static const columnIsSynced = 'isSynced';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var dbPath = await getDatabasesPath();
    var path = join(dbPath, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnTime TEXT NOT NULL,
      $columnLocation TEXT NOT NULL,
      $columnDate TEXT NOT NULL,
      $columnIsSynced INTEGER NOT NULL
    )
    ''');
  }

  Future<int> insertEvent(Map<String, dynamic> event) async {
    Database db = await database;
    return await db.insert(table, event);
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    Database db = await database;
    return await db.query(table);
  }

  Future<int> updateEventSyncStatus(String id, bool isSynced) async {
    Database db = await database;
    return await db.update(
      table,
      {columnIsSynced: isSynced ? 1 : 0},
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }
}


