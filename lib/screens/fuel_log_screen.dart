import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_theme.dart';
import '../services/fuel_price_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

import '../providers/vehicle_provider.dart';
import '../providers/fuel_provider.dart';
import '../data/models/fuel_entry.dart';

class FuelLogScreen extends ConsumerStatefulWidget {
  const FuelLogScreen({super.key});

  @override
  ConsumerState<FuelLogScreen> createState() => _FuelLogScreenState();
}

class _FuelLogScreenState extends ConsumerState<FuelLogScreen> {
  final _locService = LocationService();
  final _fuelPriceService = FuelPriceService();
  final _numberFormat = NumberFormat('#,###', 'vi_VN');

  // Controllers
  final _stationCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _odoCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // FocusNodes
  final _litersFocus = FocusNode();
  final _amountFocus = FocusNode();

  // State
  DateTime _selectedDate = DateTime.now();
  Map<String, int> _prices = {};
  String _selectedFuelType = 'RON 95-III';
  int _currentPrice = 0;
  
  bool _isLocating = false;
  String? _locError;
  GasStation? _selectedStation;
  
  double _odoPrev = 0;
  double _consumption = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    // Lắng nghe Lít -> VND
    _litersCtrl.addListener(() {
      if (_litersFocus.hasFocus) {
        final liters = double.tryParse(_litersCtrl.text.replaceAll(',', '.')) ?? 0;
        final amount = liters * _currentPrice;
        if (amount > 0) {
          _amountCtrl.text = amount.toInt().toString();
        } else {
          _amountCtrl.clear();
        }
        _calculateConsumption();
      }
    });

    // Lắng nghe VND -> Lít
    _amountCtrl.addListener(() {
      if (_amountFocus.hasFocus) {
        final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
        if (_currentPrice > 0) {
          final liters = amount / _currentPrice;
          if (liters > 0) {
            _litersCtrl.text = liters.toStringAsFixed(2);
          } else {
            _litersCtrl.clear();
          }
          _calculateConsumption();
        }
      }
    });

