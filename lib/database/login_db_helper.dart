import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  Future<bool> checkEmailExists(String email) async {
    final db = await database;
    var result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty;
  }

  Future<int> insertUser(String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'email': email,
      'password': password
    });
  }

  Future<Map<String, dynamic>?> getUserByCredentials(String email, String password) async {
    final db = await database;
    var result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password]
    );
    return result.isNotEmpty ? result.first : null;
  }
}