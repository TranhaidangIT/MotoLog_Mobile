import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/maintenance_item_provider.dart';
import '../providers/vehicle_provider.dart';

enum SetupChoice { justDone, neverDone, custom }

class MaintenanceSetupScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;
  const MaintenanceSetupScreen({super.key, this.isOnboarding = true});

  @override
  ConsumerState<MaintenanceSetupScreen> createState() => _MaintenanceSetupScreenState();
}

class _MaintenanceSetupScreenState extends ConsumerState<MaintenanceSetupScreen> {
  final Map<String, SetupChoice> _choices = {};
  final Map<String, TextEditingController> _customCtrls = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(maintenanceItemNotifierProvider);
      for (final item in items) {
        _choices[item.id] = SetupChoice.justDone;
        _customCtrls[item.id] = TextEditingController();
      }
      setState(() {});
    });
  }

  Future<void> _save() async {
    final vehicleAsync = ref.read(selectedVehicleProvider);
    final currentOdo = vehicleAsync.valueOrNull?.odometer.toInt() ?? 0;
    final items = ref.read(maintenanceItemNotifierProvider);
    final notifier = ref.read(maintenanceItemNotifierProvider.notifier);

    for (final item in items) {
      final choice = _choices[item.id] ?? SetupChoice.justDone;
      int newLastDoneOdo;
      switch (choice) {
        case SetupChoice.justDone:
          newLastDoneOdo = currentOdo;
          break;
        case SetupChoice.neverDone:
          newLastDoneOdo = currentOdo - item.intervalKm;
          break;
        case SetupChoice.custom:
          final parsed = int.tryParse(_customCtrls[item.id]?.text ?? '');
          newLastDoneOdo = parsed ?? currentOdo;
          break;
      }
      await notifier.markDone(item.id, newLastDoneOdo);
    }

    if (!mounted) return;
    if (widget.isOnboarding) {
      context.go('/home');
    } else {
      context.pop();
    }
  }

  Widget _choiceChip(String itemId, SetupChoice value, String label) {
    final active = _choices[itemId] == value;
    return GestureDetector(
      onTap: () => setState(() => _choices[itemId] = value),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label, style: GoogleFonts.beVietnamPro(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: active ? Colors.white : AppColors.textSecondary,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(maintenanceItemNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết lập mốc bảo dưỡng'),
        automaticallyImplyLeading: !widget.isOnboarding,
        actions: widget.isOnboarding
          ? [TextButton(onPressed: _save, child: const Text('Bỏ qua'))]
          : null,
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Text(
            'Cho biết lần gần nhất bạn thay từng hạng mục, để app tính đúng số km còn lại',
            style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: items.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final item = items[i];
              final choice = _choices[item.id] ?? SetupChoice.justDone;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
                      child: Icon(item.icon, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.name, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600))),
                  ]),
                  const SizedBox(height: 10),
                  Wrap(spacing: 0, runSpacing: 6, children: [
                    _choiceChip(item.id, SetupChoice.justDone, 'Vừa thay'),
                    _choiceChip(item.id, SetupChoice.neverDone, 'Chưa từng / Không nhớ'),
                    _choiceChip(item.id, SetupChoice.custom, 'Nhập ODO'),
                  ]),
                  if (choice == SetupChoice.custom) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customCtrls[item.id],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Nhập số km lúc thay',
                        hintStyle: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
                      ),
                    ),
                  ],
                ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Hoàn tất', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ),
      ]),
    );
  }
}
