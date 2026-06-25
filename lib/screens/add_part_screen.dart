import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../data/models/maintenance_entry.dart';
import '../providers/maintenance_provider.dart';
import '../providers/vehicle_provider.dart';

/// Màn hình Thêm Phụ tùng
/// Ghi nhận một lần thay phụ tùng kèm hình ảnh trước/sau và chi phí thực tế.
class AddPartScreen extends ConsumerStatefulWidget {
  const AddPartScreen({super.key});
  @override
  ConsumerState<AddPartScreen> createState() => _AddPartScreenState();
}

class _AddPartScreenState extends ConsumerState<AddPartScreen> {
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _odoCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  File? _beforePhoto;
  File? _afterPhoto;
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final costText = _costCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final odoText = _odoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (name.isEmpty || costText.isEmpty || odoText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên, số km và chi phí')),
      );
      return;
    }

    final cost = double.tryParse(costText) ?? 0;
    final odo = double.tryParse(odoText) ?? 0;

    final vehicleId = ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) return;

    setState(() => _isLoading = true);

    try {
      String? beforeImg;
      String? afterImg;

      if (_beforePhoto != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'part_${DateTime.now().millisecondsSinceEpoch}_before.jpg';
        final saved = await _beforePhoto!.copy('${appDir.path}/$fileName');
        beforeImg = saved.path;
      }
      if (_afterPhoto != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'part_${DateTime.now().millisecondsSinceEpoch}_after.jpg';
        final saved = await _afterPhoto!.copy('${appDir.path}/$fileName');
        afterImg = saved.path;
      }

      final entry = MaintenanceEntry(
        vehicleId: vehicleId,
        type: MaintenanceType.parts,
        title: name,
        date: _date,
        odometer: odo,
        cost: cost,
        beforeImageUrl: beforeImg,
        afterImageUrl: afterImg,
        note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      );

      await ref.read(maintenanceNotifierProvider.notifier).add(entry);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickPhoto({required bool isBefore}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.camera_alt_outlined), title: const Text('Chụp ảnh'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Chọn từ thư viện'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      if (isBefore) {
        _beforePhoto = File(picked.path);
      } else {
        _afterPhoto = File(picked.path);
      }
    });
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.divider)),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 14),
    child: Text(text, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
  );

  Widget _photoBox({required String label, required File? photo, required VoidCallback onTap, required VoidCallback onClear}) {
    return Expanded(
      child: GestureDetector(
        onTap: photo == null ? onTap : null,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.divider,
                  style: BorderStyle.solid,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: photo != null
                ? Image.file(photo, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.camera_alt_outlined, color: AppColors.textSecondary, size: 26),
                    const SizedBox(height: 6),
                    Text(label, textAlign: TextAlign.center, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
            ),
            if (photo != null)
              Positioned(
                top: 6, right: 6,
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm phụ tùng'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Tên phụ tùng'),
          TextField(controller: _nameCtrl, decoration: _decoration('Ví dụ: Lốp sau, Phuộc, Dây curoa...')),

          _label('Ngày thay'),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}'),
            decoration: _decoration('Chọn ngày').copyWith(suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2015), lastDate: DateTime(2035));
              if (picked != null) setState(() => _date = picked);
            },
          ),

          _label('Chỉ số ODO (km)'),
          TextField(controller: _odoCtrl, keyboardType: TextInputType.number, decoration: _decoration('Nhập số km hiện tại')),

          _label('Chi phí (VND)'),
          TextField(controller: _costCtrl, keyboardType: TextInputType.number, decoration: _decoration('Nhập số tiền')),

          _label('Ảnh tình trạng phụ tùng'),
          Row(children: [
            _photoBox(
              label: 'Ảnh trước\nkhi thay',
              photo: _beforePhoto,
              onTap: () => _pickPhoto(isBefore: true),
              onClear: () => setState(() => _beforePhoto = null),
            ),
            const SizedBox(width: 10),
            _photoBox(
              label: 'Ảnh sau\nkhi thay',
              photo: _afterPhoto,
              onTap: () => _pickPhoto(isBefore: false),
              onClear: () => setState(() => _afterPhoto = null),
            ),
          ]),

          _label('Ghi chú (không bắt buộc)'),
          TextField(controller: _noteCtrl, maxLines: 3, decoration: _decoration('Nhập ghi chú...')),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Lưu lại', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
