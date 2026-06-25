import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../providers/vehicle_provider.dart';
import '../data/models/vehicle.dart';

enum DocType { registration, inspection, insurance }

/// Màn hình Chỉnh sửa Giấy tờ xe
/// Nhập hạn đăng kiểm, bảo hiểm, đăng ký và cho phép chụp/tải ảnh giấy tờ đính kèm.
class DocumentEditScreen extends ConsumerStatefulWidget {
  final DocType docType;
  const DocumentEditScreen({super.key, required this.docType});

  @override
  ConsumerState<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends ConsumerState<DocumentEditScreen> {
  DateTime? _selectedDate;
  bool _isRegistered = true;
  String? _imagePath;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vehicle = ref.read(selectedVehicleProvider).valueOrNull;
      if (vehicle != null) {
        setState(() {
          switch (widget.docType) {
            case DocType.inspection:
              _selectedDate = vehicle.inspectionDate;
              if (vehicle.inspectionImageUrl != null) _imagePath = vehicle.inspectionImageUrl;
              break;
            case DocType.insurance:
              _selectedDate = vehicle.insuranceDate;
              if (vehicle.insuranceImageUrl != null) _imagePath = vehicle.insuranceImageUrl;
              break;
            case DocType.registration:
              _isRegistered = vehicle.isRegistered ?? true;
              if (vehicle.registrationImageUrl != null) _imagePath = vehicle.registrationImageUrl;
              break;
          }
        });
      }
    });
  }

  String get _title {
    switch (widget.docType) {
      case DocType.inspection: return 'Đăng kiểm';
      case DocType.insurance: return 'Bảo hiểm xe';
      case DocType.registration: return 'Đăng ký xe';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _save() async {
    final vehicle = ref.read(selectedVehicleProvider).valueOrNull;
    if (vehicle == null) return;

    Vehicle updatedVehicle = vehicle;
    switch (widget.docType) {
      case DocType.inspection:
        updatedVehicle = vehicle.copyWith(inspectionDate: _selectedDate, inspectionImageUrl: _imagePath);
        break;
      case DocType.insurance:
        updatedVehicle = vehicle.copyWith(insuranceDate: _selectedDate, insuranceImageUrl: _imagePath);
        break;
      case DocType.registration:
        updatedVehicle = vehicle.copyWith(isRegistered: _isRegistered, registrationImageUrl: _imagePath);
        break;
    }

    await ref.read(vehicleNotifierProvider.notifier).updateEntry(updatedVehicle);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật $_title'), backgroundColor: AppColors.primary));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Lưu', style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.docType == DocType.registration) ...[
              Text('Trạng thái giấy tờ', style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Đầy đủ / Hợp lệ', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w500)),
                    Switch(
                      value: _isRegistered,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isRegistered = v),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text('Ngày hết hạn', style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context, 
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000), 
                    lastDate: DateTime(2050),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : 'Chọn ngày hết hạn',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 15, fontWeight: FontWeight.w500, 
                          color: _selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary
                        ),
                      ),
                      const Icon(Icons.calendar_month, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text('Hình ảnh giấy tờ (1 mặt)', style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            
            if (_imagePath != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: _imagePath!.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: _imagePath!,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            )
                          : Image.file(File(_imagePath!), width: double.infinity, fit: BoxFit.contain),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, color: AppColors.textPrimary),
                            label: Text('Chụp lại', style: GoogleFonts.beVietnamPro(color: AppColors.textPrimary)),
                          ),
                        ),
                        Container(width: 1, height: 20, color: AppColors.divider),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => setState(() => _imagePath = null),
                            icon: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                            label: Text('Xoá', style: GoogleFonts.beVietnamPro(color: const Color(0xFFD32F2F))),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                      label: Text('Chụp ảnh', style: GoogleFonts.beVietnamPro(color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: AppColors.primary),
                      label: Text('Thư viện', style: GoogleFonts.beVietnamPro(color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
