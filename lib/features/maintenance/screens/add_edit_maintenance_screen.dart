import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motolog_mobile/core/constants/app_colors.dart';
import 'package:motolog_mobile/core/constants/app_constants.dart';
import 'package:motolog_mobile/core/utils/formatters.dart';
import 'package:motolog_mobile/core/utils/validators.dart';
import 'package:motolog_mobile/data/models/maintenance_entry.dart';
import 'package:motolog_mobile/features/maintenance/providers/maintenance_provider.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';

/// Màn hình Thêm / Chỉnh sửa Bảo dưỡng
/// Dùng chung cho việc ghi nhận một lần bảo dưỡng hoặc sửa lịch sử cũ.
class AddEditMaintenanceScreen extends ConsumerStatefulWidget {
  final String? maintenanceId;

  const AddEditMaintenanceScreen({super.key, this.maintenanceId});

  @override
  ConsumerState<AddEditMaintenanceScreen> createState() =>
      _AddEditMaintenanceScreenState();
}

class _AddEditMaintenanceScreenState
    extends ConsumerState<AddEditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _garageCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  MaintenanceType _selectedType = MaintenanceType.routine;
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextDueDate;
  bool _isLoading = false;
  bool _isEdit = false;

  // Quick title suggestions per type
  Map<MaintenanceType, List<String>> get _suggestions => {
        MaintenanceType.routine: [
          'Thay nhớt',
          'Vệ sinh bộ chế hòa khí',
          'Kiểm tra phanh',
          'Vệ sinh bugi',
          'Bơm lốp xe',
        ],
        MaintenanceType.repair: [
          'Sửa phanh',
          'Sửa đèn',
          'Thay ắc-quy',
          'Sửa điện',
          'Sửa động cơ',
        ],
        MaintenanceType.parts: [
          'Thay lốp xe',
          'Thay má phanh',
          'Thay bugi',
          'Thay dây côn',
          'Thay xích đĩa',
        ],
      };

  @override
  void initState() {
    super.initState();
    _isEdit = widget.maintenanceId != null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _odometerCtrl.dispose();
    _costCtrl.dispose();
    _garageCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({bool isNextDue = false}) async {
    final initial = isNextDue
        ? (_nextDueDate ?? DateTime.now().add(const Duration(days: 90)))
        : _selectedDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isNextDue ? DateTime.now() : DateTime(2000),
      lastDate: isNextDue
          ? DateTime.now().add(const Duration(days: 365 * 3))
          : DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (date != null) {
      setState(() {
        if (isNextDue) {
          _nextDueDate = date;
        } else {
          _selectedDate = date;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vehicleId = ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) return;

    setState(() => _isLoading = true);

    final entry = MaintenanceEntry(
      vehicleId: vehicleId,
      type: _selectedType,
      title: _titleCtrl.text.trim(),
      date: _selectedDate,
      odometer: double.parse(_odometerCtrl.text.replaceAll(',', '')),
      cost: double.tryParse(
              _costCtrl.text.replaceAll(',', '').replaceAll('.', '')) ??
          0,
      garageName:
          _garageCtrl.text.trim().isEmpty ? null : _garageCtrl.text.trim(),
      nextDueDate: _nextDueDate,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (_isEdit) {
      await ref.read(maintenanceNotifierProvider.notifier).updateEntry(entry);
    } else {
      await ref.read(maintenanceNotifierProvider.notifier).add(entry);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Đã cập nhật' : 'Đã thêm bảo dưỡng'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Chỉnh sửa bảo dưỡng' : 'Thêm bảo dưỡng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              _buildLabel('Loại bảo dưỡng *'),
              Row(
                children: MaintenanceType.values.map((t) {
                  final isSelected = _selectedType == t;
                  Color color;
                  switch (t) {
                    case MaintenanceType.routine:
                      color = AppColors.success;
                      break;
                    case MaintenanceType.repair:
                      color = AppColors.error;
                      break;
                    case MaintenanceType.parts:
                      color = AppColors.secondary;
                      break;
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedType = t;
                          _titleCtrl.clear();
                        }),
                        child: AnimatedContainer(
                          duration: AppConstants.animFast,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                t == MaintenanceType.routine
                                    ? Icons.autorenew_rounded
                                    : t == MaintenanceType.repair
                                        ? Icons.handyman_rounded
                                        : Icons.settings_rounded,
                                color: isSelected ? color : null,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t == MaintenanceType.routine
                                    ? 'Định kỳ'
                                    : t == MaintenanceType.repair
                                        ? 'Sửa chữa'
                                        : 'Phụ tùng',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected ? color : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Quick suggestions
              _buildLabel('Gợi ý nhanh'),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: (_suggestions[_selectedType] ?? []).map((s) {
                  return ActionChip(
                    label: Text(s),
                    onPressed: () => setState(() => _titleCtrl.text = s),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Title
              _buildLabel('Tên công việc *'),
              TextFormField(
                controller: _titleCtrl,
                validator: (v) =>
                    AppValidators.required(v, fieldName: 'Tên công việc'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.build_outlined),
                  hintText: 'VD: Thay nhớt máy',
                ),
              ),
              const SizedBox(height: 16),

              // Date
              _buildLabel('Ngày thực hiện *'),
              InkWell(
                onTap: () => _pickDate(),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(AppFormatters.date(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Odometer (km) *'),
                        TextFormField(
                          controller: _odometerCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.required(v, fieldName: 'Km'),
                          decoration: const InputDecoration(
                            hintText: '12,450',
                            suffixText: 'km',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Chi phí'),
                        TextFormField(
                          controller: _costCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '150,000',
                            suffixText: '₫',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Gara / Nơi sửa (tuỳ chọn)'),
              TextFormField(
                controller: _garageCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.place_outlined),
                  hintText: 'Tiệm sửa xe ABC',
                ),
              ),
              const SizedBox(height: 16),

              // Next due date
              _buildLabel('Hạn bảo dưỡng tiếp theo (tuỳ chọn)'),
              InkWell(
                onTap: () => _pickDate(isNextDue: true),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.event_repeat_rounded),
                    suffixIcon: _nextDueDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setState(() => _nextDueDate = null),
                          )
                        : const Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(
                    _nextDueDate != null
                        ? AppFormatters.date(_nextDueDate)
                        : 'Chọn ngày nhắc nhở',
                    style: _nextDueDate == null
                        ? TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4))
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Ghi chú (tuỳ chọn)'),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.notes_outlined),
                  hintText: 'Ghi chú thêm...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: Text(_isEdit ? 'Cập nhật' : 'Lưu bảo dưỡng'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
