import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motolog_mobile/theme/app_theme.dart';
import 'package:motolog_mobile/data/models/custom_reminder.dart';
import 'package:motolog_mobile/features/reminder/providers/custom_reminder_provider.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';

/// Màn hình Thêm Nhắc nhở tùy chỉnh
/// Hỗ trợ 3 loại nhắc: theo Ngày, theo km ODO, và theo mức Bình xăng.
class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});
  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  ReminderType _type = ReminderType.byDate;
  final _titleCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final _kmCtrl = TextEditingController();
  double _fuelFraction = 0.25; // 1/4 bình

  static const _typeLabels = {
    ReminderType.byDate: 'Theo ngày',
    ReminderType.byKm: 'Theo km',
    ReminderType.byFuelLevel: 'Theo mức xăng',
  };

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 14),
    child: Text(text, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
  );

  Widget _buildTypeSpecificField() {
    switch (_type) {
      case ReminderType.byDate:
        return TextField(
          readOnly: true,
          controller: TextEditingController(text: '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}'),
          decoration: _decoration('Chọn ngày hết hạn').copyWith(suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2040));
            if (picked != null) setState(() => _date = picked);
          },
        );
      case ReminderType.byKm:
        return TextField(
          controller: _kmCtrl,
          keyboardType: TextInputType.number,
          decoration: _decoration('Nhắc khi đạt mốc km (ví dụ: 20000)'),
        );
      case ReminderType.byFuelLevel:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nhắc khi bình xăng còn ${(_fuelFraction * 100).round()}%',
            style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600)),
          Slider(
            value: _fuelFraction, min: 0.1, max: 0.5, divisions: 8,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _fuelFraction = v),
          ),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhắc lịch'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Loại nhắc lịch'),
          Row(children: ReminderType.values.map((t) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = t),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _type == t ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _type == t ? AppColors.primary : AppColors.divider),
                ),
                alignment: Alignment.center,
                child: Text(_typeLabels[t]!, style: GoogleFonts.beVietnamPro(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: _type == t ? Colors.white : AppColors.textSecondary,
                )),
              ),
            ),
          )).toList()),

          _label('Tên nhắc lịch'),
          TextField(controller: _titleCtrl, decoration: _decoration('Ví dụ: Đăng kiểm, Bảo hiểm xe...')),

          _label(_type == ReminderType.byDate ? 'Ngày hết hạn'
                : _type == ReminderType.byKm ? 'Mốc km'
                : 'Ngưỡng cảnh báo'),
          _buildTypeSpecificField(),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final vehicleId = ref.read(selectedVehicleIdProvider);
                if (vehicleId == null) return;

                final subtitle = switch (_type) {
                  ReminderType.byDate => 'Hết hạn: ${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                  ReminderType.byKm => 'Tại mốc ${_kmCtrl.text} km',
                  ReminderType.byFuelLevel => 'Khi còn dưới ${(_fuelFraction * 100).round()}% bình',
                };
                
                final reminder = CustomReminder(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  vehicleId: vehicleId,
                  title: _titleCtrl.text.isEmpty ? 'Nhắc lịch mới' : _titleCtrl.text,
                  subtitle: subtitle,
                  type: _type,
                );
                
                await ref.read(customReminderNotifierProvider.notifier).addReminder(reminder);
                if (mounted) Navigator.pop(context);
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
