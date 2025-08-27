import 'package:equatable/equatable.dart';

class StudentFilter extends Equatable {
  final AttendanceFilter? attendanceFilter;
  final GradeFilter? gradeFilter;
  final StudentSortBy sortBy;
  final bool sortAscending;

  const StudentFilter({
    this.attendanceFilter,
    this.gradeFilter,
    this.sortBy = StudentSortBy.name,
    this.sortAscending = true,
  });

  StudentFilter copyWith({
    AttendanceFilter? attendanceFilter,
    GradeFilter? gradeFilter,
    StudentSortBy? sortBy,
    bool? sortAscending,
  }) {
    return StudentFilter(
      attendanceFilter: attendanceFilter ?? this.attendanceFilter,
      gradeFilter: gradeFilter ?? this.gradeFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  List<Object?> get props =>
      [attendanceFilter, gradeFilter, sortBy, sortAscending];
}

enum AttendanceFilter {
  excellent, // >= 95%
  good, // 80-94%
  poor, // < 80%
}

enum GradeFilter {
  excellent, // >= 9
  good, // 7-8.9
  average, // 5-6.9
  poor, // < 5
}

enum StudentSortBy {
  name,
  attendanceRate,
  averageGrade,
  birthDate,
}

enum StudentOperationType {
  add,
  update,
  delete,
  bulkUpdate,
}

// Extension for first or null
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
