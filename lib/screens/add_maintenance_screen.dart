import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../providers/vehicle_provider.dart';
import '../providers/maintenance_provider.dart';
import '../providers/maintenance_item_provider.dart';
import '../providers/fuel_provider.dart';
import '../data/models/maintenance_entry.dart';

/// Màn hình Thêm lịch sử Bảo dưỡng
/// Ghi nhận một lần thực hiện bảo dưỡng, cập nhật ODO và kết nối với hạng mục bảo dưỡng.
class AddMaintenanceScreen extends ConsumerStatefulWidget {
  const AddMaintenanceScreen({super.key});
  @override
  ConsumerState<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  String? _selectedItemId;
  DateTime _date = DateTime.now();
  final _odoCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  File? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 14),
    child: Text(text, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
  );

  @override
  Widget build(BuildContext context) {
    final maintenanceItems = ref.watch(maintenanceItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm bảo dưỡng'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Hạng mục bảo dưỡng'),
          DropdownButtonFormField<String>(
            initialValue: _selectedItemId,
            decoration: _decoration('Chọn hạng mục'),
            isExpanded: true,
            items: maintenanceItems.map((item) => DropdownMenuItem(
              value: item.id, 
              child: Row(
                children: [
                  Icon(item.icon, size: 24, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.name, style: GoogleFonts.beVietnamPro(fontSize: 13), overflow: TextOverflow.ellipsis)),
                ],
              ),
            )).toList(),
            onChanged: (v) => setState(() => _selectedItemId = v),
          ),

          _label('Ngày thực hiện'),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}'),
            decoration: _decoration('Chọn ngày').copyWith(suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context, initialDate: _date,
                firstDate: DateTime(2015), lastDate: DateTime(2035),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),

          _label('Chỉ số ODO (km)'),
          TextField(
            controller: _odoCtrl,
            keyboardType: TextInputType.number,
            decoration: _decoration('Nhập số km hiện tại'),
          ),

          _label('Chi phí (VND)'),
          TextField(
            controller: _costCtrl,
            keyboardType: TextInputType.number,
            decoration: _decoration('Nhập số tiền'),
          ),

          _label('Hình ảnh phụ tùng / Hóa đơn'),
          if (_imageFile != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _imageFile = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt, color: AppColors.primary),
                    label: Text('Chụp ảnh', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library, color: AppColors.primary),
                    label: Text('Thư viện', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),

          _label('Ghi chú (không bắt buộc)'),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: _decoration('Nhập ghi chú...'),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final vehicleId = ref.read(selectedVehicleIdProvider);
                if (vehicleId == null) return;
                
                final odo = double.tryParse(_odoCtrl.text) ?? 0;
                
                // --- BẮt ĐẦU KIỂM TRA ODO ---
                final fuelEntries = ref.read(fuelListProvider).valueOrNull ?? [];
                final maintEntries = ref.read(maintenanceListProvider).valueOrNull ?? [];
                
                double maxOdo = 0;
                if (fuelEntries.isNotEmpty) maxOdo = fuelEntries.first.odometer;
                if (maintEntries.isNotEmpty && maintEntries.first.odometer > maxOdo) {
                  maxOdo = maintEntries.first.odometer;
                }
                
                final vehicle = ref.read(selectedVehicleProvider).valueOrNull;
                if (vehicle != null && vehicle.odometer > maxOdo) {
                  maxOdo = vehicle.odometer;
                }

                if (odo > 0 && odo < maxOdo) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Số ODO phải lớn hơn hoặc bằng mốc hiện tại (${maxOdo.toInt()} km)'),
                      backgroundColor: Colors.red,
                    ));
                  }
                  return;
                }
                // --- KẾT THÚC KIỂM TRA ODO ---

                if (_selectedItemId != null) {
                  // Cập nhật lastDoneOdo
                  await ref.read(maintenanceItemNotifierProvider.notifier).markDone(_selectedItemId!, odo.toInt());
                  
                  // Thêm lịch sử chi phí
                  final selectedItem = maintenanceItems.firstWhere((e) => e.id == _selectedItemId);
                  final entry = MaintenanceEntry(
                    vehicleId: vehicleId,
                    title: selectedItem.name,
                    type: MaintenanceType.routine,
                    date: _date,
                    odometer: odo,
                    cost: double.tryParse(_costCtrl.text) ?? 0,
                    note: _noteCtrl.text,
                    imagePath: _imageFile?.path, // Lưu image path
                  );
                  await ref.read(maintenanceNotifierProvider.notifier).add(entry);
                }

                if (mounted) context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Lưu lại', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
