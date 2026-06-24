import 'dart:convert';
import 'package:geolocator/geolocator.dart';
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
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon');
      final response = await http.get(url, headers: {
        'User-Agent': 'MotoLog_Mobile_App_Student_Project (student@example.com)'
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address == null) return null;

        final addressParts = <String>[];
        if (address['house_number'] != null) addressParts.add(address['house_number']);
        if (address['road'] != null) addressParts.add(address['road']);
        if (address['suburb'] != null) addressParts.add(address['suburb']);
        if (address['city'] ?? address['town'] ?? address['county'] != null) {
          addressParts.add(address['city'] ?? address['town'] ?? address['county']);
        }
        
        return addressParts.isNotEmpty ? addressParts.join(', ') : data['display_name'];
      }
      return null;
    } catch (e) {
      return null; // Bỏ qua lỗi và trả về null nếu mạng yếu
    }
  }
}
