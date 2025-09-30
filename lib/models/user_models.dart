// lib/models/user_model.dart
class User {
  final String id;
  final String empCode;
  final String name;
  final String role;
  final double? lat;
  final double? lon;

  User({
    required this.id,
    required this.empCode,
    required this.name,
    required this.role,
    this.lat,
    this.lon,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      empCode: json['emp_code'],
      name: json['name'],
      role: json['role'],
      lat: json['lat']?.toDouble(),
      lon: json['lon']?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, empCode: $empCode, name: $name, role: $role)';
  }
}