import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../data/models/fuel_entry.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/vehicle_provider.dart';

class AddEditFuelScreen extends ConsumerStatefulWidget {
  final String? fuelId;

  const AddEditFuelScreen({super.key, this.fuelId});

  @override
  ConsumerState<AddEditFuelScreen> createState() => _AddEditFuelScreenState();
}

class _AddEditFuelScreenState extends ConsumerState<AddEditFuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isFull = true;
  bool _isLoading = false;
  bool _isEdit = false;
  FuelEntry? _existing;
  double? _previousOdometer;

  // Auto-calculate total cost
  double get _totalCost {
    final liters = double.tryParse(_litersCtrl.text.replaceAll(',', '.')) ?? 0;
    final price = double.tryParse(
            _priceCtrl.text.replaceAll(',', '').replaceAll('.', '')) ??
        0;
    return liters * price;
  }

  @override
  void initState() {
    super.initState();
    _isEdit = widget.fuelId != null;
    _litersCtrl.addListener(() => setState(() {}));
    _priceCtrl.addListener(() => setState(() {}));
    if (_isEdit) _loadExisting();
    _loadPreviousOdometer();
  }

  Future<void> _loadExisting() async {
    // Load existing fuel entry for edit
  }

  Future<void> _loadPreviousOdometer() async {
    final vehicleId = ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) return;
    final vehicles = await ref.read(vehicleNotifierProvider.future);
    final vehicle = vehicles.where((v) => v.id == vehicleId).firstOrNull;
    if (vehicle != null && mounted) {
      setState(() => _previousOdometer = vehicle.odometer);
    }
  }

  @override
  void dispose() {
    _odometerCtrl.dispose();
    _litersCtrl.dispose();
    _priceCtrl.dispose();
    _stationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vehicleId = ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn xe trước')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final entry = FuelEntry(
      id: _existing?.id,
      vehicleId: vehicleId,
      date: _selectedDate,
      odometer: double.parse(_odometerCtrl.text.replaceAll(',', '')),
      liters: double.parse(_litersCtrl.text.replaceAll(',', '.')),
      pricePerLiter:
          double.parse(_priceCtrl.text.replaceAll(',', '').replaceAll('.', '')),
      stationName:
          _stationCtrl.text.trim().isEmpty ? null : _stationCtrl.text.trim(),
      isFull: _isFull,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (_isEdit) {
      await ref.read(fuelNotifierProvider.notifier).updateEntry(entry);
    } else {
      await ref.read(fuelNotifierProvider.notifier).add(entry);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Đã cập nhật' : 'Đã thêm lần đổ xăng'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Chỉnh sửa' : 'Đổ xăng mới'),
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
              // Total cost display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tổng tiền',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.currency(_totalCost),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date picker
              _buildLabel('Ngày đổ xăng *'),
              InkWell(
                onTap: _pickDate,
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

              // Odometer
              _buildLabel('Số km hiện tại *'),
              TextFormField(
                controller: _odometerCtrl,
                keyboardType: TextInputType.number,
                validator: AppValidators.odometer(
                  previousKm: _previousOdometer,
                  fieldName: 'Odometer',
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.speed_rounded),
                  hintText: _previousOdometer != null
                      ? '> ${_previousOdometer!.toStringAsFixed(0)} km'
                      : '12,450',
                  suffixText: 'km',
                  helperText: _previousOdometer != null
                      ? 'Lần trước: ${AppFormatters.km(_previousOdometer)}'
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Số lít *'),
                        TextFormField(
                          controller: _litersCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: AppValidators.liters,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.local_gas_station_outlined),
                            hintText: '5.0',
                            suffixText: 'L',
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
                        _buildLabel('Giá/lít *'),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.positiveNumber(v, fieldName: 'Giá'),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.attach_money_rounded),
                            hintText: '21,000',
                            suffixText: '₫',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full tank switch
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Đổ đầy bình'),
                    Switch(
                      value: _isFull,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isFull = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Cây xăng (tuỳ chọn)'),
              TextFormField(
                controller: _stationCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.place_outlined),
                  hintText: 'Petrolimex, Shell...',
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
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isEdit ? 'Cập nhật' : 'Lưu lần đổ xăng'),
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
