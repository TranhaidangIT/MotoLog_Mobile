import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Dịch vụ quản lý thông báo nhắc nhở (Local Notifications)
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Khởi tạo dịch vụ thông báo và cấu hình múi giờ
  static Future<void> init() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initIOS = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: initAndroid, iOS: initIOS);
    await _plugin.initialize(initSettings);
  }

  /// Đặt lịch nhắc nhở đổ xăng dựa trên số km dự kiến còn lại
  static Future<void> scheduleRefuelReminder(int estimatedKmLeft, {int estimateDays = 5}) async {
    // Vì MotoLog chưa có Background Service đọc ODO realtime,
    // ta sử dụng heurictic đếm lùi số ngày tương ứng với số km.
    final scheduleTime = tz.TZDateTime.now(tz.local).add(Duration(days: estimateDays));
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'refuel_channel', 'Nhắc nhở đổ xăng',
      channelDescription: 'Thông báo khi gần hết xăng',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    await _plugin.zonedSchedule(
      0,
      'Cảnh báo nhiên liệu',
      'Theo mức tiêu hao của bạn, xe sắp đi hết khoảng $estimatedKmLeft km. Đừng quên đổ xăng nhé!',
      scheduleTime,
      platformDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
