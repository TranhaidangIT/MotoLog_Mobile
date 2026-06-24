import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationService {
  Future<Position?> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('PERMISSION_DENIED');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('PERMISSION_DENIED_FOREVER');
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('LOCATION_SERVICE_DISABLED');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (e) {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) return lastPos;
      
      throw Exception('GPS_TIMEOUT');
    }
  }

  Future<String?> getCurrentAddress(double lat, double lon) async {
    try {
      // 1. Thử dùng Native Geocoding (Apple/Google Maps)
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon).timeout(const Duration(seconds: 5));
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];
        
        if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) parts.add(place.administrativeArea!);
        
        if (parts.isNotEmpty) {
          return parts.join(', ');
        } else if (place.name != null && place.name!.isNotEmpty) {
          return place.name!;
        }
      }
    } catch (e) {
      // Nếu máy ảo bị lỗi kết nối Native, tiếp tục xuống API Fallback bên dưới
      print('Native geocoding failed: $e. Falling back to HTTP API...');
    }

    // 2. Fallback API: Nominatim OpenStreetMap (Rất nhạy trên máy ảo)
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon');
      final response = await http.get(url, headers: {
        'User-Agent': 'MotoLog_Mobile_App'
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Nominatim có trường display_name chứa toàn bộ địa chỉ đầy đủ (số nhà, đường, phường, thành phố)
        if (data['display_name'] != null && data['display_name'].toString().isNotEmpty) {
          return data['display_name'] as String;
        }
      }
    } catch (e) {
      print('Lỗi kết nối mạng hoặc API Nominatim: $e');
      // Lỗi Timeout do máy ảo bị kẹt DNS IPv6, bỏ qua và lấy tọa độ
    }
    
    // 3. Fallback cuối cùng: Trả về tọa độ số
    return 'Tọa độ: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
  }
}
