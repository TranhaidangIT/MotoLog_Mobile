import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/part_record.dart';

class AddPartScreen extends StatefulWidget {
  const AddPartScreen({super.key});
  @override
  State<AddPartScreen> createState() => _AddPartScreenState();
}

class _AddPartScreenState extends State<AddPartScreen> {
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _odoCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  File? _beforePhoto;
  File? _afterPhoto;
  final _picker = ImagePicker();

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
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), shape: BoxShape.circle),
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
              onPressed: () {
                // TODO: lưu PartRecord vào storage/database
                Navigator.pop(context);
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
