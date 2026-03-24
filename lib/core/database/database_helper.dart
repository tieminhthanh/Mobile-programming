// =============================================================
// database_helper.dart
// SQLite Database Manager cho PRM393
// Đã cập nhật để dùng object Migrations thay vì static
// =============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'migrations.dart';

// =============================================================
// DATABASE CONFIG
// =============================================================

class DatabaseConfig {
  final String name;
  final int version;

  const DatabaseConfig({required this.name, required this.version});
}

const databaseConfig = DatabaseConfig(name: 'prm393.db', version: 2);

// =============================================================
// DATABASE PROVIDER
// =============================================================

class DatabaseProvider {
  DatabaseProvider({required this.config});

  final DatabaseConfig config;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, config.name);

    // Khởi tạo instance của Migrations
    const migrations = Migrations();

    return openDatabase(
      path,
      version: config.version,
      onCreate: migrations.onCreate,
      onUpgrade: migrations.onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
        await db.execute("PRAGMA encoding = 'UTF-8';");
      },
    );
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> reset() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, config.name);

    await close();
    await deleteDatabase(path);

    _database = await _open();
  }
}

// =============================================================
// DATABASE SERVICE
// Generic CRUD helper
// =============================================================

class DatabaseService {
  DatabaseService(this.provider);

  final DatabaseProvider provider;

  /// Insert một record vào table
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await provider.database;