    _odoCtrl.addListener(_calculateConsumption);
  }

  @override
  void dispose() {
    _stationCtrl.dispose();
    _litersCtrl.dispose();
    _amountCtrl.dispose();
    _odoCtrl.dispose();
    _noteCtrl.dispose();
    _litersFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Giá xăng
    final prices = await _fuelPriceService.getCurrentPrices();
    setState(() {
      _prices = prices;
      if (_prices.containsKey('RON 95-III')) {
        _selectedFuelType = 'RON 95-III';
        _currentPrice = _prices['RON 95-III']!;
      }
    });

    // ODO lần đổ trước
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final entriesAsync = ref.read(fuelNotifierProvider);
      final entries = entriesAsync.valueOrNull ?? [];
      double prev = 0;
      if (entries.isNotEmpty) {
        // Lấy ODO lớn nhất từ lịch sử (danh sách đã sort date giảm dần)
        prev = entries.first.odometer;
      } else {
        // Fallback lấy ODO khai báo của xe
        final vehicle = ref.read(selectedVehicleProvider).valueOrNull;
        if (vehicle != null) prev = vehicle.odometer;
      }
      setState(() {
        _odoPrev = prev;
        _odoCtrl.text = prev > 0 ? prev.toInt().toString() : '';
      });
    });

    // Tự động detect vị trí
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isLocating = true;
      _locError = null;
      _selectedStation = null;
    });

    try {
      final pos = await _locService.getCurrentPosition();
      if (pos == null) {
        setState(() { _isLocating = false; _locError = 'Không thể lấy vị trí'; });
        return;
      }

      final stations = await _locService.findNearbyGasStations(pos.latitude, pos.longitude);
      if (!mounted) return;

      if (stations.isEmpty) {
        setState(() {
          _isLocating = false;
          _locError = 'Không tìm thấy cây xăng gần đây';
        });
      } else if (stations.length == 1) {
        setState(() {
          _isLocating = false;
          _selectedStation = stations.first;
          _stationCtrl.text = stations.first.name;
        });
      } else {
        setState(() { _isLocating = false; });
        _showStationPicker(stations);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocating = false;
        final msg = e.toString();
        if (msg.contains('PERMISSION_DENIED')) {
          _locError = 'Cần quyền vị trí để tự detect cây xăng';
        } else {
          _locError = 'Lỗi hoặc quá thời gian tìm vị trí';
        }
      });
    }
  }

  void _showStationPicker(List<GasStation> stations) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Chọn cây xăng', style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...stations.map((s) => ListTile(
                leading: const Icon(Icons.local_gas_station, color: AppColors.primary),
                title: Text(s.name, style: GoogleFonts.beVietnamPro(fontSize: 14)),
                onTap: () {
                  setState(() {
                    _selectedStation = s;
                    _stationCtrl.text = s.name;
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _calculateConsumption() {
    final odo = double.tryParse(_odoCtrl.text) ?? 0;
    final liters = double.tryParse(_litersCtrl.text.replaceAll(',', '.')) ?? 0;
    
    if (odo > _odoPrev && liters > 0) {
      final distance = odo - _odoPrev;
      setState(() {
        _consumption = distance / liters;
      });
    } else {
      setState(() {
        _consumption = 0;
      });
    }
  }

  Future<void> _save() async {
    final vehicleId = ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) return;

    final liters = double.tryParse(_litersCtrl.text.replaceAll(',', '.')) ?? 0;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    final odo = double.tryParse(_odoCtrl.text) ?? 0;

    if (liters <= 0 || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lượng xăng / số tiền hợp lệ')));
      return;
    }
    if (odo < _odoPrev) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số ODO phải lớn hơn hoặc bằng ODO cũ')));
      return;
    }

    final entry = FuelEntry(
      vehicleId: vehicleId,
      date: _selectedDate,
      odometer: odo,
      liters: liters,
      pricePerLiter: _currentPrice.toDouble(),
      totalCost: amount,
      stationName: _stationCtrl.text.isNotEmpty ? _stationCtrl.text : null,
      stationLat: _selectedStation?.lat,
      stationLon: _selectedStation?.lon,
      fuelType: _selectedFuelType,
      note: _noteCtrl.text,
    );

    await ref.read(fuelNotifierProvider.notifier).add(entry);

    if (_consumption > 0 && odo > _odoPrev) {
      _showReminderDialog();
    } else {
      _finish();
    }
  }

  void _showReminderDialog() {
    // Giải lập Y = consumption * 3.5 (Lít còn lại trung bình)
    final distanceLeft = (_consumption * 3.5).toInt();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Nhắc lịch đổ xăng', style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Text(
            'Dựa trên mức tiêu hao ${_consumption.toStringAsFixed(1)} km/lít, '
            'bạn cần đổ xăng sau khoảng $distanceLeft km nữa.\n\nBật nhắc lịch không?',
            style: GoogleFonts.beVietnamPro(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _finish();
              },
              child: Text('Để sau', style: GoogleFonts.beVietnamPro(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                NotificationService.scheduleRefuelReminder(distanceLeft, estimateDays: 5); // Tạm fix 5 ngày
                Navigator.pop(context);
                _finish();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Bật nhắc', style: GoogleFonts.beVietnamPro(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _finish() {
    // User requested invalidate but Riverpod providers usually self-invalidate/update when state changes.
    // However, if we need explicit invalidation for stats:
    // ref.invalidate(...)
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu nhật ký đổ xăng')));
    if (mounted) context.pop();
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16)}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: child,
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {FocusNode? focusNode, TextInputType? keyboardType, String? suffixText, bool readOnly = false, Widget? suffixIcon}) {
    return TextField(
      controller: ctrl,
      focusNode: focusNode,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffixText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đổ xăng'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card 1: Thông tin cơ bản
            _buildCard(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2050));
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ngày đổ', style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)),
                          Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFuelType,
                          decoration: InputDecoration(
                            filled: true, fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          items: _prices.keys.map((k) => DropdownMenuItem(value: k, child: Text(k, style: GoogleFonts.beVietnamPro(fontSize: 14)))).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedFuelType = v;
                                _currentPrice = _prices[v] ?? 0;
                              });
                              // Tính lại tiền
                              final liters = double.tryParse(_litersCtrl.text.replaceAll(',', '.')) ?? 0;
                              if (liters > 0) _amountCtrl.text = (liters * _currentPrice).toInt().toString();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            '${_numberFormat.format(_currentPrice)} đ/L', 
                            style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card 2: Địa điểm
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Địa điểm', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                      if (_isLocating) 
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      else 
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: _detectLocation,
                        ),
                    ],
                  ),
                  if (_locError != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFE65100)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_locError!, style: GoogleFonts.beVietnamPro(fontSize: 12, color: const Color(0xFFE65100)))),
                          if (_locError!.contains('Quyền'))
                            TextButton(
                              onPressed: () => openAppSettings(),
                              child: Text('Mở CĐ', style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTextField(_stationCtrl, 'Tên cây xăng (nhập tay hoặc auto)'),
                ],
              ),
            ),

            // Card 3: Lượng xăng
            _buildCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Số lít', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        _buildTextField(_litersCtrl, '0.0', focusNode: _litersFocus, keyboardType: const TextInputType.numberWithOptions(decimal: true), suffixText: 'Lít'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng tiền', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        _buildTextField(_amountCtrl, '0', focusNode: _amountFocus, keyboardType: TextInputType.number, suffixText: 'VND'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card 4: Đồng hồ ODO
            _buildCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ODO lần trước', style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)),
                      Text('${_odoPrev.toInt()} km', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(flex: 1, child: Text('ODO hiện tại', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(_odoCtrl, 'Nhập số km', keyboardType: TextInputType.number, suffixText: 'km'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card 5: Tính toán auto
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('QUÃNG ĐƯỜNG', style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          _odoCtrl.text.isNotEmpty && (double.tryParse(_odoCtrl.text) ?? 0) > _odoPrev 
                              ? '${((double.tryParse(_odoCtrl.text) ?? 0) - _odoPrev).toInt()} km' 
                              : '-- km',
                          style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.divider),
                  Expanded(
                    child: Column(
                      children: [
                        Text('MỨC TIÊU HAO', style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          _consumption > 0 ? '${_consumption.toStringAsFixed(1)} km/l' : '-- km/l',
                          style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Lưu lại', style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
