  import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:motolog_mobile/theme/app_theme.dart';
import 'package:motolog_mobile/widgets/bottom_nav_bar.dart';
import 'package:motolog_mobile/features/fuel/providers/fuel_provider.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';
import 'package:motolog_mobile/data/models/fuel_entry.dart';

/// Màn hình Lịch sử Đổ xăng
/// Hiển thị toàn bộ lịch sử các lần đổ xăng có thể lọc theo tháng và thống kê tổng quan.
class FuelHistoryScreen extends ConsumerStatefulWidget {
  const FuelHistoryScreen({super.key});

  @override
  ConsumerState<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends ConsumerState<FuelHistoryScreen> {
  int _filterIndex = 0;
  static const _filters = ['Tất cả', 'Tháng này', 'Tháng trước', 'Tuỳ chọn'];

  @override
  Widget build(BuildContext context) {
    final fuelListAsync = ref.watch(fuelListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đổ xăng'),
        leading: BackButton(onPressed: () => context.go('/home')),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.filter_list))],
      ),
      body: Column(children: [
        // Filter chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (i) => GestureDetector(
                onTap: () => setState(() => _filterIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: _filterIndex == i ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _filterIndex == i ? AppColors.primary : AppColors.divider),
                  ),
                  child: Text(_filters[i], style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _filterIndex == i ? Colors.white : AppColors.textSecondary,
                  )),
                ),
              )),
            ),
          ),
        ),

        // Body
        Expanded(
          child: fuelListAsync.when(
            data: (records) {
              // Áp dụng bộ lọc
              final now = DateTime.now();
              Iterable<FuelEntry> filtered = records;
              if (_filterIndex == 1) {
                // Tháng này
                filtered = records.where((r) => r.date.year == now.year && r.date.month == now.month);
              } else if (_filterIndex == 2) {
                // Tháng trước
                int prevMonth = now.month - 1;
                int prevYear = now.year;
                if (prevMonth == 0) {
                  prevMonth = 12;
                  prevYear--;
                }
                filtered = records.where((r) => r.date.year == prevYear && r.date.month == prevMonth);
              }
              // Tùy chọn (index 3) hiện tại để tạm giống 'Tất cả'

              final displayList = filtered.toList();

              if (displayList.isEmpty) {
                return const Center(child: Text('Không có dữ liệu'));
              }
              
              // Calculate stats
              double totalAmount = 0;
              double totalLiters = 0;
              for (var r in displayList) {
                totalAmount += r.totalCost;
                totalLiters += r.liters;
              }

              // Giả định quãng đường là từ odo max - odo min
              double distance = 0;
              if (displayList.length > 1) {
                displayList.sort((a, b) => b.odometer.compareTo(a.odometer));
                distance = displayList.first.odometer - displayList.last.odometer;
              }

              double avgConsumption = totalLiters > 0 ? (distance / totalLiters) : 0.0;

              return Column(
                children: [
                  // Stats summary
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(children: [
                      _StatCell(label: 'Tổng tiền', value: '${NumberFormat('#,###').format(totalAmount)} đ'),
                      Container(width: 1, height: 50, color: AppColors.divider),
                      _StatCell(label: 'Tổng lít', value: '${totalLiters.toStringAsFixed(2)} lít'),
                      Container(width: 1, height: 50, color: AppColors.divider),
                      _StatCell(label: 'Tiêu hao TB', value: '${avgConsumption.toStringAsFixed(1)} km/lít'),
                    ]),
                  ),

                  // List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 1),
                      itemBuilder: (_, i) => _FuelRecordTile(record: displayList[i]),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Lỗi: $e')),
          ),
        ),
      ]),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: 1, 
        onTap: (i) {
          if (i == 0) {
            context.go('/home');
          } else if (i == 2) {
            context.go('/profile');
          }
        },
        onAddTap: () {
          if (ref.read(selectedVehicleIdProvider) == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm xe trước khi sử dụng')));
            context.push('/add-vehicle');
          } else {
            context.push('/fuel-log');
          }
        },
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _FuelRecordTile extends StatelessWidget {
  final FuelEntry record;
  const _FuelRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat('#,###');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        // Icon
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
          child: Icon(Icons.local_gas_station_outlined, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),

        // Nội dung trái
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dateFormat.format(record.date), style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(record.stationName ?? 'Cây xăng', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            if (record.stationAddress != null && record.stationAddress!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                record.stationAddress!,
                style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 2),
            Text('${record.liters.toStringAsFixed(2)} lít · ODO: ${record.odometer.toInt()}', style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ),

        // Nội dung phải
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${currencyFormat.format(record.totalCost)} đ', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.greenChip,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('58.0 km/lít', style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ]),
      ]),
    );
  }
}
