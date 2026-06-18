class AppValidators {
  AppValidators._();

  /// Kiểm tra bỏ trống
  static String? required(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Validate mật khẩu (min 6 ký tự)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  /// Validate xác nhận mật khẩu
  static String? Function(String?) confirmPassword(String? original) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng nhập lại mật khẩu';
      }
      if (value != original) {
        return 'Mật khẩu không khớp';
      }
      return null;
    };
  }

  /// Validate số dương
  static String? positiveNumber(String? value, {String fieldName = 'Giá trị'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    final num = double.tryParse(value.replaceAll(',', '.'));
    if (num == null) {
      return '$fieldName phải là số hợp lệ';
    }
    if (num <= 0) {
      return '$fieldName phải lớn hơn 0';
    }
    return null;
  }

  /// Validate odometer (phải >= giá trị trước)
  static String? Function(String?) odometer({
    required double? previousKm,
    String fieldName = 'Số km',
  }) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName không được để trống';
      }
      final km = double.tryParse(value.replaceAll(',', '').replaceAll('.', ''));
      if (km == null || km < 0) {
        return '$fieldName phải là số hợp lệ';
      }
      if (previousKm != null && km <= previousKm) {
        return '$fieldName phải lớn hơn lần trước (${previousKm.toStringAsFixed(0)} km)';
      }
      return null;
    };
  }

  /// Validate số lít (0.1 - 200)
  static String? liters(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số lít không được để trống';
    }
    final liters = double.tryParse(value.replaceAll(',', '.'));
    if (liters == null || liters <= 0) {
      return 'Số lít phải lớn hơn 0';
    }
    if (liters > 200) {
      return 'Số lít không hợp lệ (tối đa 200L)';
    }
    return null;
  }

  /// Validate năm sản xuất xe
  static String? vehicleYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Năm sản xuất không được để trống';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Năm sản xuất phải là số nguyên';
    }
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Năm sản xuất không hợp lệ (1900 - ${currentYear + 1})';
    }
    return null;
  }

  /// Validate biển số xe
  static String? plateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Biển số xe không được để trống';
    }
    if (value.trim().length < 5) {
      return 'Biển số xe không hợp lệ';
    }
    return null;
  }

  /// Combine validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
