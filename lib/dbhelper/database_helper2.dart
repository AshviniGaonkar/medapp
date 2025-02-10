import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper2 {
  static const _databaseName = "attendance.db";
  static const _databaseVersion = 1;

  static const studentTable = 'students';
  static const attendanceTable = 'attendance';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnPresent = 'present';
  static const columnEventId = 'eventId';
  static const columnEventDate = 'eventDate';
  static const columnIsSynced = 'isSynced';
  static const columnIsSubmitted = 'isSubmitted'; // New column for submission status

  // Singleton pattern
  DatabaseHelper2._privateConstructor();
  static final DatabaseHelper2 instance = DatabaseHelper2._privateConstructor();
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
    // Create student table
    await db.execute('''  
      CREATE TABLE $studentTable (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL
      )
    ''');

    // Create attendance table with eventDate and isSubmitted
    await db.execute('''  
      CREATE TABLE $attendanceTable (
        $columnId TEXT PRIMARY KEY,
        $columnEventId TEXT NOT NULL,
        $columnEventDate TEXT NOT NULL,
        $columnPresent INTEGER NOT NULL,
        $columnIsSynced INTEGER NOT NULL,
        $columnIsSubmitted INTEGER NOT NULL DEFAULT 0  // Default to 0 (not submitted)
      )
    ''');
  }

  // Insert student into the student table
  Future<void> insertStudent(Map<String, dynamic> student) async {
    Database db = await database;
    await db.insert(studentTable, student, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<Map<String, dynamic>>> getStudentsForEvent(String eventId) async {
  Database db = await database;
  return await db.rawQuery('''
    SELECT s.id, s.name
    FROM students s
    LEFT JOIN attendance a ON s.id = a.id AND a.eventId = ?
  ''', [eventId]);
}




  // Insert attendance into the attendance table
  Future<void> insertAttendance(Map<String, dynamic> attendance) async {
    Database db = await database;
    await db.insert(
      attendanceTable,
      {
        ...attendance,
        columnIsSubmitted: attendance[columnIsSubmitted] ?? 0, // Default to 0 if not provided
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get students from the database
  Future<List<Map<String, dynamic>>> getStudents() async {
    Database db = await database;
    return await db.query(studentTable);
  }

  // Get attendance data for a specific eventId and eventDate
  Future<List<Map<String, dynamic>>> getAttendance(String eventId, String eventDate) async {
    Database db = await database;
    return await db.query(
      attendanceTable,
      where: "$columnEventId = ? AND $columnEventDate = ?",
      whereArgs: [eventId, eventDate],
    );
  }

  // Update attendance for a student
  Future<void> updateAttendance(Map<String, dynamic> attendance) async {
    Database db = await database;
    await db.update(
      attendanceTable,
      attendance,
      where: "$columnId = ?",
      whereArgs: [attendance[columnId]],
    );
  }

  // Check if attendance has already been submitted for a specific event
  Future<bool> isAttendanceSubmitted(String eventId, String eventDate) async {
    Database db = await database;
    final result = await db.query(
      attendanceTable,
      where: "$columnEventId = ? AND $columnEventDate = ? AND $columnIsSubmitted = 1",
      whereArgs: [eventId, eventDate],
    );
    return result.isNotEmpty; // Returns true if attendance is already submitted
  }

  // Mark attendance as submitted for a specific event
  Future<void> markAttendanceAsSubmitted(String eventId, String eventDate) async {
    Database db = await database;
    await db.update(
      attendanceTable,
      {columnIsSubmitted: 1},
      where: "$columnEventId = ? AND $columnEventDate = ?",
      whereArgs: [eventId, eventDate],
    );
  }
}

