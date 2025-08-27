// lib/core/models/attendance_summary_model.dart
class AttendanceSummary {
  final int present;
  final int absent;
  final double rate;
  final DateTime lastUpdated;

  AttendanceSummary({
    required this.present,
    required this.absent,
    required this.rate,
    required this.lastUpdated,
  });

  factory AttendanceSummary.empty() {
    return AttendanceSummary(
      present: 0,
      absent: 0,
      rate: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  int get total => present + absent;
  String get rateFormatted => '${rate.toStringAsFixed(1)}%';
}