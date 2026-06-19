import 'package:flutter_test/flutter_test.dart';
import 'package:motolog_mobile/core/utils/validators.dart';

void main() {
  group('AppValidators tests', () {
    // UI-002 & VAL-001/002: Biển số xe Việt Nam
    test('VAL-001: Biển số xe VN hợp lệ (Positive)', () {
      expect(AppValidators.plateNumber('59A1-123.45'), isNull);
      expect(AppValidators.plateNumber('29-B1 12345'), isNull);
      expect(AppValidators.plateNumber('51F-999.99'), isNull);
      expect(AppValidators.plateNumber('43-A 1234'), isNull);
    });

    test('VAL-002: Biển số xe VN không đúng định dạng (Negative)', () {
      expect(
        AppValidators.plateNumber('ABC-DEF'),
        equals('Biển số xe không đúng định dạng VN'),
      );
      expect(
        AppValidators.plateNumber('12345678'),
        equals('Biển số xe không đúng định dạng VN'),
      );
      expect(
        AppValidators.plateNumber('!@#\$%'),
        equals('Biển số xe không đúng định dạng VN'),
      );
      expect(
        AppValidators.plateNumber(''),
        equals('Biển số xe không được để trống'),
      );
      expect(
        AppValidators.plateNumber('   '),
        equals('Biển số xe không được để trống'),
      );
    });

    // VAL-003/VAL-004: Số lít đổ xăng
    test('VAL-003: Số lít đổ xăng hợp lệ', () {
      expect(AppValidators.liters('3'), isNull);
      expect(AppValidators.liters('5.5'), isNull);
      expect(AppValidators.liters('150'), isNull);
    });

    test('VAL-004: Số lít đổ xăng không hợp lệ / phi lý', () {
      expect(AppValidators.liters('0'), equals('Số lít phải lớn hơn 0'));
      expect(AppValidators.liters('-5'), equals('Số lít phải lớn hơn 0'));
      expect(AppValidators.liters('250'), equals('Số lít không hợp lệ (tối đa 200L)'));
      expect(AppValidators.liters('abc'), equals('Số lít phải lớn hơn 0')); // parser returns null -> triggers <= 0 check
    });

    // VAL-005: Bỏ trống các trường bắt buộc
    test('VAL-005: Bỏ trống trường bắt buộc', () {
      expect(AppValidators.required('', fieldName: 'Số lít'), equals('Số lít không được để trống'));
      expect(AppValidators.required(null, fieldName: 'Giá tiền'), equals('Giá tiền không được để trống'));
      expect(AppValidators.required('  ', fieldName: 'Ghi chú'), equals('Ghi chú không được để trống'));
      expect(AppValidators.required('123', fieldName: 'Số lít'), isNull);
    });

    // VAL-006: Nhập ký tự không phải số vào trường số
    test('VAL-006: Giá trị số hợp lệ và không hợp lệ', () {
      expect(AppValidators.positiveNumber('70000', fieldName: 'Chi phí'), isNull);
      expect(AppValidators.positiveNumber('-1000', fieldName: 'Chi phí'), equals('Chi phí phải lớn hơn 0'));
      expect(AppValidators.positiveNumber('mot tram', fieldName: 'Chi phí'), equals('Chi phí phải là số hợp lệ'));
    });

    // LOG-005: Số KM odometer nhỏ hơn lần gần nhất
    test('LOG-005: Odometer lần sau nhỏ hơn lần trước', () {
      final odometerValidator = AppValidators.odometer(previousKm: 10000);
      
      // Hợp lệ (lớn hơn lần trước)
      expect(odometerValidator('10001'), isNull);
      expect(odometerValidator('12000'), isNull);
      
      // Không hợp lệ (nhỏ hơn hoặc bằng lần trước)
      expect(
        odometerValidator('9500'),
        equals('Số km phải lớn hơn lần trước (10000 km)'),
      );
      expect(
        odometerValidator('10000'),
        equals('Số km phải lớn hơn lần trước (10000 km)'),
      );
      expect(
        odometerValidator('abc'),
        equals('Số km phải là số hợp lệ'),
      );
    });
  });
}
