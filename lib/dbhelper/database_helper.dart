import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "events.db";
  static const _databaseVersion = 1;

  static const eventTable = 'events';
  static const attendanceTable = 'attendance';

  // Events Table Columns
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnTime = 'time';
  static const columnLocation = 'location';
  static const columnDate = 'date';
  static const columnIsSynced = 'isSynced';

  // Attendance Table Columns
  static const columnEventId = 'eventId';
  static const columnStudentId = 'studentId';
  static const columnAttendanceDate = 'date';
  static const columnPresent = 'present';

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
    CREATE TABLE $eventTable (
      $columnId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnTime TEXT NOT NULL,
      $columnLocation TEXT NOT NULL,
      $columnDate TEXT NOT NULL,
      $columnIsSynced INTEGER NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE $attendanceTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnEventId TEXT NOT NULL,
      $columnStudentId TEXT NOT NULL,
      $columnAttendanceDate TEXT NOT NULL,
      $columnPresent INTEGER NOT NULL
    )
    ''');
  }

  /// Insert Event (Avoid Duplicate)
  Future<int> insertEvent(Map<String, dynamic> event) async {
    Database db = await database;
    return await db.insert(eventTable, event, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Get All Events
  Future<List<Map<String, dynamic>>> getEvents() async {
    Database db = await database;
    return await db.query(eventTable);
  }

  /// Check if Event Exists
  Future<bool> eventExists(String eventId) async {
    var db = await database;
    var result = await db.query(eventTable, where: '_id = ?', whereArgs: [eventId]);
    return result.isNotEmpty;
  }

  /// Check if Attendance is Already Submitted
  Future<bool> isAttendanceSubmitted(String eventId, String date) async {
    Database db = await database;
    var result = await db.query(
      attendanceTable,
      where: '$columnEventId = ? AND $columnAttendanceDate = ?',
      whereArgs: [eventId, date],
    );
    return result.isNotEmpty;
  }

  /// Mark Attendance
  Future<void> markAttendance(String eventId, String studentId, String date, bool present) async {
    Database db = await database;
    await db.insert(
      attendanceTable,
      {
        columnEventId: eventId,
        columnStudentId: studentId,
        columnAttendanceDate: date,
        columnPresent: present ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get Attendance for an Event
  Future<List<Map<String, dynamic>>> getAttendance(String eventId, String date) async {
    Database db = await database;
    return await db.query(
      attendanceTable,
      where: '$columnEventId = ? AND $columnAttendanceDate = ?',
      whereArgs: [eventId, date],
    );
  }
}
