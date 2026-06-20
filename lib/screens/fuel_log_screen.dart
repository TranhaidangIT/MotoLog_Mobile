import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/fuel_provider.dart';
import '../providers/vehicle_provider.dart';
import '../data/models/fuel_entry.dart';

class FuelLogScreen extends ConsumerStatefulWidget {
  const FuelLogScreen({super.key});

  @override
  ConsumerState<FuelLogScreen> createState() => _FuelLogScreenState();
}

class _FuelLogScreenState extends ConsumerState<FuelLogScreen> {
  final _dateCtrl    = TextEditingController();
  final _placeCtrl   = TextEditingController();
  final _amountCtrl  = TextEditingController();
  final _litersCtrl  = TextEditingController();
  final _odoCtrl     = TextEditingController();
  final _noteCtrl    = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _placeCtrl.dispose();
    _amountCtrl.dispose();
    _litersCtrl.dispose();
    _odoCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    final vehicleId = ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn xe trước')));
      return;
    }

    final amountStr = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(amountStr) ?? 0.0;
    
    final litersStr = _litersCtrl.text.replaceAll(',', '.');
    final liters = double.tryParse(litersStr) ?? 0.0;
    
    final odoStr = _odoCtrl.text.replaceAll('.', '').replaceAll(',', '');
    final odo = double.tryParse(odoStr) ?? 0.0;

    if (amount <= 0 || liters <= 0 || odo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ và hợp lệ')));
      return;
    }

    final entry = FuelEntry(
      id: const Uuid().v4(),
      vehicleId: vehicleId,
      date: _selectedDate,
      totalCost: amount,
      liters: liters,
      pricePerLiter: liters > 0 ? amount / liters : 0,
      odometer: odo,
      stationName: _placeCtrl.text.isEmpty ? 'Cây xăng' : _placeCtrl.text,
      note: _noteCtrl.text,
    );

    try {
      await ref.read(fuelNotifierProvider.notifier).add(entry);
      if (mounted) {
        context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tự động tính toán mức tiêu hao / quãng đường nếu cần thiết (optional enhancement)
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đổ xăng'),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildLabel('Ngày đổ'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _dateCtrl.text = DateFormat('dd/MM/yyyy').format(date);
                });
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: _dateCtrl,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _buildLabel('Địa điểm'),
          const SizedBox(height: 6),
          TextField(
            controller: _placeCtrl,
            decoration: const InputDecoration(
              hintText: 'Nhập địa điểm cây xăng',
              suffixIcon: Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('Số tiền (VND)'),
              const SizedBox(height: 6),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('Số lít'),
              const SizedBox(height: 6),
              TextField(
                controller: _litersCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ])),
          ]),
          const SizedBox(height: 16),

          _buildLabel('Chỉ số ODO (km)'),
          const SizedBox(height: 6),
          TextField(
            controller: _odoCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          _buildLabel('Ghi chú (không bắt buộc)'),
          const SizedBox(height: 6),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Nhập ghi chú...'),
          ),
          const SizedBox(height: 20),

          // Calculation summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenChip,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Text('Tính toán', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _CalcItem(label: 'Quãng đường', value: '— km')),
                Container(width: 1, height: 40, color: AppColors.accent.withValues(alpha: 0.3)),
                Expanded(child: _CalcItem(label: 'Mức tiêu hao', value: '— km/lít')),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _save,
            child: const Text('Lưu lại'),
          ),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: -1, 
        onTap: (i) {
          if (i == 0) {
            context.go('/home');
          } else if (i == 1) {
            context.go('/fuel-history');
          } else if (i == 2) {
            context.go('/expense');
          } else if (i == 3) {
            context.go('/profile');
          }
        },
        onAddTap: () {},
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary));
  }
}

class _CalcItem extends StatelessWidget {
  final String label;
  final String value;
  const _CalcItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
    ]);
  }
}
