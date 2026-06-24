import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../local/dao/vehicle_dao.dart';
import '../local/dao/fuel_dao.dart';
import '../local/dao/maintenance_dao.dart';

class DataExportService {
  static Future<File?> generateCsvExport(String uid) async {
    try {
      final vehicles = await VehicleDao.instance.getAll(userId: uid);
      if (vehicles.isEmpty) return null;

      List<List<dynamic>> csvData = [];

      for (var vehicle in vehicles) {
        csvData.add(['=== THÔNG TIN XE ===']);
        csvData.add(['Tên xe', 'Hãng', 'Dòng xe', 'Biển số', 'Năm SX', 'Odometer', 'Loại nhiên liệu']);
        csvData.add([
          vehicle.name, vehicle.brand, vehicle.model, vehicle.plateNumber,
          vehicle.year, vehicle.odometer, vehicle.fuelType
        ]);
        csvData.add([]);

        // Nhiên liệu
        final fuels = await FuelDao.instance.getByVehicle(vehicle.id);
        if (fuels.isNotEmpty) {
          csvData.add(['--- LỊCH SỬ ĐỔ XĂNG ---']);
          csvData.add(['Ngày', 'Odometer', 'Lít', 'Đơn giá', 'Tổng tiền', 'Đầy bình', 'Cây xăng', 'Địa chỉ']);
          for (var f in fuels) {
            csvData.add([
              f.date.toIso8601String(), f.odometer, f.liters, f.pricePerLiter, f.totalCost,
              f.isFull ? 'Có' : 'Không', f.stationName ?? '', f.stationAddress ?? ''
            ]);
          }
          csvData.add([]);
        }

        // Bảo dưỡng / Phụ tùng
        final maintenances = await MaintenanceDao.instance.getByVehicle(vehicle.id);
        if (maintenances.isNotEmpty) {
          csvData.add(['--- LỊCH SỬ BẢO DƯỠNG & PHỤ TÙNG ---']);
          csvData.add(['Ngày', 'Loại', 'Tiêu đề', 'Odometer', 'Chi phí', 'Ghi chú', 'Garage']);
          for (var m in maintenances) {
            String typeStr = m.type.name; // enum name
            csvData.add([
              m.date.toIso8601String(), typeStr, m.title, m.odometer, m.cost, m.note ?? '', m.garageName ?? ''
            ]);
          }
          csvData.add([]);
        }
      }

      // Convert to CSV string manually to avoid package dependency errors
      String csv = csvData.map((row) {
        return row.map((field) {
          String val = field?.toString() ?? '';
          return '"${val.replaceAll('"', '""')}"';
        }).join(',');
      }).join('\n');
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/MotoLog_ExportData.csv');
      await file.writeAsString(csv);
      
      return file;
    } catch (e) {
      print('Lỗi xuất CSV: $e');
      return null;
    }
  }
}
