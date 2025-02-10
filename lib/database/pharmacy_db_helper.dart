import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';

class PharmacyDatabaseHelper {
  static final String databaseName = "pharmacy_database.db";
  static final int databaseVersion = 2; // Increased version for new tables

  // Medicines Table
  static final String medicinesTable = 'medicines';
  static final String columnId = 'id';
  static final String columnName = 'name';
  static final String columnDescription = 'description';
  static final String columnPrice = 'price';
  static final String columnQuantity = 'quantity';
  static final String columnImage = 'image';

  // Orders Table
  static final String ordersTable = 'orders';
  static final String orderColumnId = 'id';
  static final String orderColumnTotalAmount = 'total_amount';
  static final String orderColumnDate = 'order_date';

  // Order Items Table
  static final String orderItemsTable = 'order_items';
  static final String orderItemColumnId = 'id';
  static final String orderItemColumnOrderId = 'order_id';
  static final String orderItemColumnMedicineId = 'medicine_id';
  static final String orderItemColumnQuantity = 'quantity';
  static final String orderItemColumnPrice = 'price';

  Database? database;

  Future<Database> get getDatabase async {
    if (database != null) return database!;
    database = await initDatabase();
    return database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  Future onCreate(Database db, int version) async {
    // Medicines Table
    await db.execute('''
      CREATE TABLE $medicinesTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnPrice REAL NOT NULL,
        $columnQuantity INTEGER NOT NULL,
        $columnImage BLOB
      )
    ''');

    // Orders Table
    await db.execute('''
      CREATE TABLE $ordersTable (
        $orderColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $orderColumnTotalAmount REAL NOT NULL,
        $orderColumnDate TEXT NOT NULL
      )
    ''');

    // Order Items Table
    await db.execute('''
      CREATE TABLE $orderItemsTable (
        $orderItemColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $orderItemColumnOrderId INTEGER,
        $orderItemColumnMedicineId INTEGER,
        $orderItemColumnQuantity INTEGER NOT NULL,
        $orderItemColumnPrice REAL NOT NULL,
        FOREIGN KEY ($orderItemColumnOrderId) REFERENCES $ordersTable ($orderColumnId),
        FOREIGN KEY ($orderItemColumnMedicineId) REFERENCES $medicinesTable ($columnId)
      )
    ''');
  }

  Future onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for orders
      await db.execute('''
        CREATE TABLE $ordersTable (
          $orderColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $orderColumnTotalAmount REAL NOT NULL,
          $orderColumnDate TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE $orderItemsTable (
          $orderItemColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $orderItemColumnOrderId INTEGER,
          $orderItemColumnMedicineId INTEGER,
          $orderItemColumnQuantity INTEGER NOT NULL,
          $orderItemColumnPrice REAL NOT NULL,
          FOREIGN KEY ($orderItemColumnOrderId) REFERENCES $ordersTable ($orderColumnId),
          FOREIGN KEY ($orderItemColumnMedicineId) REFERENCES $medicinesTable ($columnId)
        )
      ''');
    }
  }

  // Existing Medicine Methods
  Future<int> insertMedicine(Map<String, dynamic> medicine) async {
    final db = await getDatabase;
    return await db.insert(medicinesTable, medicine);
  }

  Future<List<Map<String, dynamic>>> getAllMedicines() async {
    final db = await getDatabase;
    return await db.query(medicinesTable);
  }

  Future<Map<String, dynamic>?> getMedicineById(int id) async {
    final db = await getDatabase;
    List<Map<String, dynamic>> results = await db.query(
      medicinesTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateMedicine(int id, Map<String, dynamic> medicine) async {
    final db = await getDatabase;
    return await db.update(
        medicinesTable,
        medicine,
        where: '$columnId = ?',
        whereArgs: [id]
    );
  }

  Future<int> deleteMedicine(int id) async {
    final db = await getDatabase;
    return await db.delete(medicinesTable, where: '$columnId = ?', whereArgs: [id]);
  }

  // New Order Methods
  Future<int> createOrder(double totalAmount) async {
    final db = await getDatabase;
    return await db.insert(ordersTable, {
      orderColumnTotalAmount: totalAmount,
      orderColumnDate: DateTime.now().toIso8601String(),
    });
  }

  Future<void> addOrderItems(int orderId, List<Map<String, dynamic>> items) async {
    final db = await getDatabase;
    for (var item in items) {
      await db.insert(orderItemsTable, {
        orderItemColumnOrderId: orderId,
        orderItemColumnMedicineId: item['medicine_id'],
        orderItemColumnQuantity: item['quantity'],
        orderItemColumnPrice: item['price'],
      });

      // Decrement medicine quantity
      await decrementMedicineQuantity(item['medicine_id'], item['quantity']);
    }
  }

  Future<int> decrementMedicineQuantity(int id, int quantity) async {
    final db = await getDatabase;
    final medicine = await getMedicineById(id);

    if (medicine != null) {
      int currentQuantity = medicine[columnQuantity];
      if (currentQuantity >= quantity) {
        return await db.update(
            medicinesTable,
            {columnQuantity: currentQuantity - quantity},
            where: '$columnId = ?',
            whereArgs: [id]
        );
      }
    }
    return 0;
  }

  // Fetch Order History
  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    final db = await getDatabase;
    return await db.query(ordersTable, orderBy: '$orderColumnDate DESC');
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    final db = await getDatabase;
    return await db.query(
      orderItemsTable,
      where: '$orderItemColumnOrderId = ?',
      whereArgs: [orderId],
    );
  }
}