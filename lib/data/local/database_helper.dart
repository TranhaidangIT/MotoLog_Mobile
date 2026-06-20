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
        user_id      TEXT,
        created_at   TEXT NOT NULL,
        updated_at   TEXT NOT NULL
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
        is_full         INTEGER NOT NULL DEFAULT 1,
        note            TEXT,
        created_at      TEXT NOT NULL,
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
        created_at    TEXT NOT NULL,
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
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN engine_capacity TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN inspection_date TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN insurance_date TEXT');
      await db.execute('ALTER TABLE ${AppConstants.tableVehicles} ADD COLUMN is_registered INTEGER');
    }
  }

  /// Xóa toàn bộ data (dùng khi logout)
  Future<void> clearAll() async {
    final db = await database;
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
