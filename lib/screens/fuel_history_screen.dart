import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/fuel_provider.dart';
import '../data/models/fuel_entry.dart';

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
        Container(color: AppColors.surface,
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
              if (records.isEmpty) {
                return const Center(child: Text('Chưa có lịch sử đổ xăng'));
              }
              
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _FuelRecordTile(record: records[i]),
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
            context.go('/expense');
          } else if (i == 3) {
            context.go('/profile');
          }
        },
        onAddTap: () => context.push('/fuel-log'),
      ),
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

    return Container(color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        // Icon
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
          child: const Icon(Icons.local_gas_station_outlined, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),

        // Nội dung trái
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dateFormat.format(record.date), style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(record.stationName ?? 'Cây xăng', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
      ]),
    );
  }
}
