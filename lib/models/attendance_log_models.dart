
class AttendanceLog {
  final String id;
  final String userId;
  final DateTime? clockInTime;
  final double? clockInLat;
  final double? clockInLon;
  final DateTime? clockOutTime;
  final double? clockOutLat;
  final double? clockOutLon;
  final int? durationMinutes;
  final String? status;

  AttendanceLog({
    required this.id,
    required this.userId,
    this.clockInTime,
    this.clockInLat,
    this.clockInLon,
    this.clockOutTime,
    this.clockOutLat,
    this.clockOutLon,
    this.durationMinutes,
    this.status,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      id: json['id'],
      userId: json['user_id'],
      clockInTime: json['clock_in_time'] != null
          ? DateTime.parse(json['clock_in_time'])
          : null,
      clockInLat: json['clock_in_lat']?.toDouble(),
      clockInLon: json['clock_in_lon']?.toDouble(),
      clockOutTime: json['clock_out_time'] != null
          ? DateTime.parse(json['clock_out_time'])
          : null,
      clockOutLat: json['clock_out_lat']?.toDouble(),
      clockOutLon: json['clock_out_lon']?.toDouble(),
      durationMinutes: json['duration_minutes'],
      status: json['status'],
    );
  }
}
