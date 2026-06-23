import 'dart:io' as java_io;
import 'package:sqflite/sqflite.dart';
import '../../models/vehicle.dart';
import '../database_helper.dart';
import '../../../core/constants/app_constants.dart';

/// DAO cho bảng vehicles — CRUD operations
class VehicleDao {
  VehicleDao._();
  static final VehicleDao instance = VehicleDao._();

  Future<Database> get _db => DatabaseHelper.instance.database;

  // ===== CREATE =====
  Future<void> insert(Vehicle vehicle) async {
    final db = await _db;
    await db.insert(
      AppConstants.tableVehicles,
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===== READ =====

  /// Lấy tất cả xe (sắp xếp theo ngày tạo mới nhất)
  Future<List<Vehicle>> getAll({String? userId}) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableVehicles,
      where: userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'created_at DESC',
    );
    return maps.map(Vehicle.fromMap).toList();
  }

  /// Lấy xe theo ID
  Future<Vehicle?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableVehicles,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  /// Lấy tất cả xe chưa được đồng bộ (is_synced = 0)
  Future<List<Vehicle>> getUnsynced() async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableVehicles,
      where: 'is_synced = 0',
    );
    return maps.map(Vehicle.fromMap).toList();
  }

  // ===== UPDATE =====
  Future<void> update(Vehicle vehicle) async {
    final db = await _db;
    await db.update(
      AppConstants.tableVehicles,
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  /// Cập nhật chỉ odometer (sau khi thêm fuel/maintenance)
  Future<void> updateOdometer(String vehicleId, double odometer) async {
    final db = await _db;
    await db.update(
      AppConstants.tableVehicles,
      {
        'odometer': odometer,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND odometer < ?',
      whereArgs: [vehicleId, odometer],
    );
  }

  // ===== DELETE =====
  Future<void> delete(String id) async {
    final vehicle = await getById(id);
    if (vehicle != null) {
      _deleteFile(vehicle.imageUrl);
      _deleteFile(vehicle.registrationImageUrl);
      _deleteFile(vehicle.inspectionImageUrl);
      _deleteFile(vehicle.insuranceImageUrl);
    }
    final db = await _db;
    await db.delete(
      AppConstants.tableVehicles,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void _deleteFile(String? path) {
    if (path != null && path.isNotEmpty) {
      try {
        final file = java_io.File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        // Ignore
      }
    }
  }

  // ===== COUNT =====
  Future<int> count({String? userId}) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${AppConstants.tableVehicles}${userId != null ? " WHERE user_id = '$userId'" : ""}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
