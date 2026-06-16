import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFmt = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFmt = NumberFormat('#,###', 'vi_VN');

  static final NumberFormat _decimalFmt = NumberFormat('#,###.##', 'vi_VN');

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFmt = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFmt = DateFormat('MM/yyyy');
  static final DateFormat _dbFmt = DateFormat('yyyy-MM-dd');

  /// Format VND currency: 105000 → "105.000 ₫"
  static String currency(num? amount) {
    if (amount == null) return '0 ₫';
    return _currencyFmt.format(amount);
  }

  /// Format number with thousand separators: 12450 → "12.450"
  static String number(num? value) {
    if (value == null) return '0';
    return _numberFmt.format(value);
  }

  /// Format decimal: 4.823 → "4,82"
  static String decimal(num? value, {int decimals = 2}) {
    if (value == null) return '0';
    final fmt = NumberFormat('#,###.${'#' * decimals}', 'vi_VN');
    return fmt.format(value);
  }

  /// Format km: 12450.5 → "12.450 km"
  static String km(num? value) {
    if (value == null) return '0 km';
    return '${_numberFmt.format(value)} km';
  }

  /// Format liters: 5.0 → "5,0 L"
  static String liters(num? value) {
    if (value == null) return '0 L';
    return '${_decimalFmt.format(value)} L';
  }

  /// Format consumption: 4.5 → "4,50 L/100km"
  static String consumption(num? value) {
    if (value == null) return '—';
    return '${NumberFormat('0.00', 'vi_VN').format(value)} L/100km';
  }

  /// Format date: DateTime → "26/05/2025"
  static String date(DateTime? dt) {
    if (dt == null) return '—';
    return _dateFmt.format(dt);
  }

  /// Format datetime: DateTime → "26/05/2025 09:30"
  static String dateTime(DateTime? dt) {
    if (dt == null) return '—';
    return _dateTimeFmt.format(dt);
  }

  /// Format month/year: DateTime → "05/2025"
  static String monthYear(DateTime? dt) {
    if (dt == null) return '—';
    return _monthYearFmt.format(dt);
  }

  /// Format for DB storage: DateTime → "2025-05-26"
  static String toDbDate(DateTime dt) => _dbFmt.format(dt);

  /// Parse from DB: "2025-05-26" → DateTime
  static DateTime? fromDbDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return _dbFmt.parse(s);
    } catch (_) {
      return null;
    }
  }

  /// Relative time: "3 ngày trước", "hôm nay", "2 ngày nữa"
  static String relativeDate(DateTime? dt) {
    if (dt == null) return '—';
    final now = DateTime.now();
    final diff = dt.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Ngày mai';
    if (diff == -1) return 'Hôm qua';
    if (diff > 0) return '$diff ngày nữa';
    return '${-diff} ngày trước';
  }

  /// Calculate fuel consumption L/100km
  static double? calcConsumption({
    required double liters,
    required double distanceKm,
  }) {
    if (distanceKm <= 0) return null;
    return (liters / distanceKm) * 100;
  }
}
