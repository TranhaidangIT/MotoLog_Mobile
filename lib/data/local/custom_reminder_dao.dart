import 'package:sqflite/sqflite.dart';
import 'package:motolog_mobile/core/constants/app_constants.dart';
import 'package:motolog_mobile/data/models/custom_reminder.dart';
import 'package:motolog_mobile/shared/database/database_helper.dart';

class CustomReminderDao {
  CustomReminderDao._();
  static final CustomReminderDao instance = CustomReminderDao._();

  Future<Database> get _db async => await DatabaseHelper.instance.database;

  Future<int> insert(CustomReminder item) async {
    final db = await _db;
    return await db.insert(
      AppConstants.tableCustomReminders,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CustomReminder>> getByVehicleId(String vehicleId) async {
    final db = await _db;
    final maps = await db.query(
      AppConstants.tableCustomReminders,
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    return maps.map((e) => CustomReminder.fromMap(e)).toList();
  }

  Future<int> update(CustomReminder item) async {
    final db = await _db;
    return await db.update(
      AppConstants.tableCustomReminders,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _db;
    return await db.delete(
      AppConstants.tableCustomReminders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
