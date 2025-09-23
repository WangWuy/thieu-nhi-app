import 'package:equatable/equatable.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_state.dart';
import 'package:thieu_nhi_app/features/students/models/student_filter.dart';
import '../../../core/models/student_model.dart';

abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudents extends StudentsEvent {
  final String classId;

  const LoadStudents(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadStudentsByClassEvent extends StudentsEvent {
  final String classId;

  const LoadStudentsByClassEvent({required this.classId});

  @override
  List<Object?> get props => [classId];
}

class LoadAllStudentsEvent extends StudentsEvent {
  const LoadAllStudentsEvent();
}

class RefreshStudentsEvent extends StudentsEvent {
  const RefreshStudentsEvent();
}

class SearchStudentsEvent extends StudentsEvent {
  final String searchTerm;

  const SearchStudentsEvent({required this.searchTerm});

  @override
  List<Object?> get props => [searchTerm];
}

class LoadStudentsByDepartment extends StudentsEvent {
  final String department;

  const LoadStudentsByDepartment(this.department);

  @override
  List<Object?> get props => [department];
}

class LoadStudentDetail extends StudentsEvent {
  final String studentId;

  const LoadStudentDetail(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class AddStudent extends StudentsEvent {
  final StudentModel student;

  const AddStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class UpdateStudent extends StudentsEvent {
  final StudentModel student;

  const UpdateStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class DeleteStudent extends StudentsEvent {
  final String studentId;

  const DeleteStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class UpdateStudentAttendance extends StudentsEvent {
  final String studentId;
  final Map<String, bool> attendance;

  const UpdateStudentAttendance(this.studentId, this.attendance);

  @override
  List<Object?> get props => [studentId, attendance];
}

class UpdateStudentGrades extends StudentsEvent {
  final String studentId;
  final List<double> grades;

  const UpdateStudentGrades(this.studentId, this.grades);

  @override
  List<Object?> get props => [studentId, grades];
}

class BulkUpdateAttendance extends StudentsEvent {
  final String classId;
  final String week;
  final Map<String, bool> attendanceUpdates; // studentId -> isPresent

  const BulkUpdateAttendance({
    required this.classId,
    required this.week,
    required this.attendanceUpdates,
  });

  @override
  List<Object?> get props => [classId, week, attendanceUpdates];
}

class SearchStudents extends StudentsEvent {
  final String query;

  const SearchStudents(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterStudents extends StudentsEvent {
  final StudentFilter filter;

  const FilterStudents(this.filter);

  @override
  List<Object?> get props => [filter];
}

class RefreshStudents extends StudentsEvent {
  final bool forceReload;

  const RefreshStudents({this.forceReload = false});

  @override
  List<Object?> get props => [forceReload];
}

// Internal events (không expose cho UI, nhưng phải public để BLoC access)
class UpdateStudentsInternal extends StudentsEvent {
  final List<StudentModel> students;
  final List<StudentModel> filteredStudents;
  final String? currentClassId;
  final String? currentDepartment;
  final String searchQuery;
  final StudentFilter filter;

  const UpdateStudentsInternal({
    required this.students,
    required this.filteredStudents,
    this.currentClassId,
    this.currentDepartment,
    required this.searchQuery,
    required this.filter,
  });

  @override
  List<Object?> get props => [
        students,
        filteredStudents,
        currentClassId,
        currentDepartment,
        searchQuery,
        filter
      ];
}

class StudentsStreamError extends StudentsEvent {
  final String error;

  const StudentsStreamError(this.error);

  @override
  List<Object?> get props => [error];
}

class BackToStudentsList extends StudentsEvent {
  final String? classId;
  final StudentsLoaded? previousState;

  const BackToStudentsList({
    this.classId,
    this.previousState,
  });

  @override
  List<Object?> get props => [classId, previousState];
}

class ForceRefreshStudents extends StudentsEvent {
  final String? classId;
  final String? department;

  const ForceRefreshStudents({
    this.classId,
    this.department,
  });

  @override
  List<Object?> get props => [classId, department];
}

class SaveNavigationState extends StudentsEvent {
  final StudentsLoaded state;

  const SaveNavigationState(this.state);

  @override
  List<Object?> get props => [state];
}