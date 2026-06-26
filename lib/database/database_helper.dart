import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../models/customer.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;
  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'uht_store.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productName TEXT,
        price REAL,
        quantity INTEGER,
        total REAL,
        customerName TEXT,
        customerPhone TEXT,
        date TEXT,
        status TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        buyPrice REAL,
        sellPrice REAL,
        stock INTEGER,
        imageUrl TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        notes TEXT,
        createdAt TEXT
      )
    ''');
  }

  // ─── SALES ───
  Future<int> addSale(Sale s) async {
    final db = await database;
    return await db.insert('sales', s.toMap()..remove('id'));
  }

  Future<List<Sale>> getSales({String? orderBy = 'DESC'}) async {
    final db = await database;
    final maps = await db.query('sales', orderBy: 'date $orderBy');
    return maps.map((m) => Sale.fromMap(m)).toList();
  }

  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query('sales',
        where: 'date >= ? AND date <= ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC');
    return maps.map((m) => Sale.fromMap(m)).toList();
  }

  Future<double> getTotalSales({DateTime? start, DateTime? end}) async {
    final db = await database;
    String? where;
    List? args;
    if (start != null && end != null) {
      where = 'date >= ? AND date <= ?';
      args = [start.toIso8601String(), end.toIso8601String()];
    }
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(total), 0) as total FROM sales${where != null ? " WHERE $where" : ""}',
        args);
    final v = result.first['total'];
    return (v is int) ? v.toDouble() : (v as double);
  }

  Future<int> getSalesCount({DateTime? start, DateTime? end}) async {
    final db = await database;
    String? where;
    List? args;
    if (start != null && end != null) {
      where = 'date >= ? AND date <= ?';
      args = [start.toIso8601String(), end.toIso8601String()];
    }
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM sales${where != null ? " WHERE $where" : ""}',
        args);
    return (result.first['cnt'] as int);
  }

  Future<void> deleteSale(int id) async {
    final db = await database;
    await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  // ─── PRODUCTS ───
  Future<int> addProduct(Product p) async {
    final db = await database;
    return await db.insert('products', p.toMap()..remove('id'));
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<void> updateStock(int id, int newStock) async {
    final db = await database;
    await db.update('products', {'stock': newStock},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ─── CUSTOMERS ───
  Future<int> addCustomer(Customer c) async {
    final db = await database;
    return await db.insert('customers', c.toMap()..remove('id'));
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final maps = await db.query('customers', orderBy: 'createdAt DESC');
    return maps.map((m) => Customer.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getCustomerWithTotalSpent() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.id, c.name, c.phone, c.notes, c.createdAt,
             COALESCE(SUM(s.total), 0) as totalSpent,
             COUNT(s.id) as orderCount
      FROM customers c
      LEFT JOIN sales s ON c.name = s.customerName
      GROUP BY c.id
      ORDER BY totalSpent DESC
    ''');
  }

  Future<void> deleteCustomer(int id) async {
    final db = await database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // ─── DAILY STATS FOR CHARTS ───
  Future<List<Map<String, dynamic>>> getDailySales(int days) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT DATE(date) as day, COALESCE(SUM(total), 0) as total
      FROM sales
      WHERE date >= DATE('now', '-${days} days')
      GROUP BY DATE(date)
      ORDER BY day ASC
    ''');
  }
}
