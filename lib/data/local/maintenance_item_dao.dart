import 'package:sqflite/sqflite.dart';
import 'package:motolog_mobile/core/constants/app_constants.dart';
import 'package:motolog_mobile/data/models/maintenance_item.dart';
import 'package:motolog_mobile/shared/database/database_helper.dart';

class MaintenanceItemDao {
  MaintenanceItemDao._();
  static final MaintenanceItemDao instance = MaintenanceItemDao._();

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<int> insert(MaintenanceItem item) async {
    final db = await _db;
    return await db.insert(
      AppConstants.tableMaintenanceItems,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAll(List<MaintenanceItem> items) async {
    final db = await _db;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        AppConstants.tableMaintenanceItems,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<MaintenanceItem>> getByVehicleId(String vehicleId) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableMaintenanceItems,
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    return maps.map((e) => MaintenanceItem.fromMap(e)).toList();
  }

  Future<int> update(MaintenanceItem item) async {
    final db = await _db;
    return await db.update(
      AppConstants.tableMaintenanceItems,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _db;
    return await db.delete(
      AppConstants.tableMaintenanceItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Khởi tạo các mục mặc định
  List<MaintenanceItem> getDefaultItems(String vehicleId) {
    return [
      MaintenanceItem(id: 'oil_$vehicleId', vehicleId: vehicleId, name: 'Thay nhớt máy', iconCode: 'opacity', intervalKm: 2000, lastDoneOdo: 0),
      MaintenanceItem(id: 'cvt_$vehicleId', vehicleId: vehicleId, name: 'Vệ sinh nồi (CVT)', iconCode: 'settings', intervalKm: 10000, lastDoneOdo: 0),
      MaintenanceItem(id: 'spark_$vehicleId', vehicleId: vehicleId, name: 'Thay bugi', iconCode: 'electrical_services', intervalKm: 10000, lastDoneOdo: 0),
      MaintenanceItem(id: 'air_$vehicleId', vehicleId: vehicleId, name: 'Thay lọc gió', iconCode: 'air', intervalKm: 12000, lastDoneOdo: 0),
      MaintenanceItem(id: 'coolant_$vehicleId', vehicleId: vehicleId, name: 'Thay nước làm mát', iconCode: 'water_drop', intervalKm: 15000, lastDoneOdo: 0),
      MaintenanceItem(id: 'battery_$vehicleId', vehicleId: vehicleId, name: 'Thay ắc quy', iconCode: 'battery_full', intervalKm: 20000, lastDoneOdo: 0),
    ];
  }
}
