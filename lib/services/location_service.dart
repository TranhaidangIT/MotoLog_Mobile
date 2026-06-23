import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class GasStation {
  final String name;
  final String? address;
  final double lat;
  final double lon;

  GasStation({required this.name, this.address, required this.lat, required this.lon});
}

class LocationService {
  Future<Position?> getCurrentPosition() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isDenied) {
      throw Exception('PERMISSION_DENIED');
    }
    if (status.isPermanentlyDenied) {
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
      // Nếu timeout, thử lấy vị trí cuối cùng đã biết để fallback
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) return lastPos;
      
      throw Exception('GPS_TIMEOUT');
    }
  }

  Future<List<GasStation>> findNearbyGasStations(double lat, double lon, {int radius = 200}) async {
    final query = '''
[out:json];
node["amenity"="fuel"](around:$radius,$lat,$lon);
out;
    ''';
    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List?;
        if (elements == null || elements.isEmpty) return [];

        return elements.map((e) {
          final tags = e['tags'] ?? {};
          final name = tags['name'] ?? tags['brand'] ?? 'Cây xăng';
          
          final addressParts = <String>[];
          if (tags['addr:housenumber'] != null) addressParts.add(tags['addr:housenumber']);
          if (tags['addr:street'] != null) addressParts.add(tags['addr:street']);
          if (tags['addr:city'] != null) {
            addressParts.add(tags['addr:city']);
          } else if (tags['addr:province'] != null) {
            addressParts.add(tags['addr:province']);
          }
          final address = addressParts.isNotEmpty ? addressParts.join(', ') : null;

          return GasStation(
            name: name,
            address: address,
            lat: e['lat'],
            lon: e['lon'],
          );
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('NETWORK_ERROR_OR_TIMEOUT');
    }
  }
}
