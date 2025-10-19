

import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/geo_fence_model.dart';
import 'offline_local_storage.dart';
import 'superbase_services.dart';

class GeoFenceService extends GetxService {
  final RxString geofenceMessage = ''.obs;
  List<Geofence> _geofences = [];
  static const double REQUIRED_RADIUS = 100.0; // meters

  /// Initialize geofences, fetching from local storage or Supabase
  Future<void> setupGeofences([List<Geofence>? geofences]) async {
    final offlineService = Get.find<OfflineLocalStorageService>();
    final supabaseService = Get.find<SupabaseService>();

    if (geofences != null && geofences.isNotEmpty) {
      _geofences = List.from(geofences);
      await offlineService.saveGeofences(geofences); // Store provided geofences locally
      geofenceMessage.value = ' ';
      print('Geofences set up from provided list: ${geofences.length} geofences');
    } else {
      // Try to load from local storage first
      _geofences = await offlineService.getStoredGeofences();
      if (_geofences.isEmpty) {
        // Fallback to fetching from Supabase if local storage is empty
        _geofences = await supabaseService.getGeofences();
        if (_geofences.isNotEmpty) {
          await offlineService.saveGeofences(_geofences); // Store fetched geofences
          print('Geofences fetched from Supabase and stored: ${_geofences.length}');
        } else {
          print('No geofences available from Supabase or local storage');
          geofenceMessage.value = 'no_geofences_available'.tr;
        }
      } else {
        print('Geofences loaded from local storage: ${_geofences.length}');
      }
    }
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

  /// Get current position with permission handling, falling back to Supabase if denied
  Future<Map<String, dynamic>> getCurrentPosition({bool debug = false, required String empCode}) async {
    if (debug) {
      return {
        'success': true,
        'latitude': 33.577500,
        'longitude': 72.869700,
        'source': 'debug',
      };
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // Fallback to Supabase last known location
        final userLocation = await Get.find<SupabaseService>().getUserLocation(empCode);
        if (userLocation != null && userLocation['lat'] != null && userLocation['lon'] != null) {
          print('Using last known location from Supabase for empCode: $empCode');
          return {
            'success': true,
            'latitude': userLocation['lat'] as double,
            'longitude': userLocation['lon'] as double,
            'source': 'supabase',
          };
        } else {
          geofenceMessage.value = 'error_no_location_data'.tr;
          return {
            'success': false,
            'message': 'error_no_location_data'.tr,
          };
        }
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'source': 'live',
      };
    } catch (e) {
      // Fallback to Supabase if live location fails
      final userLocation = await Get.find<SupabaseService>().getUserLocation(empCode);
      if (userLocation != null && userLocation['lat'] != null && userLocation['lon'] != null) {
        print('Live location failed, using Supabase location for empCode: $empCode');
        return {
          'success': true,
          'latitude': userLocation['lat'] as double,
          'longitude': userLocation['lon'] as double,
          'source': 'supabase',
        };
      }
      geofenceMessage.value = 'error_location_fetch_failed'.tr;
      return {
        'success': false,
        'message': 'error_location_fetch_failed'.trParams({'error': e.toString()}),
      };
    }
  }

  /// Validate location for clock-in/out, using stored geofences
  Future<Map<String, dynamic>> validateLocationForClockAction({
    bool debug = false,
    required String empCode,
    List<Geofence>? geofences,
  }) async {
    final positionResult = await getCurrentPosition(debug: debug, empCode: empCode);
    if (!positionResult['success']) {
      return {
        'success': false,
        'message': positionResult['message'],
      };
    }

    final isWithinGeofence = isInsideGeofence(
      positionResult['latitude'],
      positionResult['longitude'],
      geofences ?? _geofences,
    );

    if (isWithinGeofence) {
      return {
        'success': true,
        'latitude': positionResult['latitude'],
        'longitude': positionResult['longitude'],
        'message': geofenceMessage.value,
        'source': positionResult['source'],
      };
    } else {
      return {
        'success': false,
        'message': geofenceMessage.value,
      };
    }
  }
}