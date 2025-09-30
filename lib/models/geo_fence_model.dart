class Geofence {
  final String id;
  final String? name;
  final double latitude;
  final double longitude;
  final int radius;

  Geofence({
    required this.id,
    this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      radius: json['radius_m'] ?? 100,
    );
  }
}