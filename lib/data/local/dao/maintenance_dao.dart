import 'dart:io' as java_io;
import 'package:sqflite/sqflite.dart';
import '../../models/maintenance_entry.dart';
import '../database_helper.dart';
import '../../../core/constants/app_constants.dart';

/// DAO cho bảng maintenance_entries
class MaintenanceDao {
  MaintenanceDao._();
  static final MaintenanceDao instance = MaintenanceDao._();

  Future<Database> get _db => DatabaseHelper.instance.database;

  // ===== CREATE =====
  Future<void> insert(MaintenanceEntry entry) async {
    final db = await _db;
    await db.insert(
      AppConstants.tableMaintenanceEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===== READ =====

  /// Lấy tất cả bảo dưỡng của một xe
  Future<List<MaintenanceEntry>> getByVehicle(
    String vehicleId, {
    int? limit,
    String? type,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _db;
    String where = 'vehicle_id = ?';
    final args = <Object?>[vehicleId];

    if (type != null) {
      where += ' AND type = ?';
      args.add(type);
    }
    if (from != null) {
      where += ' AND date >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where += ' AND date <= ?';
      args.add(to.toIso8601String());
    }

    final maps = await db.query(
      AppConstants.tableMaintenanceEntries,
      where: where,
      whereArgs: args,
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map(MaintenanceEntry.fromMap).toList();
  }

  /// Lấy các mục sắp đến hạn bảo dưỡng (trong 7 ngày tới)
  Future<List<MaintenanceEntry>> getUpcomingDue({String? vehicleId}) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final inOneWeek =
        DateTime.now().add(const Duration(days: 7)).toIso8601String();

    String where =
        'next_due_date IS NOT NULL AND next_due_date BETWEEN ? AND ?';
    final args = <Object?>[now, inOneWeek];

    if (vehicleId != null) {
      where += ' AND vehicle_id = ?';
      args.add(vehicleId);
    }

    final maps = await db.query(
      AppConstants.tableMaintenanceEntries,
      where: where,
      whereArgs: args,
      orderBy: 'next_due_date ASC',
    );
    return maps.map(MaintenanceEntry.fromMap).toList();
  }

  /// Lấy một entry theo ID
  Future<MaintenanceEntry?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableMaintenanceEntries,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MaintenanceEntry.fromMap(maps.first);
  }

  /// Lấy tất cả hoá đơn bảo dưỡng chưa đồng bộ (is_synced = 0)
  Future<List<MaintenanceEntry>> getUnsynced() async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableMaintenanceEntries,
      where: 'is_synced = 0',
    );
    return maps.map(MaintenanceEntry.fromMap).toList();
  }

  // ===== STATISTICS =====

  /// Tổng chi phí bảo dưỡng
  Future<double> totalCostInRange(
    String vehicleId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _db;
    String where = 'vehicle_id = ?';
    final args = <Object?>[vehicleId];
    if (from != null) {
      where += ' AND date >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where += ' AND date <= ?';
      args.add(to.toIso8601String());
    }
    final result = await db.rawQuery(
      'SELECT SUM(cost) FROM ${AppConstants.tableMaintenanceEntries} WHERE $where',
      args,
    );
    if (result.isNotEmpty && result.first.values.first != null) {
      return (result.first.values.first as num).toDouble();
    }
    return 0.0;
  }

  /// Chi phí bảo dưỡng theo tháng
  Future<List<Map<String, dynamic>>> monthlyCosts(
    String vehicleId, {
    int months = 6,
  }) async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', date) as month,
        SUM(cost) as cost,
        COUNT(*) as count,
        type
      FROM ${AppConstants.tableMaintenanceEntries}
      WHERE vehicle_id = ?
      GROUP BY month
      ORDER BY month DESC
      LIMIT ?
    ''', [vehicleId, months]);
  }

  // ===== UPDATE =====
  Future<void> update(MaintenanceEntry entry) async {
    final db = await _db;
    await db.update(
      AppConstants.tableMaintenanceEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // ===== DELETE =====
  Future<void> delete(String id) async {
    final entry = await getById(id);
    if (entry != null) {
      _deleteFile(entry.imagePath);
      _deleteFile(entry.beforeImageUrl);
      _deleteFile(entry.afterImageUrl);
    }
    final db = await _db;
    await db.delete(
      AppConstants.tableMaintenanceEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Xoá toàn bộ lịch sử bảo dưỡng của một xe
  Future<void> deleteByVehicle(String vehicleId) async {
    final entries = await getByVehicle(vehicleId);
    for (var entry in entries) {
      _deleteFile(entry.imagePath);
      _deleteFile(entry.beforeImageUrl);
      _deleteFile(entry.afterImageUrl);
    }
    final db = await _db;
    await db.delete(
      AppConstants.tableMaintenanceEntries,
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
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
}
