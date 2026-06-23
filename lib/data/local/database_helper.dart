import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

/// Singleton quản lý SQLite database
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Tạo các bảng lần đầu
  Future<void> _createTables(Database db, int version) async {
    // Bảng xe
    await db.execute('''
      CREATE TABLE ${AppConstants.tableVehicles} (
        id           TEXT PRIMARY KEY,
        name         TEXT NOT NULL,
        brand        TEXT NOT NULL,
        model        TEXT NOT NULL,
        plate_number TEXT NOT NULL,
        year         INTEGER NOT NULL,
        odometer     REAL NOT NULL DEFAULT 0,
        fuel_type    TEXT NOT NULL DEFAULT 'Xăng',
        image_url    TEXT,
        color        TEXT NOT NULL DEFAULT '#FF6B00',
        engine_capacity TEXT,
        inspection_date TEXT,
        insurance_date TEXT,
        is_registered INTEGER,
        registration_image_url TEXT,
        inspection_image_url TEXT,
        insurance_image_url TEXT,
        user_id      TEXT,
        created_at   TEXT NOT NULL,
        updated_at   TEXT NOT NULL,
        cached_image_url TEXT,
        is_synced    INTEGER DEFAULT 1
      )
    ''');

    // Bảng đổ xăng
    await db.execute('''
      CREATE TABLE ${AppConstants.tableFuelEntries} (
        id              TEXT PRIMARY KEY,
        vehicle_id      TEXT NOT NULL,
        date            TEXT NOT NULL,
        odometer        REAL NOT NULL,
        liters          REAL NOT NULL,
        price_per_liter REAL NOT NULL,
        total_cost      REAL NOT NULL,
        station_name    TEXT,
        station_address TEXT,
        station_lat     REAL,
        station_lon     REAL,
        fuel_type       TEXT,
        is_full         INTEGER NOT NULL DEFAULT 1,
        note            TEXT,
        created_at      TEXT NOT NULL,
        is_synced       INTEGER DEFAULT 1,
        FOREIGN KEY (vehicle_id) REFERENCES ${AppConstants.tableVehicles}(id) ON DELETE CASCADE
      )
    ''');

    // Bảng bảo dưỡng
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMaintenanceEntries} (
        id            TEXT PRIMARY KEY,
        vehicle_id    TEXT NOT NULL,
        type          TEXT NOT NULL DEFAULT 'ROUTINE',
        title         TEXT NOT NULL,
        date          TEXT NOT NULL,
        odometer      REAL NOT NULL,
        cost          REAL NOT NULL DEFAULT 0,
        garage_name   TEXT,
        next_due_date TEXT,
        next_due_km   REAL,
        note          TEXT,
        image_path    TEXT,
        created_at    TEXT NOT NULL,
        is_synced     INTEGER DEFAULT 1,
        FOREIGN KEY (vehicle_id) REFERENCES ${AppConstants.tableVehicles}(id) ON DELETE CASCADE
      )
    ''');

    // Bảng cấu hình hạng mục bảo dưỡng định kỳ
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMaintenanceItems} (
        id            TEXT PRIMARY KEY,
        vehicle_id    TEXT NOT NULL,
        name          TEXT NOT NULL,
        icon_code     TEXT NOT NULL,
        interval_km   INTEGER NOT NULL,
        last_done_odo INTEGER NOT NULL DEFAULT 0,
        is_reminder_on INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (vehicle_id) REFERENCES ${AppConstants.tableVehicles}(id) ON DELETE CASCADE
      )
    ''');

    // Bảng lời nhắc tuỳ chỉnh
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCustomReminders} (
        id            TEXT PRIMARY KEY,
        vehicle_id    TEXT NOT NULL,
        title         TEXT NOT NULL,
        subtitle      TEXT NOT NULL,
        type          TEXT NOT NULL,
        is_on         INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (vehicle_id) REFERENCES ${AppConstants.tableVehicles}(id) ON DELETE CASCADE
      )
    ''');

    // Index để query nhanh hơn
    await db.execute(
      'CREATE INDEX idx_fuel_vehicle ON ${AppConstants.tableFuelEntries}(vehicle_id, date DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_maint_vehicle ON ${AppConstants.tableMaintenanceEntries}(vehicle_id, date DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Xử lý migration khi nâng cấp version DB
    if (oldVersion < 9) {
      // Yêu cầu xoá sạch dữ liệu và khởi tạo lại ở v9
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableCustomReminders}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableMaintenanceItems}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableMaintenanceEntries}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableFuelEntries}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.tableVehicles}');
      await _createTables(db, newVersion);
      return;
    }

    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN engine_capacity TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN inspection_date TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN insurance_date TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN is_registered INTEGER');
    }
    if (oldVersion < 3) {
      // Dành cho Phụ tùng
      await db.execute('ALTER TABLE ${AppConstants.tableMaintenanceEntries} ADD COLUMN before_image_url TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableMaintenanceEntries} ADD COLUMN after_image_url TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE ${AppConstants.tableMaintenanceItems} (
          id            TEXT PRIMARY KEY,
          vehicle_id    TEXT NOT NULL,
          name          TEXT NOT NULL,
          icon_code     TEXT NOT NULL,
          interval_km   INTEGER NOT NULL,
          last_done_odo INTEGER NOT NULL DEFAULT 0,
          is_reminder_on INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (vehicle_id) REFERENCES ${AppConstants.tableVehicles}(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE ${AppConstants.tableCustomReminders} (
          id            TEXT PRIMARY KEY,
          vehicle_id    TEXT NOT NULL,
          title         TEXT NOT NULL,
          subtitle      TEXT NOT NULL,
          type          TEXT NOT NULL,
          is_on         INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (vehicle_id) REFERENCES ${AppConstants.tableVehicles}(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE ${AppConstants.tableMaintenanceEntries} ADD COLUMN image_path TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN registration_image_url TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN inspection_image_url TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN insurance_image_url TEXT');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE ${AppConstants.tableFuelEntries} ADD COLUMN station_lat REAL');
      await db.execute('ALTER TABLE ${AppConstants.tableFuelEntries} ADD COLUMN station_lon REAL');
      await db.execute('ALTER TABLE ${AppConstants.tableFuelEntries} ADD COLUMN fuel_type TEXT');
    }
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN cached_image_url TEXT');
    }
    if (oldVersion < 10) {
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN is_synced INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE ${AppConstants.tableFuelEntries} ADD COLUMN is_synced INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE ${AppConstants.tableMaintenanceEntries} ADD COLUMN is_synced INTEGER DEFAULT 1');
    }
    if (oldVersion < 11) {
      await db.execute('ALTER TABLE ${AppConstants.tableFuelEntries} ADD COLUMN station_address TEXT');
    }
  }

  /// Xóa toàn bộ data (dùng khi logout)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(AppConstants.tableCustomReminders);
    await db.delete(AppConstants.tableMaintenanceItems);
    await db.delete(AppConstants.tableMaintenanceEntries);
    await db.delete(AppConstants.tableFuelEntries);
    await db.delete(AppConstants.tableVehicles);
  }

  /// Đóng DB
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
