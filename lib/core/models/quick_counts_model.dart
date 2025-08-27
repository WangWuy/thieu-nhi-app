// lib/core/models/quick_counts_model.dart
class QuickCounts {
  final int totalClasses;
  final int totalStudents;
  final DateTime timestamp;

  QuickCounts({
    required this.totalClasses,
    required this.totalStudents,
    required this.timestamp,
  });

  factory QuickCounts.fromJson(Map<String, dynamic> json) {
    return QuickCounts(
      totalClasses: json['totalClasses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  factory QuickCounts.empty() {
    return QuickCounts(
      totalClasses: 0,
      totalStudents: 0,
      timestamp: DateTime.now(),
    );
  }

  bool get hasData => totalStudents > 0;
}