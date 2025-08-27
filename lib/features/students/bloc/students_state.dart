import 'package:equatable/equatable.dart';
import 'package:thieu_nhi_app/features/students/models/student_filter.dart';
import '../../../core/models/student_model.dart';

abstract class StudentsState extends Equatable {
  const StudentsState();

  @override
  List<Object?> get props => [];
}

class StudentsInitial extends StudentsState {
  const StudentsInitial();
}

class StudentsLoading extends StudentsState {
  const StudentsLoading();
}

class StudentsLoaded extends StudentsState {
  final List<StudentModel> students;
  final List<StudentModel> filteredStudents;
  final String? currentClassId;
  final String? currentDepartment;
  final String searchQuery;
  final StudentFilter filter;
  final DateTime lastUpdated;

  const StudentsLoaded({
    required this.students,
    required this.filteredStudents,
    this.currentClassId,
    this.currentDepartment,
    this.searchQuery = '',
    this.filter = const StudentFilter(),
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        students,
        filteredStudents,
        currentClassId,
        currentDepartment,
        searchQuery,
        filter,
        lastUpdated,
      ];

  StudentsLoaded copyWith({
    List<StudentModel>? students,
    List<StudentModel>? filteredStudents,
    String? currentClassId,
    String? currentDepartment,
    String? searchQuery,
    StudentFilter? filter,
    DateTime? lastUpdated,
  }) {
    return StudentsLoaded(
      students: students ?? this.students,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      currentClassId: currentClassId ?? this.currentClassId,
      currentDepartment: currentDepartment ?? this.currentDepartment,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class StudentDetailLoaded extends StudentsState {
  final StudentModel student;
  final DateTime lastUpdated;

  const StudentDetailLoaded({
    required this.student,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [student, lastUpdated];

  StudentDetailLoaded copyWith({
    StudentModel? student,
    DateTime? lastUpdated,
  }) {
    return StudentDetailLoaded(
      student: student ?? this.student,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class StudentsError extends StudentsState {
  final String message;
  final String? errorCode;

  const StudentsError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class StudentOperationSuccess extends StudentsState {
  final String message;
  final StudentOperationType operationType;
  final StudentsLoaded previousState;

  const StudentOperationSuccess({
    required this.message,
    required this.operationType,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, operationType, previousState];
}

class StudentsRefreshing extends StudentsState {
  final StudentsLoaded previousState;

  const StudentsRefreshing(this.previousState);

  @override
  List<Object?> get props => [previousState];
}
