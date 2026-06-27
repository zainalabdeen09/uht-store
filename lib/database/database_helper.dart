import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/section.dart';
import '../models/cart_item.dart';

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
    final path = join(await getDatabasesPath(), 'uhtred_store.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        email TEXT DEFAULT '',
        phone TEXT DEFAULT '',
        gender TEXT DEFAULT '',
        address TEXT DEFAULT '',
        avatarPath TEXT DEFAULT '',
        createdAt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE sections (
        id INTEGER PRIMARY KEY,
        name TEXT,
        note TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT,
        colors TEXT,
        prices TEXT,
        sectionId INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderNumber TEXT,
        userId INTEGER,
        name TEXT,
        phone TEXT,
        address TEXT,
        items TEXT,
        total REAL,
        status TEXT DEFAULT 'pending',
        createdAt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER DEFAULT 0,
        productKey TEXT,
        productName TEXT,
        printing TEXT,
        price REAL,
        color TEXT,
        size TEXT DEFAULT 'L',
        quantity INTEGER DEFAULT 1
      )
    ''');
    await _seedData(db);
  }

  Future _seedData(Database db) async {
    await db.insert('users', {
      'username': 'za_c10',
      'password': 'za_c10',
      'email': '',
      'phone': '',
      'gender': '',
      'address': '',
      'avatarPath': '',
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.insert('sections', {'id': 1, 'name': 'تيشيرتات', 'note': ''});
    await db.insert('sections', {'id': 3, 'name': 'تيشيرتات GYM', 'note': ''});
    await db.insert('sections', {'id': 4, 'name': 'سيتات GYM رياضية', 'note': ''});
    await db.insert('sections', {'id': 5, 'name': 'بجامة', 'note': ''});
    await db.insert('sections', {'id': 6, 'name': 'تيشيرت البولو', 'note': ''});
    await db.insert('sections', {'id': 7, 'name': 'تيشيرت مكحوت', 'note': ''});

    final products = [
      {'id': 'p1', 'name': 'تيربو - قالب هاف', 'colors': 'اسود,ابيض', 'prices': 'سادة بدون طباعة:20000||طباعة جهة واحدة (حجم متوسط او كبير):25000||طباعة جهتين (وسط + كبير):27000||طباعة جهتين (الجهتين حجم كبير):30000', 'sectionId': 1},
      {'id': 'p2', 'name': 'قطني - قالب هاف', 'colors': 'اسود,ابيض', 'prices': 'سادة بدون طباعة:20000||طباعة جهة واحدة (حجم متوسط او كبير):23000||طباعة جهتين (وسط + كبير):25000||طباعة جهتين (الجهتين حجم كبير):28000', 'sectionId': 1},
      {'id': 'p3', 'name': 'قطني درجة اولى - قالب عادي', 'colors': 'اسود,ابيض', 'prices': 'سادة بدون طباعة:19000||طباعة جهة واحدة (حجم متوسط او كبير):22000||طباعة جهتين (وسط + كبير):24000||طباعة جهتين (الجهتين حجم كبير):26000', 'sectionId': 1},
      {'id': 'p4', 'name': 'قطني + ليگرا - مطاطية', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:15000||طباعة جهة واحدة (حجم متوسط او كبير):18000||طباعة جهتين (وسط + كبير):20000||طباعة جهتين (الجهتين حجم كبير):22000', 'sectionId': 1},
      {'id': 'p5', 'name': 'تيشيرت جم رياضي ردان', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:20000||طباعة جهة واحدة (حجم متوسط او كبير):24000||طباعة جهتين (وسط + كبير):26000||طباعة جهتين (الجهتين حجم كبير):28000', 'sectionId': 3},
      {'id': 'p6', 'name': 'تيشيرت جم رياضي (خامة فلتر)', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:19000||طباعة جهة واحدة (حجم متوسط او كبير):23000||طباعة جهتين (وسط + كبير):25000', 'sectionId': 3},
      {'id': 'p7', 'name': 'تيشيرت جم رياضي كومبدشن - نص ردان', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:21000||طباعة جهة واحدة (حجم متوسط او كبير):24000||طباعة جهتين (وسط + كبير):25000||طباعة جهتين (الجهتين حجم كبير):27000', 'sectionId': 3},
      {'id': 'p8', 'name': 'تيشيرت جم شارك رياضي - نص ردان', 'colors': 'اسود,رصاصي', 'prices': 'سعر القطعة:35000', 'sectionId': 3},
      {'id': 'p9', 'name': 'تيشيرت كيمونه جم شارك', 'colors': 'اسود', 'prices': 'سعر القطعة:35000', 'sectionId': 3},
      {'id': 'p10', 'name': 'سيت جم رياضي (شورت + تيشيرت ردان)', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:30000||طباعة جهة واحدة (حجم متوسط او كبير):35000||طباعة جهتين (وسط + كبير):37000', 'sectionId': 4},
      {'id': 'p11', 'name': 'سيت جم (قالب باندا + شورت مبطن)', 'colors': 'اسود,ابيض', 'prices': 'سادة بدون طباعة:27000||طباعة جهة واحدة (حجم متوسط او كبير):32000||طباعة جهتين (وسط + كبير):35000', 'sectionId': 4},
      {'id': 'p12', 'name': 'سيت جم وتر بروف الكامل', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:22000||طباعة جهة واحدة (حجم متوسط او كبير):25000||طباعة جهتين (وسط + كبير):35000', 'sectionId': 4},
      {'id': 'p13', 'name': 'سيت جم فلتر + شورت وتر بروف', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:20000||طباعة جهة واحدة (حجم متوسط او كبير):25000||طباعة جهتين (وسط + كبير):27000', 'sectionId': 4},
      {'id': 'p14', 'name': 'سيت جم (تيشيرت جم شارك + شورت)', 'colors': 'اسود', 'prices': 'سعر السيت:40000', 'sectionId': 4},
      {'id': 'p15', 'name': 'بجامه جوغر كلاسك (شريط مطاطي)', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:23000||طباعة جهة واحدة (حجم متوسط او كبير):25000||طباعة جهتين (وسط + كبير):27000||طباعة جهتين (الجهتين حجم كبير):30000||طباعة ثلاث جهات:33000', 'sectionId': 5},
      {'id': 'p16', 'name': 'بجامه جوغر بريميوم (حلقة)', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:23000||طباعة جهة واحدة (حجم متوسط او كبير):25000||طباعة جهتين (وسط + كبير):27000||طباعة جهتين (الجهتين حجم كبير):30000||طباعة ثلاث جهات:33000', 'sectionId': 5},
      {'id': 'p17', 'name': 'سيت بجامه + تيشيرت تيربو', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:38000||طباعة جهة واحدة (حجم متوسط او كبير):40000||طباعة جهتين (وسط + كبير):45000||طباعة جهتين (الجهتين حجم كبير):50000', 'sectionId': 5},
      {'id': 'p18', 'name': 'تيشيرت بولو اسود', 'colors': 'اسود', 'prices': 'سادة بدون طباعة:18000||طباعة جهة واحدة (حجم متوسط او كبير):22000||طباعة جهتين (وسط + كبير):25000', 'sectionId': 6},
      {'id': 'p19', 'name': 'تيشيرت بولو ابيض', 'colors': 'ابيض', 'prices': 'سادة بدون طباعة:18000||طباعة جهة واحدة (حجم متوسط او كبير):22000||طباعة جهتين (وسط + كبير):25000', 'sectionId': 6},
      {'id': 'p20', 'name': 'تيشيرت مغسول رصاصي', 'colors': 'رصاصي', 'prices': 'سادة بدون طباعة:19000||طباعة جهة واحدة (حجم متوسط او كبير):24000||طباعة جهتين (وسط + كبير):25000||طباعة جهتين (الجهتين حجم كبير):27000', 'sectionId': 7},
      {'id': 'p21', 'name': 'تيشيرت مكحوت رصاصي', 'colors': 'رصاصي', 'prices': 'سادة بدون طباعة:19000||طباعة جهة واحدة (حجم متوسط او كبير):23000||طباعة جهتين (وسط + كبير):25000', 'sectionId': 7},
      {'id': 'p22', 'name': 'تيشيرت مكحوت سلفر', 'colors': 'سلفر', 'prices': 'سادة بدون طباعة:19000||طباعة جهة واحدة (حجم متوسط او كبير):23000||طباعة جهتين (الجهتين حجم كبير):27000', 'sectionId': 7},
      {'id': 'p23', 'name': 'تيشيرت مكحوت ازرق فاتح', 'colors': 'ازرق فاتح', 'prices': 'سادة بدون طباعة:19000||طباعة جهة واحدة (حجم متوسط او كبير):24000||طباعة جهتين (الجهتين حجم كبير):27000', 'sectionId': 7},
      {'id': 'p24', 'name': 'تيشيرت مكحوت زيتوني فاتح', 'colors': 'زيتوني فاتح', 'prices': 'سادة بدون طباعة:19000||طباعة جهة واحدة (حجم متوسط او كبير):24000||طباعة جهتين (الجهتين حجم كبير):27000', 'sectionId': 7},
      {'id': 'p25', 'name': 'سيت (بجامه باكي + تيشيرت مكحوت رصاصي)', 'colors': 'رصاصي', 'prices': 'سيت سادة:37000||طباعة جهة واحدة (تيشيرت كبير - بجامه صغير):40000||طباعة جهة واحدة (تيشيرت كبير - بجامه كبير):45000', 'sectionId': 7},
      {'id': 'p26', 'name': 'سيت مكحوت (تيشيرت + شورت)', 'colors': 'اسود', 'prices': 'سيت سادة:37000||طباعة جهة واحدة (تيشيرت كبير - شورت صغير):43000', 'sectionId': 7},
    ];

    for (final p in products) {
      await db.insert('products', p);
    }
  }

  // ─── USERS ───
  Future<int> registerUser(AppUser user) async {
    final db = await database;
    return await db.insert('users', user.toMap()..remove('id'));
  }

  Future<AppUser?> login(String username, String password) async {
    final db = await database;
    final maps = await db.query('users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password]);
    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  Future<AppUser?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query('users',
        where: 'username = ?', whereArgs: [username]);
    if (maps.isEmpty) return null;
    return AppUser.fromMap(maps.first);
  }

  Future<int> updateUser(AppUser user) async {
    final db = await database;
    return await db.update('users', user.toMap()..remove('id')..remove('createdAt'),
        where: 'id = ?', whereArgs: [user.id]);
  }

  // ─── SECTIONS ───
  Future<List<Section>> getSections() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT s.*, (SELECT COUNT(*) FROM products WHERE sectionId = s.id) as productCount
      FROM sections s ORDER BY s.id ASC
    ''');
    return maps.map((m) => Section(
      id: m['id'] as int,
      name: m['name'] as String,
      note: (m['note'] as String?) ?? '',
      productCount: (m['productCount'] as int?) ?? 0,
    )).toList();
  }

  // ─── PRODUCTS ───
  Future<List<Product>> getProducts({int? sectionId}) async {
    final db = await database;
    final where = sectionId != null ? 'WHERE sectionId = ?' : '';
    final args = sectionId != null ? [sectionId] : [];
    final maps = await db.rawQuery('SELECT * FROM products $where ORDER BY id ASC', args);
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProduct(String id) async {
    final db = await database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  // ─── CART ───
  Future<List<CartItem>> getCartItems({int userId = 0}) async {
    final db = await database;
    final maps = await db.query('cart_items',
        where: 'userId = ?', whereArgs: [userId]);
    return maps.map((m) => CartItem.fromMap(m)).toList();
  }

  Future<void> addToCart(CartItem item, {int userId = 0}) async {
    final db = await database;
    final existing = await db.query('cart_items',
        where: 'userId = ? AND productKey = ? AND printing = ? AND color = ? AND size = ?',
        whereArgs: [userId, item.productKey, item.printing, item.color, item.size]);
    if (existing.isNotEmpty) {
      final currentQty = existing.first['quantity'] as int;
      await db.update('cart_items', {'quantity': currentQty + item.quantity},
          where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      final map = item.toMap();
      map['userId'] = userId;
      await db.insert('cart_items', map);
    }
  }

  Future<void> updateCartItemQty(int id, int qty) async {
    final db = await database;
    await db.update('cart_items', {'quantity': qty},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeCartItem(int id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart({int userId = 0}) async {
    final db = await database;
    await db.delete('cart_items', where: 'userId = ?', whereArgs: [userId]);
  }

  // ─── ORDERS ───
  Future<int> createOrder(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('orders', data);
  }

  Future<List<Map<String, dynamic>>> getOrdersByUser(int userId) async {
    final db = await database;
    return await db.query('orders',
        where: 'userId = ?', whereArgs: [userId],
        orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;
    return await db.query('orders', orderBy: 'createdAt DESC');
  }

  Future<void> updateOrderStatus(int id, String status) async {
    final db = await database;
    await db.update('orders', {'status': status},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getOrderStats() async {
    final db = await database;
    final totalOrders = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM orders')) ?? 0;
    final revVal = (await db.rawQuery('SELECT COALESCE(SUM(total), 0) as t FROM orders')).first['t'];
    final totalRevenue = (revVal is int) ? revVal.toDouble() : revVal;
    final pendingOrders = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM orders WHERE status = 'pending'")) ?? 0;
    final productCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue is int ? totalRevenue.toDouble() : totalRevenue,
      'pendingOrders': pendingOrders,
      'productCount': productCount,
    };
  }
}
