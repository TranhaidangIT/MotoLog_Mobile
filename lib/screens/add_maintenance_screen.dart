import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vehicle_provider.dart';
import '../providers/maintenance_provider.dart';
import '../data/models/maintenance_entry.dart';
import '../utils/maintenance_utils.dart';

class AddMaintenanceScreen extends ConsumerStatefulWidget {
  const AddMaintenanceScreen({super.key});
  @override
  ConsumerState<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  String? _selectedType;
  DateTime _date = DateTime.now();
  final _odoCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  final _types = MaintenanceUtils.allItems;

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 14),
    child: Text(text, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm bảo dưỡng'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Hạng mục bảo dưỡng'),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: _decoration('Chọn hạng mục'),
            isExpanded: true,
            items: _types.map((t) => DropdownMenuItem(
              value: t, 
              child: Row(
                children: [
                  Image.asset(MaintenanceUtils.getIcon(t), width: 28, height: 28),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t, style: GoogleFonts.beVietnamPro(fontSize: 13), overflow: TextOverflow.ellipsis)),
                ],
              ),
            )).toList(),
            onChanged: (v) => setState(() => _selectedType = v),
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
                if (vehicleId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn xe trước')));
                  return;
                }

                if (_selectedType == null || _odoCtrl.text.isEmpty || _costCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Hạng mục, ODO và Chi phí')));
                  return;
                }

                final entry = MaintenanceEntry(
                  vehicleId: vehicleId,
                  title: _selectedType!,
                  type: MaintenanceType.routine,
                  date: _date,
                  odometer: double.tryParse(_odoCtrl.text) ?? 0,
                  cost: double.tryParse(_costCtrl.text) ?? 0,
                  note: _noteCtrl.text,
                );

                await ref.read(maintenanceNotifierProvider.notifier).add(entry);
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
