

import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/geo_fence_model.dart';

class GeoFenceService extends GetxService {
  final RxString geofenceMessage = ''.obs;
  List<Geofence> _geofences = [];
  static const double REQUIRED_RADIUS = 100.0; // meters

  /// Initialize geofences
  Future<void> setupGeofences(List<Geofence> geofences) async {
    _geofences = List.from(geofences);
    geofenceMessage.value = ' ';
  }

  /// Haversine formula - calculate distance in meters
  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Earth radius in meters
    final double phi1 = lat1 * (math.pi / 180.0);
    final double phi2 = lat2 * (math.pi / 180.0);
    final double dPhi = (lat2 - lat1) * (math.pi / 180.0);
    final double dLambda = (lon2 - lon1) * (math.pi / 180.0);

    final a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(dLambda / 2) * math.sin(dLambda / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  /// Check if the position is inside any geofence
  bool isInsideGeofence(double lat, double lon, [List<Geofence>? geofences]) {
    final list = geofences ?? _geofences;
    for (var g in list) {
      final dist = _distanceMeters(lat, lon, g.latitude, g.longitude);
      if (dist <= REQUIRED_RADIUS) {
        geofenceMessage.value = 'inside_geofence_with_distance'
            .trParams({'name': g.name ?? g.id ?? 'unknown', 'distance': dist.toStringAsFixed(2)});
        return true;
      }
    }
    geofenceMessage.value = 'error_geofence_outside_100m_workplace'.tr;
    return false;
  }

  /// Get current position with permission handling
  Future<Position> getCurrentPosition({bool debug = false}) async {
    if (debug) {
      return Position(
        latitude: 33.577500,
        longitude: 72.869700,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 10,
        headingAccuracy: 10,
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        geofenceMessage.value = 'error_location_permission_denied'.tr;
        throw Exception('error_location_permission_denied'.tr);
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Clock in/out based on geofence validation
  Future<Map<String, dynamic>> clockInOut({bool debug = false, List<Geofence>? geofences}) async {
    try {
      final position = await getCurrentPosition(debug: debug);

      final isWithinGeofence = isInsideGeofence(
        position.latitude,
        position.longitude,
        geofences ?? _geofences,
      );

      if (isWithinGeofence) {
        final action = 'Clocked ${DateTime.now().hour < 12 ? 'in' : 'out'} successfully'.tr;
        return {
          'success': true,
          'message': action,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'success': false,
          'message': geofenceMessage.value,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'error_clock_in_out'.trParams({'error': e.toString()}),
      };
    }
  }
}
