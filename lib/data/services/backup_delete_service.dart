import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../local/dao/vehicle_dao.dart';
import '../local/dao/fuel_dao.dart';
import '../local/dao/maintenance_dao.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/maintenance_provider.dart';
import 'firestore_service.dart';

/// Dịch vụ sao lưu và xoá xe.
/// Khi người dùng xoá xe, toàn bộ dữ liệu lịch sử sẽ được gom thành
/// một bản báo cáo HTML và gửi qua email (thông qua Firebase Extension
/// Trigger Email), sau đó xoá sạch dữ liệu trong SQLite cục bộ.
class BackupDeleteService {
  static Future<void> deleteVehicleWithBackup(
    BuildContext context,
    String vehicleId,
    WidgetRef ref,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thực hiện xoá xe')),
      );
      return;
    }

    // Hiện loading trong khi xử lý
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Đang sao lưu & xoá xe...'),
          ],
        ),
      ),
    );

    try {
      final vDao = VehicleDao.instance;
      final fDao = FuelDao.instance;
      final mDao = MaintenanceDao.instance;

      final vehicle = await vDao.getById(vehicleId);
      if (vehicle == null) throw Exception('Không tìm thấy xe');

      final fuels = await fDao.getByVehicle(vehicleId);
      final maints = await mDao.getByVehicle(vehicleId);

      final totalFuel = fuels.fold<double>(0, (s, e) => s + e.totalCost);
      final totalMaint = maints.fold<double>(0, (s, e) => s + e.cost);
      final totalAll = totalFuel + totalMaint;
      final fmt = NumberFormat('#,###', 'vi_VN');

      // Tạo báo cáo HTML gửi email
      final buffer = StringBuffer();
      buffer.write('''
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
          <h2 style="color: #2E7D32;">MotoLog – Báo cáo xoá xe</h2>
          <h3>${vehicle.name} (Biển số: ${vehicle.plateNumber})</h3>
          <p><b>Tổng quãng đường:</b> ${fmt.format(vehicle.odometer)} km</p>
          <p><b>Tổng chi phí (Xăng + Bảo dưỡng):</b> <span style="color: #D32F2F; font-weight: bold;">${fmt.format(totalAll)} đ</span></p>

          <h3 style="border-bottom: 1px solid #ccc; padding-bottom: 5px;">Hồ sơ / Giấy tờ xe</h3>
      ''');

      bool hasImages = false;
      if (vehicle.registrationImageUrl?.isNotEmpty == true) {
        buffer.write('<p>📄 <a href="${vehicle.registrationImageUrl}">Ảnh Đăng ký xe</a></p>');
        hasImages = true;
      }
      if (vehicle.inspectionImageUrl?.isNotEmpty == true) {
        buffer.write('<p>📄 <a href="${vehicle.inspectionImageUrl}">Ảnh Đăng kiểm</a></p>');
        hasImages = true;
      }
      if (vehicle.insuranceImageUrl?.isNotEmpty == true) {
        buffer.write('<p>📄 <a href="${vehicle.insuranceImageUrl}">Ảnh Bảo hiểm</a></p>');
        hasImages = true;
      }
      if (!hasImages) {
        buffer.write('<p><i>Không có giấy tờ hình ảnh nào được tải lên.</i></p>');
      }

      buffer.write('''
        </div>
      ''');

      // Đẩy vào collection 'mail' để Firebase Extension tự gửi email
      await FirebaseFirestore.instance.collection('mail').add({
        'to': user.email,
        'message': {
          'subject': 'Sao lưu dữ liệu MotoLog: ${vehicle.name}',
          'html': buffer.toString(),
        },
      });

      // Xoá toàn bộ dữ liệu xe khỏi SQLite
      await fDao.deleteByVehicle(vehicleId);
      await mDao.deleteByVehicle(vehicleId);
      await vDao.delete(vehicleId);

      // Xoá trên Cloud
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        if (firestoreService != null) {
          await firestoreService.deleteVehicleWithRelatedData(vehicleId);
        }
      } catch (e) {
        debugPrint('Error deleting from Cloud: $e');
      }

      // Cập nhật lại tất cả providers liên quan
      ref.invalidate(vehicleNotifierProvider);
      ref.invalidate(vehicleListProvider);
      ref.invalidate(selectedVehicleProvider);
      ref.invalidate(fuelListProvider);
      ref.invalidate(maintenanceListProvider);

      // Nếu xe bị xoá đang được chọn thì reset selection
      final selectedId = ref.read(selectedVehicleIdProvider);
      if (selectedId == vehicleId) {
        await ref.read(selectedVehicleIdProvider.notifier).select(null);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Xoá xe thành công. Đã gửi email sao lưu dữ liệu!'),
          backgroundColor: Colors.green,
        ));
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}
