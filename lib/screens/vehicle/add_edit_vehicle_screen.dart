import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../data/models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../maintenance_setup_screen.dart';

class AddEditVehicleScreen extends ConsumerStatefulWidget {
  final String? vehicleId;

  const AddEditVehicleScreen({super.key, this.vehicleId});

  @override
  ConsumerState<AddEditVehicleScreen> createState() =>
      _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends ConsumerState<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();

  String _selectedFuelType = AppConstants.fuelGasoline;
  String _selectedVehicleType = 'Xe tay ga';
  String _selectedColor = '#003087';
  String? _selectedImagePath;

  final List<String> _vehicleTypes = ['Xe tay ga', 'Xe số', 'Xe côn tay / PKL'];
  bool _isLoading = false;
  bool _isEdit = false;
  Vehicle? _existingVehicle;

  final List<String> _colorOptions = [
    '#003087', // PayPal Blue
    '#6D28D9', // Deep Purple
    '#0E7490', // Teal
    '#065F46', // Deep Green
    '#92400E', // Bronze
    '#7C3AED', // Bright Purple
    '#FFD166', // Yellow
    '#FF6B6B', // Coral
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.vehicleId != null;
    if (_isEdit) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final vehicles = await ref.read(vehicleNotifierProvider.future);
    _existingVehicle =
        vehicles.where((v) => v.id == widget.vehicleId).firstOrNull;
    if (_existingVehicle != null && mounted) {
      final v = _existingVehicle!;
      _nameCtrl.text = v.name;
      _brandCtrl.text = v.brand;
      _modelCtrl.text = v.model;
      _plateCtrl.text = v.plateNumber;
      _yearCtrl.text = v.year.toString();
      _odometerCtrl.text = v.odometer.toStringAsFixed(0);
      setState(() {
        _selectedFuelType = v.fuelType;
        _selectedColor = v.color;
        _selectedImagePath = v.imageUrl;
        _selectedVehicleType = v.engineCapacity ?? 'Xe tay ga';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _yearCtrl.dispose();
    _odometerCtrl.dispose();
    super.dispose();
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userId = ref.read(currentUserProvider)?.uid;
    final vehicle = Vehicle(
      id: _existingVehicle?.id,
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      plateNumber: _plateCtrl.text.trim().toUpperCase(),
      year: int.parse(_yearCtrl.text.trim()),
      odometer: double.parse(_odometerCtrl.text.trim()),
      fuelType: _selectedFuelType,
      color: _selectedColor,
      imageUrl: _selectedImagePath,
      engineCapacity: _selectedVehicleType,
      userId: userId,
    );

    if (_isEdit) {
      await ref.read(vehicleNotifierProvider.notifier).updateEntry(vehicle);
    } else {
      await ref.read(vehicleNotifierProvider.notifier).add(vehicle);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Đã cập nhật xe' : 'Đã thêm xe thành công'),
        backgroundColor: AppColors.primary,
      ),
    );
    
    if (_isEdit) {
      context.pop();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MaintenanceSetupScreen(isOnboarding: true)),
      );
    }
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll("#", "")}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Chỉnh sửa xe' : 'Thêm xe mới'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Lưu'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Type
              _buildLabel('Kiểu dáng xe *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.two_wheeler_outlined),
                ),
                items: _vehicleTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedVehicleType = v!),
              ),
              const SizedBox(height: 16),

              // Color picker
              Text(
                'Màu xe',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _colorOptions.map((hex) {
                  final isSelected = _selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _hexToColor(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color:
                                        _hexToColor(hex).withValues(alpha: 0.5),
                                    blurRadius: 8)
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Form fields
              _buildLabel('Tên xe *'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    AppValidators.required(v, fieldName: 'Tên xe'),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'VD: Xe đi làm',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Hãng xe *'),
                        TextFormField(
                          controller: _brandCtrl,
                          validator: (v) =>
                              AppValidators.required(v, fieldName: 'Hãng xe'),
                          decoration: const InputDecoration(
                              hintText: 'Honda, Yamaha...'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Dòng xe *'),
                        TextFormField(
                          controller: _modelCtrl,
                          validator: (v) =>
                              AppValidators.required(v, fieldName: 'Dòng xe'),
                          decoration: const InputDecoration(
                              hintText: 'Wave, Exciter...'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Biển số xe *'),
              TextFormField(
                controller: _plateCtrl,
                textCapitalization: TextCapitalization.characters,
                validator: AppValidators.plateNumber,
                decoration: const InputDecoration(
                  hintText: '51A-123.45',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Năm SX *'),
                        TextFormField(
                          controller: _yearCtrl,
                          keyboardType: TextInputType.number,
                          validator: AppValidators.vehicleYear,
                          decoration: const InputDecoration(hintText: '2020'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Odometer (km) *'),
                        TextFormField(
                          controller: _odometerCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              AppValidators.required(v, fieldName: 'Odometer'),
                          decoration: const InputDecoration(hintText: '12450'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Loại nhiên liệu *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedFuelType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.local_gas_station_outlined),
                ),
                items: AppConstants.fuelTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedFuelType = v!),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEdit ? 'Lưu chỉnh sửa' : 'Lưu xe',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
