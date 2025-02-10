import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DoctorDatabaseHelper {
  static final String databaseName = "doctor_database.db";
  static final int databaseVersion = 1;
  static final String table = 'doctors';
  static final String columnId = 'id';
  static final String columnName = 'name';
  static final String columnPhone = 'phone';
  static final String columnSpecialization = 'specialization';
  static final String columnArea = 'area';
  static final String columnHospital = 'hospital';
  static final String columnFees = 'fees';
  static final String columnPhoto = 'photo';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnPhone TEXT NOT NULL,
        $columnSpecialization TEXT NOT NULL,
        $columnArea TEXT NOT NULL,
        $columnHospital TEXT NOT NULL,
        $columnFees REAL NOT NULL,
        $columnPhoto BLOB
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add upgrade logic if needed in the future
  }

  Future<int> insertDoctor(Map<String, dynamic> doctor) async {
    final db = await database;
    return await db.insert(table, doctor);
  }

  Future<int> updateDoctor(int id, Map<String, dynamic> doctor) async {
    final db = await database;
    return await db.update(
      table,
      doctor,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteDoctor(int doctorId) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [doctorId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final db = await database;
    return await db.query(table);
  }

  Future<Map<String, dynamic>?> getDoctorById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }
}