    return db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Query dữ liệu từ table với các điều kiện
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool distinct = false,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await provider.database;

    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Query một record theo ID
  Future<Map<String, dynamic>?> queryById(
    String table,
    String idColumn,
    int id,
  ) async {
    final result = await query(
      table,
      where: '$idColumn = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Update record trong table
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await provider.database;

    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  /// Delete record khỏi table
  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await provider.database;

    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Đếm số lượng record
  Future<int> count(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await provider.database;

    final sql = 'SELECT COUNT(*) as cnt FROM $table'
        '${where != null ? ' WHERE $where' : ''}';

    final result = await db.rawQuery(sql, whereArgs ?? []);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await provider.database;
    return db.rawQuery(sql, args);
  }

  /// Execute raw SQL command
  Future<void> rawExecute(String sql, [List<dynamic>? args]) async {
    final db = await provider.database;
    await db.execute(sql, args);
  }

  /// Insert nhiều record trong một batch
  Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;

    final db = await provider.database;
    final batch = db.batch();

    for (final row in rows) {
      batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  /// Delete nhiều record trong một batch
  Future<void> batchDelete(
    String table, {
    required List<int> ids,
    required String idColumn,
  }) async {
    if (ids.isEmpty) return;

    final db = await provider.database;
    final batch = db.batch();

    for (final id in ids) {
      batch.delete(
        table,
        where: '$idColumn = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }
}

// =============================================================
// DOMAIN QUERIES (Repository style)
// =============================================================

class DomainQueries {
  DomainQueries(this.db);

  final DatabaseService db;

  /// Lấy danh sách sản phẩm với thông tin người bán và ảnh chính
  Future<List<Map<String, dynamic>>> getProductsWithSeller() {
    return db.rawQuery('''
      SELECT
        p.ProductId,
        p.SellerId,
        p.Title,
        p.Price,
        p.Unit,
        p.Category,
        p.CreatedAt,
        u.DisplayName AS SellerName,
        i.ImageUrl AS ImageUrl
      FROM commerce_Products p
      JOIN Users u ON p.SellerId = u.UserId
      LEFT JOIN Images i ON i.ReferenceId = p.ProductId
        AND i.ReferenceType = 'PRODUCT' AND i.IsPrimary = 1
      ORDER BY p.CreatedAt DESC
    ''');
  }

  /// Lấy chi tiết sản phẩm theo ID
  Future<Map<String, dynamic>?> getProductDetail(int productId) {
    return db.rawQuery(
      '''
      SELECT
        p.ProductId,
        p.SellerId,
        p.Title,
        p.Price,
        p.Unit,
        p.Category,
        p.Description,
        p.CreatedAt,
        u.DisplayName AS SellerName,
        u.Email AS SellerEmail
      FROM commerce_Products p
      JOIN Users u ON p.SellerId = u.UserId
      WHERE p.ProductId = ?
    ''',
      [productId],
    ).then((result) => result.isNotEmpty ? result.first : null);
  }

  /// Lấy tất cả ảnh của sản phẩm
  Future<List<Map<String, dynamic>>> getProductImages(int productId) {
    return db.rawQuery(
      '''
      SELECT ImageId, ImageUrl, IsPrimary, DisplayOrder
      FROM Images
      WHERE ReferenceId = ? AND ReferenceType = 'PRODUCT'
      ORDER BY IsPrimary DESC, DisplayOrder ASC
    ''',
      [productId],
    );
  }

  /// Lấy danh sách trang trại theo nông dân
  Future<List<Map<String, dynamic>>> getFarmsByFarmer(int farmerId) {
    return db.rawQuery(
      '''
      SELECT f.*, i.ImageUrl AS FarmImageUrl
      FROM iot_Farms f
      LEFT JOIN Images i ON i.ReferenceId = f.FarmId
        AND i.ReferenceType = 'FARM' AND i.IsPrimary = 1
      WHERE f.FarmerId = ?
    ''',
      [farmerId],
    );
  }

  /// Lấy danh sách thiết bị IoT với dữ liệu cảm biến mới nhất
  Future<List<Map<String, dynamic>>> getDevicesWithLatestReading(int farmId) {
    return db.rawQuery(
      '''
      SELECT d.*, r.MetricType, r.MetricValue, r.RecordedAt
      FROM iot_IoTDevices d
      LEFT JOIN iot_IoTSensorReadings r ON r.DeviceId = d.DeviceId
        AND r.ReadingId = (
          SELECT MAX(ReadingId) 
          FROM iot_IoTSensorReadings
          WHERE DeviceId = d.DeviceId
        )
      WHERE d.FarmId = ?
    ''',
      [farmId],
    );
  }

  /// Lấy danh sách đơn hàng theo người mua
  Future<List<Map<String, dynamic>>> getOrdersByBuyer(int buyerId) {
    return db.rawQuery(
      '''
      SELECT o.*, oi.ProductId, oi.Quantity, oi.Price,
             p.Title AS ProductTitle
      FROM commerce_Orders o
      JOIN commerce_OrderItems oi ON oi.OrderId = o.OrderId
      JOIN commerce_Products p ON p.ProductId = oi.ProductId
      WHERE o.BuyerId = ?
      ORDER BY o.CreatedAt DESC
    ''',
      [buyerId],
    );
  }

  /// Lấy danh sách thông báo chưa đọc
  Future<List<Map<String, dynamic>>> getUnreadNotifications(int userId) {
    return db.query(
      'Notifications',
      where: 'UserId = ? AND IsRead = 0',
      whereArgs: [userId],
      orderBy: 'CreatedAt DESC',
    );
  }

  /// Lấy danh sách đặt máy theo trang trại
  Future<List<Map<String, dynamic>>> getBookingsByFarm(int farmId) {
    return db.rawQuery(
      '''
      SELECT b.*, m.MachineType, m.BasePricePerHour,
             u.DisplayName AS BookerName
      FROM logistics_MachineBookings b
      JOIN logistics_AgriMachines m ON m.MachineId = b.MachineId
      JOIN Users u ON u.UserId = b.BookerId
      WHERE b.FarmId = ?
      ORDER BY b.StartTime DESC
    ''',
      [farmId],
    );
  }

  /// Lấy ảnh chính của một tài nguyên
  Future<String?> getPrimaryImage(String referenceType, int referenceId) async {
    final result = await db.query(
      'Images',
      columns: ['ImageUrl'],
      where: 'ReferenceType = ? AND ReferenceId = ? AND IsPrimary = 1',
      whereArgs: [referenceType, referenceId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return result.first['ImageUrl'] as String?;
  }
}
