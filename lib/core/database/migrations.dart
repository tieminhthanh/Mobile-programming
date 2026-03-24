// =============================================================
// migrations.dart
// Tạo bảng (DDL) + Seed data khớp 100% với SQL gốc PRM393
// Thiết kế theo hướng đối tượng, không lạm dụng static
// =============================================================

import 'package:sqflite/sqflite.dart';

class Migrations {
  const Migrations();

  // -------------------------------------------------------
  // onCreate – chạy lần đầu khi database chưa tồn tại
  // -------------------------------------------------------
  Future<void> onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedData(db);
  }

  // -------------------------------------------------------
  // onUpgrade – tăng version khi thay đổi schema
  // -------------------------------------------------------
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // SME extra fields for profile
      try {
        await db.execute('ALTER TABLE SMEProfiles ADD COLUMN Description TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE SMEProfiles ADD COLUMN LogoUrl TEXT');
      } catch (_) {}

      // Admin control flags
      try {
        await db.execute('ALTER TABLE iot_Farms ADD COLUMN IsVerified INTEGER DEFAULT 0');
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE logistics_AgriMachines ADD COLUMN IsApproved INTEGER DEFAULT 0',
        );
      } catch (_) {}
    }
  }

  // =======================================================
  // PHẦN I – TẠO BẢNG
  // =======================================================
  Future<void> _createTables(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Users (
        UserId      INTEGER PRIMARY KEY AUTOINCREMENT,
        PhoneNumber  TEXT    UNIQUE NOT NULL,
        Email        TEXT    UNIQUE,
        PasswordHash BLOB    NOT NULL,
        RoleType     TEXT    NOT NULL CHECK (RoleType IN ('FARMER','SME','ADMIN')),
        DisplayName  TEXT,
        IsActive     INTEGER NOT NULL DEFAULT 1,
        CreatedAt    TEXT    DEFAULT (datetime('now','localtime'))
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS AdminProfiles (
        AdminId   INTEGER PRIMARY KEY,
        FullName  TEXT NOT NULL,
        Position  TEXT,
        CreatedAt TEXT DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (AdminId) REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS core_UserAddresses (
        AddressId   INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId      INTEGER NOT NULL,
        Province    TEXT,
        District    TEXT,
        Commune     TEXT,
        AddressLine TEXT,
        CreatedAt   TEXT DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS FarmerProfiles (
        UserId         INTEGER PRIMARY KEY,
        FullName       TEXT    NOT NULL,
        Village        TEXT,
        ContactName    TEXT,
        ContactPhone   TEXT,
        PreferredVoice INTEGER DEFAULT 1,
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS SMEProfiles (
        UserId         INTEGER PRIMARY KEY,
        CompanyName    TEXT UNIQUE NOT NULL,
        TaxCode        TEXT UNIQUE NOT NULL,
        ContactName    TEXT,
        ContactPhone   TEXT,
        AddressSummary TEXT,
        Description    TEXT,
        LogoUrl        TEXT,
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Images (
        ImageId       INTEGER PRIMARY KEY AUTOINCREMENT,
        ReferenceId   INTEGER NOT NULL,
        ReferenceType TEXT    CHECK (ReferenceType IN ('USER','PRODUCT','SME','FARM','CONSULTING','MACHINE')),
        ImageUrl      TEXT    NOT NULL,
        IsPrimary     INTEGER DEFAULT 0,
        DisplayOrder  INTEGER DEFAULT 0,
        UploadedAt    TEXT    DEFAULT (datetime('now','localtime'))
      );
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS IX_Images_Reference ON Images(ReferenceType, ReferenceId);');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS iot_Farms (
        FarmId         INTEGER PRIMARY KEY AUTOINCREMENT,
        FarmerId       INTEGER NOT NULL,
        FarmName       TEXT,
        Location       TEXT,
        AreaHectares   REAL    NOT NULL,
        CropType       TEXT,
        IsVerified     INTEGER DEFAULT 0,
        Certifications TEXT,
        FOREIGN KEY (FarmerId) REFERENCES FarmerProfiles(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS iot_IoTDevices (
        DeviceId     INTEGER PRIMARY KEY AUTOINCREMENT,
        FarmId       INTEGER NOT NULL,
        DeviceType   TEXT    CHECK (DeviceType IN ('SOIL','AIR','WATER','GATEWAY')),
        Description  TEXT,
        BatteryLevel INTEGER CHECK (BatteryLevel BETWEEN 0 AND 100),
        FOREIGN KEY (FarmId) REFERENCES iot_Farms(FarmId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS iot_IoTSensorReadings (
        ReadingId   INTEGER PRIMARY KEY AUTOINCREMENT,
        DeviceId    INTEGER NOT NULL,
        MetricType  TEXT    NOT NULL,
        MetricValue REAL    NOT NULL,
        RecordedAt  TEXT    DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (DeviceId) REFERENCES iot_IoTDevices(DeviceId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS iot_FarmingLogs (
        LogId        INTEGER PRIMARY KEY AUTOINCREMENT,
        FarmId       INTEGER NOT NULL,
        ActionType   TEXT    NOT NULL,
        MaterialUsed TEXT,
        Quantity     REAL,
        RecordedAt   TEXT    DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (FarmId) REFERENCES iot_Farms(FarmId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS logistics_AgriMachines (
        MachineId        INTEGER PRIMARY KEY AUTOINCREMENT,
        OwnerId          INTEGER NOT NULL,
        MachineType      TEXT    NOT NULL,
        Description      TEXT,
        BasePricePerHour REAL    NOT NULL,
        IsApproved       INTEGER DEFAULT 0,
        FOREIGN KEY (OwnerId) REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS logistics_MachineHailingRequests (
        RequestId           INTEGER PRIMARY KEY AUTOINCREMENT,
        FarmId              INTEGER NOT NULL,
        MachineTypeRequired TEXT    NOT NULL,
        ExpectedStartTime   TEXT    NOT NULL,
        Status              TEXT    DEFAULT 'MATCHING',
        FOREIGN KEY (FarmId) REFERENCES iot_Farms(FarmId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS logistics_MachineBookings (
        BookingId  INTEGER PRIMARY KEY AUTOINCREMENT,
        MachineId  INTEGER NOT NULL,
        FarmId     INTEGER NOT NULL,
        BookerId   INTEGER NOT NULL,
        StartTime  TEXT    NOT NULL,
        EndTime    TEXT,
        TotalPrice REAL,
        Status     TEXT    DEFAULT 'BOOKED',
        CreatedAt  TEXT    DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (MachineId) REFERENCES logistics_AgriMachines(MachineId),
        FOREIGN KEY (FarmId)    REFERENCES iot_Farms(FarmId),
        FOREIGN KEY (BookerId)  REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS commerce_Products (
        ProductId   INTEGER PRIMARY KEY AUTOINCREMENT,
        SellerId    INTEGER NOT NULL,
        Title       TEXT    NOT NULL,
        Description TEXT,
        Category    TEXT,
        Price       REAL    NOT NULL,
        Unit        TEXT,
        CreatedAt   TEXT    DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (SellerId) REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS commerce_ProductBatches (
        ProductBatchId INTEGER PRIMARY KEY AUTOINCREMENT,
        ProductId      INTEGER NOT NULL,
        BatchCode      TEXT    UNIQUE,
        ProductionDate TEXT,
        FOREIGN KEY (ProductId) REFERENCES commerce_Products(ProductId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS commerce_Carts (
        CartId    INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId    INTEGER NOT NULL,
        CreatedAt TEXT    DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS commerce_CartItems (
        CartItemId INTEGER PRIMARY KEY AUTOINCREMENT,
        CartId     INTEGER NOT NULL,
        ProductId  INTEGER NOT NULL,
        Quantity   REAL    NOT NULL,
        AddedAt    TEXT    DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (CartId)    REFERENCES commerce_Carts(CartId),
        FOREIGN KEY (ProductId) REFERENCES commerce_Products(ProductId),
        UNIQUE (CartId, ProductId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS commerce_Orders (
        OrderId    INTEGER PRIMARY KEY AUTOINCREMENT,
        BuyerId    INTEGER NOT NULL,
        OrderTotal REAL    NOT NULL,
        Status     TEXT    DEFAULT 'CREATED',
        CreatedAt  TEXT    DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (BuyerId) REFERENCES Users(UserId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS commerce_OrderItems (
        OrderItemId INTEGER PRIMARY KEY AUTOINCREMENT,
        OrderId     INTEGER NOT NULL,
        ProductId   INTEGER NOT NULL,
        Quantity    REAL    NOT NULL,
        Price       REAL    NOT NULL,
        FOREIGN KEY (OrderId)   REFERENCES commerce_Orders(OrderId),
        FOREIGN KEY (ProductId) REFERENCES commerce_Products(ProductId)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Notifications (
        NotificationId INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId    INTEGER NOT NULL,
        Title     TEXT,
        IsRead    INTEGER DEFAULT 0,
        CreatedAt TEXT    DEFAULT (datetime('now','localtime')),
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
      );
    ''');
  }

  // =======================================================
  // PHẦN II – SEED DATA (khớp 100% SQL gốc)
  // =======================================================
  Future<void> _seedData(Database db) async {
    // Dùng nhiều batch nhỏ để tránh lỗi transaction quá lớn
    await _seedUsers(db);
    await _seedProfiles(db);
    await _seedAddressesAndFarms(db);
    await _seedIoT(db);
    await _seedLogisticsAndCommerce(db);
    await _seedImages(db);
  }

  // -------------------------------------------------------
  // 1. USERS
  // -------------------------------------------------------
  Future<void> _seedUsers(Database db) async {
    final batch = db.batch();
    final pwHash = [65, 98, 99, 100, 49, 50, 51, 50, 64]; // 'Abcd1232@'

    final users = [
      ['0901000001', 'farmer1@agri.vn',  'FARMER', 'Nguyễn Văn Tèo'],
      ['0901000002', 'farmer2@agri.vn',  'FARMER', 'Trần Thị Thắm'],
      ['0901000003', 'farmer3@agri.vn',  'FARMER', 'Lê Văn Hùng'],
      ['0901000004', 'farmer4@agri.vn',  'FARMER', 'Phạm Thị Hoa'],
      ['0911000001', 'sme1@agri.vn',     'SME',    'HTX Nông Nghiệp Xanh'],
      ['0911000002', 'sme2@agri.vn',     'SME',    'Công Ty Cơ Khí Vina'],
      ['0911000003', 'sme3@agri.vn',     'SME',    'Phân Bón Miền Nam'],
      ['0911000004', 'sme4@agri.vn',     'SME',    'Logistics Nông Thôn'],
      ['0888000001', 'admin1@system.com','ADMIN',  'Admin Vận Hành'],
      ['0888000002', 'admin2@system.com','ADMIN',  'Admin Kỹ Thuật'],
    ];
    for (final u in users) {
      batch.insert('Users', {
        'PhoneNumber': u[0], 'Email': u[1],
        'PasswordHash': pwHash, 'RoleType': u[2], 'DisplayName': u[3],
      });
    }
    await batch.commit(noResult: true);
  }

  // -------------------------------------------------------
  // 2. FARMER / SME / ADMIN PROFILES
  // -------------------------------------------------------
  Future<void> _seedProfiles(Database db) async {
    final batch = db.batch();

    // FarmerProfiles
    final farmers = [
      [1, 'Nguyễn Văn Tèo', 'Thôn 1, Đắk Lắk',   '0901000001'],
      [2, 'Trần Thị Thắm',  'Xóm Chùa, Nam Định', '0901000002'],
      [3, 'Lê Văn Hùng',    'Ấp 3, Tiền Giang',   '0901000003'],
      [4, 'Phạm Thị Hoa',   'Bản Lác, Hòa Bình',  '0901000004'],
    ];
    for (final f in farmers) {
      batch.insert('FarmerProfiles', {
        'UserId': f[0], 'FullName': f[1], 'Village': f[2], 'ContactPhone': f[3],
      });
    }

    // SMEProfiles
    final smes = [
      [
        5,
        'HTX Nông Nghiệp Xanh',
        '0101010101',
        'Ông Bình',
        'Chuyên cung ứng nông sản sạch theo mùa vụ.',
        'https://picsum.photos/id/205/200/200',
      ],
      [
        6,
        'Công Ty Cơ Khí Vina',
        '0202020202',
        'Bà An',
        'Giải pháp cơ giới hóa nông nghiệp hiện đại.',
        'https://picsum.photos/id/206/200/200',
      ],
      [
        7,
        'Phân Bón Miền Nam',
        '0303030303',
        'Anh Dũng',
        'Vật tư đầu vào, phân bón chuyên dụng vùng miền.',
        'https://picsum.photos/id/207/200/200',
      ],
      [
        8,
        'Logistics Nông Thôn',
        '0404040404',
        'Anh Hoàng',
        'Vận tải nông sản và kho lạnh theo tuyến.',
        'https://picsum.photos/id/208/200/200',
      ],
    ];
    for (final s in smes) {
      batch.insert('SMEProfiles', {
        'UserId': s[0],
        'CompanyName': s[1],
        'TaxCode': s[2],
        'ContactName': s[3],
        'Description': s[4],
        'LogoUrl': s[5],
      });
    }

    // AdminProfiles
    batch.insert('AdminProfiles', {'AdminId': 9,  'FullName': 'Quản Trị Vận Hành', 'Position': 'Trưởng phòng Vận hành'});
    batch.insert('AdminProfiles', {'AdminId': 10, 'FullName': 'Quản Trị Kỹ Thuật', 'Position': 'Trưởng phòng IT'});

    await batch.commit(noResult: true);
  }

  // -------------------------------------------------------
  // 3. USER ADDRESSES + FARMS
  // -------------------------------------------------------
  Future<void> _seedAddressesAndFarms(Database db) async {
    final batch = db.batch();

    // core_UserAddresses
    final addresses = [
      [1,  'Đắk Lắk',      'Buôn Ma Thuột', 'Ea Tu',          '123 Đường Y Wang'],
      [2,  'Nam Định',      'Hải Hậu',       'Hải Lý',         'Khu 1 Nhà Thờ'],
      [3,  'Tiền Giang',    'Cái Bè',        'Đông Hòa Hiệp',  'Ấp An Lợi'],
      [4,  'Hòa Bình',      'Mai Châu',      'Chiềng Châu',    'Bản Lác'],
      [5,  'Hà Nội',        'Cầu Giấy',      'Dịch Vọng',      'Tòa nhà AgriTower'],
      [6,  'Hồ Chí Minh',   'Quận 1',        'Bến Nghé',       '68 Nguyễn Huệ'],
      [7,  'Đồng Nai',      'Biên Hòa',      'Tân Phong',      'KCN Amata'],
      [8,  'Cần Thơ',       'Ninh Kiều',     'An Phú',         '120 Lý Tự Trọng'],
      [9,  'Đà Nẵng',       'Hải Châu',      'Thạch Thang',    'Trung tâm Hành chính'],
      [10, 'Hà Nội',        'Ba Đình',       'Quán Thánh',     'Trụ sở Bộ'],
    ];
    for (final a in addresses) {
      batch.insert('core_UserAddresses', {
        'UserId': a[0], 'Province': a[1], 'District': a[2],
        'Commune': a[3], 'AddressLine': a[4],
      });
    }

    // iot_Farms
    final farms = [
      [1, 'Rẫy Cà Phê Tèo',       '12.6,108.0', 2.5, 'Cà Phê', 1],
      [1, 'Rẫy Tiêu Tèo',         '12.6,108.1', 1.0, 'Hồ Tiêu', 1],
      [2, 'Ruộng Lúa Thắm',       '20.4,106.2', 1.2, 'Lúa Nước', 1],
      [2, 'Vườn Rau Thắm',        '20.4,106.3', 0.5, 'Rau Sạch', 0],
      [3, 'Vườn Sầu Riêng Hùng',  '10.3,106.0', 3.0, 'Sầu Riêng', 1],
      [3, 'Vườn Chôm Chôm',       '10.3,106.1', 1.5, 'Chôm Chôm', 0],
      [4, 'Đồi Cam Hoa',          '20.9,105.1', 1.8, 'Cam Cao Phong', 1],
      [4, 'Vườn Mận Thung Lũng',  '20.9,105.2', 2.0, 'Mận Hậu', 0],
      [1, 'Trại Thủy Canh A',     '12.6,108.2', 0.2, 'Xà Lách', 1],
      [3, 'Vườn Bưởi Da Xanh',    '10.4,106.0', 1.0, 'Bưởi', 1],
    ];
    for (final f in farms) {
      batch.insert('iot_Farms', {
        'FarmerId': f[0], 'FarmName': f[1], 'Location': f[2],
        'AreaHectares': f[3], 'CropType': f[4], 'IsVerified': f[5],
      });
    }

    await batch.commit(noResult: true);
  }

  // -------------------------------------------------------
  // 4. IoT DEVICES + SENSOR READINGS + FARMING LOGS
  // -------------------------------------------------------
  Future<void> _seedIoT(Database db) async {
    final batch = db.batch();

    // iot_IoTDevices
    final devices = [
      [1,  'SOIL',    'Cảm biến độ ẩm đất khu cà phê',      85],
      [2,  'AIR',     'Trạm thời tiết vườn tiêu',            90],
      [3,  'WATER',   'Cảm biến mực nước ruộng lúa',         75],
      [4,  'SOIL',    'Cảm biến dinh dưỡng đất vườn rau',    60],
      [5,  'GATEWAY', 'Trạm thu phát Lora trung tâm',        100],
      [6,  'AIR',     'Đo nhiệt ẩm vườn chôm chôm',          95],
      [7,  'SOIL',    'Cảm biến độ ẩm đồi cam',              80],
      [8,  'WATER',   'Cảm biến lưu lượng nước tưới mận',    88],
      [9,  'WATER',   'Đo pH/EC bồn thủy canh',              92],
      [10, 'SOIL',    'Cảm biến gốc bưởi',                   70],
    ];
    for (final d in devices) {
      batch.insert('iot_IoTDevices', {
        'FarmId': d[0], 'DeviceType': d[1],
        'Description': d[2], 'BatteryLevel': d[3],
      });
    }

    // iot_IoTSensorReadings
    final readings = [
      [1,  'Moisture',       45.5],
      [2,  'Temperature',    28.2],
      [3,  'WaterLevel',      1.2],
      [4,  'PH',              6.5],
      [5,  'SignalStrength', 99.0],
      [6,  'Humidity',       75.0],
      [7,  'Moisture',       50.1],
      [8,  'FlowRate',       15.5],
      [9,  'EC',              1.8],
      [10, 'Temperature',    29.0],
    ];
    for (final r in readings) {
      batch.insert('iot_IoTSensorReadings', {
        'DeviceId': r[0], 'MetricType': r[1], 'MetricValue': r[2],
      });
    }

    // iot_FarmingLogs
    final logs = [
      [1,  'Bón phân',       'NPK 16-16-8',      50.0],
      [2,  'Phun thuốc',     'Thuốc sinh học',     2.0],
      [3,  'Tưới nước',      'Nước giếng khoan', 500.0],
      [4,  'Thu hoạch',      'Xà lách',           50.0],
      [5,  'Cắt tỉa',        null,                 0.0],
      [6,  'Bón lót',        'Phân chuồng',      200.0],
      [7,  'Bao trái',       'Túi lưới',        1000.0],
      [8,  'Làm cỏ',         null,                 0.0],
      [9,  'Pha dinh dưỡng', 'Dung dịch A B',      5.0],
      [10, 'Ghi chép',       null,                 0.0],
    ];
    for (final l in logs) {
      batch.insert('iot_FarmingLogs', {
        'FarmId': l[0], 'ActionType': l[1],
        'MaterialUsed': l[2], 'Quantity': l[3],
      });
    }

    await batch.commit(noResult: true);
  }

  // -------------------------------------------------------
  // 5. MACHINES + BOOKINGS + PRODUCTS + CARTS + ORDERS + NOTIFS
  // -------------------------------------------------------
  Future<void> _seedLogisticsAndCommerce(Database db) async {
    final batch = db.batch();

    // logistics_AgriMachines
    final machines = [
      [6, 'Máy Cày Kubota L5018',  'Máy cày 50HP kèm dàn xới',  250000.0, 1],
      [6, 'Drone Phun Thuốc DJI',  'Drone tải trọng 40 lít',     800000.0, 1],
      [6, 'Máy Gặt Đập Liên Hợp', 'Thu hoạch lúa nhanh',         500000.0, 1],
      [8, 'Xe Tải Isuzu 2 Tấn',   'Xe thùng bạt chở nông sản',  150000.0, 0],
      [6, 'Máy Sấy Vĩ Ngang',     'Máy sấy lúa 4 tấn/mẻ',      100000.0, 1],
      [6, 'Máy Gieo Hạt 8 Hàng',  'Gieo hạt tự động hóa',       120000.0, 1],
      [8, 'Xe Cẩu 1 Tấn',         'Cẩu vật tư',                  300000.0, 0],
      [6, 'Máy Xới Đất Đa Năng',  'Xới luống động cơ xăng',      80000.0, 1],
      [8, 'Xe Tải Hino 5 Tấn',    'Chở hàng đường dài',          250000.0, 1],
      [6, 'Hệ Thống Tưới Cuộn',   'Ống cuộn tưới 200m',          70000.0, 1],
    ];
    for (final m in machines) {
      batch.insert('logistics_AgriMachines', {
        'OwnerId': m[0], 'MachineType': m[1],
        'Description': m[2], 'BasePricePerHour': m[3], 'IsApproved': m[4],
      });
    }

    // logistics_MachineBookings
    final bookings = [
      [2,  1, 1, '2026-04-20 07:00', '2026-04-20 09:00', 1600000.0, 'BOOKED'],
      [3,  3, 2, '2026-04-25 08:00', '2026-04-25 12:00', 2000000.0, 'COMPLETED'],
      [4,  5, 3, '2026-04-26 09:00', '2026-04-26 13:00',  600000.0, 'COMPLETED'],
      [8,  7, 4, '2026-04-10 08:00', '2026-04-10 10:00',  160000.0, 'CANCELLED'],
      [10, 2, 1, '2026-04-18 16:00', '2026-04-18 18:00',  140000.0, 'BOOKED'],
      [9,  6, 3, '2026-04-15 15:00', '2026-04-16 15:00', 6000000.0, 'IN_PROGRESS'],
      [1,  4, 2, '2026-05-10 06:00', '2026-05-10 10:00', 1000000.0, 'BOOKED'],
      [7,  8, 4, '2026-05-12 08:00', '2026-05-12 10:00',  600000.0, 'BOOKED'],
      [5,  9, 1, '2026-04-22 07:00', '2026-04-22 15:00',  800000.0, 'COMPLETED'],
      [6, 10, 3, '2026-04-05 06:00', '2026-04-05 10:00',  480000.0, 'COMPLETED'],
    ];
    for (final b in bookings) {
      batch.insert('logistics_MachineBookings', {
        'MachineId': b[0], 'FarmId': b[1], 'BookerId': b[2],
        'StartTime': b[3], 'EndTime': b[4],
        'TotalPrice': b[5], 'Status': b[6],
      });
    }

    // commerce_Products
    final products = [
      [1, 'Cà Phê Nhân Robusta', 'Cà phê xanh sàng 18',   'Nông sản',  65000.0, 'kg'],
      [2, 'Gạo Tám Thơm',        'Gạo Nam Định',            'Nông sản',  22000.0, 'kg'],
      [3, 'Sầu Riêng Ri6',       'Sầu riêng Tiền Giang',   'Trái cây', 150000.0, 'hộp'],
      [4, 'Cam Cao Phong',        'Cam Hòa Bình',            'Trái cây',  40000.0, 'kg'],
      [7, 'Phân NPK Đầu Trâu',   'Bao 25kg',                'Vật tư',   450000.0, 'bao'],
      [5, 'Dưa Lưới Taki',       'Trồng nhà màng',          'Trái cây',  85000.0, 'trái'],
      [1, 'Hạt Tiêu Đen',        'Tiêu sấy khô',            'Nông sản', 120000.0, 'kg'],
      [5, 'Rau Xà Lách',         'Thủy canh sạch',          'Nông sản',  35000.0, 'kg'],
      [3, 'Bưởi Da Xanh',        'Bưởi ruột hồng',          'Trái cây',  60000.0, 'trái'],
      [7, 'Chế Phẩm Sinh Học',   'Trị nấm cây trồng',       'Vật tư',   120000.0, 'chai'],
    ];
    for (final p in products) {
      batch.insert('commerce_Products', {
        'SellerId': p[0], 'Title': p[1], 'Description': p[2],
        'Category': p[3], 'Price': p[4], 'Unit': p[5],
      });
    }

    // commerce_Carts – mỗi user 1 cart
    for (int i = 1; i <= 10; i++) {
      batch.insert('commerce_Carts', {'UserId': i});
    }

    await batch.commit(noResult: true);

    // CartItems, Orders, OrderItems, Notifications (batch riêng)
    final batch2 = db.batch();

    // commerce_CartItems
    final cartItems = [
      [1,  5,  2.0], [2,  1,  5.0], [3,  2, 20.0], [4,  3,  1.0], [5,  4,  5.0],
      [6,  9, 10.0], [7, 10,  2.0], [8,  6,  4.0], [9,  7,  2.0], [10, 8,  3.0],
    ];
    for (final ci in cartItems) {
      batch2.insert('commerce_CartItems', {
        'CartId': ci[0], 'ProductId': ci[1], 'Quantity': ci[2],
      });
    }

    // commerce_Orders
    final orders = [
      [3,  545000.0, 'COMPLETED'], [1,  900000.0, 'PAID'],
      [2,  325000.0, 'SHIPPING'],  [4,  150000.0, 'COMPLETED'],
      [5,  200000.0, 'CREATED'],   [6,  380000.0, 'PAID'],
      [7,  500000.0, 'COMPLETED'], [8,  340000.0, 'SHIPPING'],
      [9,  650000.0, 'COMPLETED'], [10, 150000.0, 'CANCELLED'],
    ];
    for (final o in orders) {
      batch2.insert('commerce_Orders', {
        'BuyerId': o[0], 'OrderTotal': o[1], 'Status': o[2],
      });
    }

    // commerce_OrderItems
    final orderItems = [
      [1, 1,  5.0,  65000.0], [1, 2, 10.0,  22000.0],
      [2, 5,  2.0, 450000.0], [3, 1,  5.0,  65000.0],
      [4, 3,  1.0, 150000.0], [5, 4,  5.0,  40000.0],
      [6, 9, 10.0,  38000.0], [7, 10, 2.0, 250000.0],
      [8, 6,  4.0,  85000.0], [9, 1, 10.0,  65000.0],
    ];
    for (final oi in orderItems) {
      batch2.insert('commerce_OrderItems', {
        'OrderId': oi[0], 'ProductId': oi[1],
        'Quantity': oi[2], 'Price': oi[3],
      });
    }

    // Notifications
    final notifs = [
      [1,  'Đơn mua phân bón của bạn đã thanh toán', 1],
      [2,  'Độ ẩm ruộng lúa đang thấp',              0],
      [6,  'Có yêu cầu thuê máy mới',                0],
      [3,  'Đơn hàng #1 đã giao thành công',          1],
      [4,  'Chuyên gia đã phản hồi câu hỏi',          0],
      [8,  'Máy gặt sẽ đến vào 01/05',                1],
      [8,  'Tài xế nhận cuốc xe tải thành công',      1],
      [1,  'Pin trạm Lora Farm 1 sắp hết',            0],
      [6,  'Thanh toán đơn #6 thành công',            1],
      [9,  'Có 5 người dùng mới cần duyệt',          0],
    ];
    for (final n in notifs) {
      batch2.insert('Notifications', {
        'UserId': n[0], 'Title': n[1], 'IsRead': n[2],
      });
    }

    await batch2.commit(noResult: true);
  }

  // -------------------------------------------------------
  // 6. IMAGES – khớp 100% SQL gốc (18A / 18B / 18C / 18D)
  // -------------------------------------------------------
  Future<void> _seedImages(Database db) async {
    final batch = db.batch();

    // ---- 18A. PRODUCT IMAGES (30 rows) ----
    final productImages = [
      // Product 1
      [1, 'https://picsum.photos/id/101/400/400', 1, 1],
      [1, 'https://picsum.photos/id/102/400/400', 0, 2],
      [1, 'https://picsum.photos/id/103/400/400', 0, 3],
      // Product 2
      [2, 'https://picsum.photos/id/104/400/400', 1, 1],
      [2, 'https://picsum.photos/id/106/400/400', 0, 2],
      [2, 'https://picsum.photos/id/107/400/400', 0, 3],
      // Product 3
      [3, 'https://picsum.photos/id/108/400/400', 1, 1],
      [3, 'https://picsum.photos/id/109/400/400', 0, 2],
      [3, 'https://picsum.photos/id/110/400/400', 0, 3],
      // Product 4
      [4, 'https://picsum.photos/id/111/400/400', 1, 1],
      [4, 'https://picsum.photos/id/112/400/400', 0, 2],
      [4, 'https://picsum.photos/id/113/400/400', 0, 3],
      // Product 5
      [5, 'https://picsum.photos/id/114/400/400', 1, 1],
      [5, 'https://picsum.photos/id/115/400/400', 0, 2],
      [5, 'https://picsum.photos/id/116/400/400', 0, 3],
      // Product 6
      [6, 'https://picsum.photos/id/117/400/400', 1, 1],
      [6, 'https://picsum.photos/id/118/400/400', 0, 2],
      [6, 'https://picsum.photos/id/119/400/400', 0, 3],
      // Product 7
      [7, 'https://picsum.photos/id/120/400/400', 1, 1],
      [7, 'https://picsum.photos/id/121/400/400', 0, 2],
      [7, 'https://picsum.photos/id/122/400/400', 0, 3],
      // Product 8
      [8, 'https://picsum.photos/id/123/400/400', 1, 1],
      [8, 'https://picsum.photos/id/124/400/400', 0, 2],
      [8, 'https://picsum.photos/id/125/400/400', 0, 3],
      // Product 9
      [9, 'https://picsum.photos/id/126/400/400', 1, 1],
      [9, 'https://picsum.photos/id/127/400/400', 0, 2],
      [9, 'https://picsum.photos/id/128/400/400', 0, 3],
      // Product 10
      [10, 'https://picsum.photos/id/129/400/400', 1, 1],
      [10, 'https://picsum.photos/id/130/400/400', 0, 2],
      [10, 'https://picsum.photos/id/131/400/400', 0, 3],
    ];
    for (final img in productImages) {
      batch.insert('Images', {
        'ReferenceId': img[0], 'ReferenceType': 'PRODUCT',
        'ImageUrl': img[1], 'IsPrimary': img[2], 'DisplayOrder': img[3],
      });
    }

    // ---- 18B. USER / SME IMAGES (10 rows) ----
    final userSmeImages = [
      [1,  'USER', 'https://i.pravatar.cc/150?u=1'],
      [2,  'USER', 'https://i.pravatar.cc/150?u=2'],
      [3,  'USER', 'https://i.pravatar.cc/150?u=3'],
      [4,  'USER', 'https://i.pravatar.cc/150?u=4'],
      [5,  'SME',  'https://picsum.photos/id/205/200/200'],
      [6,  'SME',  'https://picsum.photos/id/206/200/200'],
      [7,  'SME',  'https://picsum.photos/id/207/200/200'],
      [8,  'SME',  'https://picsum.photos/id/208/200/200'],
      [9,  'USER', 'https://i.pravatar.cc/150?u=9'],
      [10, 'USER', 'https://i.pravatar.cc/150?u=10'],
    ];
    for (final img in userSmeImages) {
      batch.insert('Images', {
        'ReferenceId': img[0], 'ReferenceType': img[1],
        'ImageUrl': img[2], 'IsPrimary': 1,
      });
    }

    // ---- 18C. FARM IMAGES (10 rows) ----
    final farmImages = [
      [1,  'https://picsum.photos/id/211/600/400'],
      [2,  'https://picsum.photos/id/212/600/400'],
      [3,  'https://picsum.photos/id/213/600/400'],
      [4,  'https://picsum.photos/id/214/600/400'],
      [5,  'https://picsum.photos/id/215/600/400'],
      [6,  'https://picsum.photos/id/216/600/400'],
      [7,  'https://picsum.photos/id/217/600/400'],
      [8,  'https://picsum.photos/id/218/600/400'],
      [9,  'https://picsum.photos/id/219/600/400'],
      [10, 'https://picsum.photos/id/220/600/400'],
    ];
    for (final img in farmImages) {
      batch.insert('Images', {
        'ReferenceId': img[0], 'ReferenceType': 'FARM',
        'ImageUrl': img[1], 'IsPrimary': 1,
      });
    }

    // ---- 18D. MACHINE IMAGES (10 rows) ----
    final machineImages = [
      [1,  'https://picsum.photos/id/221/500/300'],
      [2,  'https://picsum.photos/id/222/500/300'],
      [3,  'https://picsum.photos/id/223/500/300'],
      [4,  'https://picsum.photos/id/224/500/300'],
      [5,  'https://picsum.photos/id/225/500/300'],
      [6,  'https://picsum.photos/id/226/500/300'],
      [7,  'https://picsum.photos/id/227/500/300'],
      [8,  'https://picsum.photos/id/228/500/300'],
      [9,  'https://picsum.photos/id/229/500/300'],
      [10, 'https://picsum.photos/id/230/500/300'],
    ];
    for (final img in machineImages) {
      batch.insert('Images', {
        'ReferenceId': img[0], 'ReferenceType': 'MACHINE',
        'ImageUrl': img[1], 'IsPrimary': 1,
      });
    }

    await batch.commit(noResult: true);
  }
}
