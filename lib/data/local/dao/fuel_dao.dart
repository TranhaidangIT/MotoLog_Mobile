import 'package:sqflite/sqflite.dart';
import '../../models/fuel_entry.dart';
import '../database_helper.dart';
import '../../../core/constants/app_constants.dart';

/// DAO cho bảng fuel_entries
class FuelDao {
  FuelDao._();
  static final FuelDao instance = FuelDao._();

  Future<Database> get _db => DatabaseHelper.instance.database;

  // ===== CREATE =====
  Future<void> insert(FuelEntry entry) async {
    final db = await _db;
    await db.insert(
      AppConstants.tableFuelEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===== READ =====

  /// Lấy tất cả lần đổ xăng của một xe
  Future<List<FuelEntry>> getByVehicle(
    String vehicleId, {
    int? limit,
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

    final maps = await db.query(
      AppConstants.tableFuelEntries,
      where: where,
      whereArgs: args,
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
    );
    return maps.map(FuelEntry.fromMap).toList();
  }

  /// Lấy lần đổ xăng gần nhất
  Future<FuelEntry?> getLatest(String vehicleId) async {
    final entries = await getByVehicle(vehicleId, limit: 1);
    return entries.isEmpty ? null : entries.first;
  }

  /// Lấy một entry theo ID
  Future<FuelEntry?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableFuelEntries,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FuelEntry.fromMap(maps.first);
  }

  // ===== STATISTICS =====

  /// Tổng tiền xăng trong khoảng thời gian
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
      'SELECT SUM(total_cost) FROM ${AppConstants.tableFuelEntries} WHERE $where',
      args,
    );
    return (Sqflite.firstIntValue(result) ?? 0).toDouble();
  }

  /// Tổng lít xăng trong khoảng thời gian
  Future<double> totalLitersInRange(
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
      'SELECT SUM(liters) FROM ${AppConstants.tableFuelEntries} WHERE $where',
      args,
    );
    return (Sqflite.firstIntValue(result) ?? 0).toDouble();
  }

  /// Chi phí xăng theo tháng (cho biểu đồ)
  Future<List<Map<String, dynamic>>> monthlyCosts(
    String vehicleId, {
    int months = 6,
  }) async {
    final db = await _db;
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', date) as month,
        SUM(total_cost) as cost,
        SUM(liters) as liters,
        COUNT(*) as count
      FROM ${AppConstants.tableFuelEntries}
      WHERE vehicle_id = ?
      GROUP BY month
      ORDER BY month DESC
      LIMIT ?
    ''', [vehicleId, months]);
  }

  // ===== UPDATE =====
  Future<void> update(FuelEntry entry) async {
    final db = await _db;
    await db.update(
      AppConstants.tableFuelEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // ===== DELETE =====
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(
      AppConstants.tableFuelEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
