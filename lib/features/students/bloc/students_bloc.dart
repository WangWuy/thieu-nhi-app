// lib/features/students/bloc/students_bloc.dart - IMPROVED VERSION
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/core/services/backend_adapters.dart';
import 'package:thieu_nhi_app/features/students/models/student_filter.dart';
import 'dart:async';
import '../../../core/services/student_service.dart';
import '../../../core/services/class_service.dart';
import '../../../core/services/attendance_service.dart';
import '../../../core/models/student_model.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final StudentService _studentService;
  final ClassService _classService;
  final AttendanceService _attendanceService;

  Timer? _refreshTimer;
  StudentsLoaded? _savedNavigationState;
  final Map<String, StudentModel> _studentCache = {};

  StudentsBloc({
    required StudentService studentService,
    required ClassService classService,
    required AttendanceService attendanceService,
  })  : _studentService = studentService,
        _classService = classService,
        _attendanceService = attendanceService,
        super(const StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<LoadStudentsByDepartment>(_onLoadStudentsByDepartment);
    on<LoadStudentDetail>(_onLoadStudentDetail);
    on<AddStudent>(_onAddStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<UpdateStudentAttendance>(_onUpdateStudentAttendance);
    on<UpdateStudentGrades>(_onUpdateStudentGrades);
    on<BulkUpdateAttendance>(_onBulkUpdateAttendance);
    on<SearchStudents>(_onSearchStudents);
    on<FilterStudents>(_onFilterStudents);
    on<RefreshStudents>(_onRefreshStudents);
    on<BackToStudentsList>(_onBackToStudentsList);
    on<ForceRefreshStudents>(_onForceRefreshStudents);
    on<SaveNavigationState>(_onSaveNavigationState);

    // Setup periodic refresh
    _setupPeriodicRefresh();
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    _studentCache.clear();
    return super.close();
  }

  void _setupPeriodicRefresh() {
    // Refresh students every 5 minutes if loaded
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!isClosed && state is StudentsLoaded) {
        add(RefreshStudents());
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentsState> emit,
  ) async {
    final currentState = state;

    if (currentState is StudentsLoaded &&
        currentState.currentClassId == event.classId &&
        currentState.students.isNotEmpty &&
        _isDataFresh(currentState.lastUpdated)) {
      return; 
    }

    emit(const StudentsLoading());

    try {
      final students = await _studentService.getStudentsByClass(event.classId);

      // Update cache
      for (final student in students) {
        _studentCache[student.id] = student;
      }

      final filteredStudents =
          _applyFilters(students, '', const StudentFilter());

      final newState = StudentsLoaded(
        students: students,
        filteredStudents: filteredStudents,
        currentClassId: event.classId,
        currentDepartment: null,
        searchQuery: '',
        filter: const StudentFilter(),
        lastUpdated: DateTime.now(),
      );

      emit(newState);

      // Save for navigation
      add(SaveNavigationState(newState));
    } catch (e) {
      emit(StudentsError(
        message: 'Không thể tải danh sách thiếu nhi: ${_formatError(e)}',
        errorCode: 'LOAD_STUDENTS_ERROR',
      ));
    }
  }

  Future<void> _onLoadStudentsByDepartment(
    LoadStudentsByDepartment event,
    Emitter<StudentsState> emit,
  ) async {
    emit(const StudentsLoading());

    try {
      // Load students by department using search with department filter
      final result = await _studentService.getStudents(
        limit: 1000, // Large limit to get all students
      );

      // Filter by department on client side
      final students = result.students
              ?.where((student) =>
                  student.department.toLowerCase() ==
                  event.department.toLowerCase())
              .toList() ??
          [];

      // Update cache
      for (final student in students) {
        _studentCache[student.id] = student;
      }

      final filteredStudents =
          _applyFilters(students, '', const StudentFilter());

      emit(StudentsLoaded(
        students: students,
        filteredStudents: filteredStudents,
        currentClassId: null,
        currentDepartment: event.department,
        searchQuery: '',
        filter: const StudentFilter(),
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(StudentsError(
        message:
            'Không thể tải danh sách thiếu nhi ngành ${event.department}: ${_formatError(e)}',
        errorCode: 'LOAD_DEPARTMENT_STUDENTS_ERROR',
      ));
    }
  }

  Future<void> _onLoadStudentDetail(
    LoadStudentDetail event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      final currentState = state;

      // Save StudentsLoaded state before loading detail
      if (currentState is StudentsLoaded) {
        add(SaveNavigationState(currentState));

        // Find student in current state first
        final cachedStudent = currentState.students
            .where((s) => s.id == event.studentId)
            .firstOrNull;

        // If found and data is fresh, use cached version
        if (cachedStudent != null && _isDataFresh(currentState.lastUpdated)) {
          emit(StudentDetailLoaded(
            student: cachedStudent,
            lastUpdated: currentState.lastUpdated,
          ));
          return;
        }
      }

      // Also check memory cache
      final cachedStudent = _studentCache[event.studentId];
      if (cachedStudent != null) {
        emit(StudentDetailLoaded(
          student: cachedStudent,
          lastUpdated: DateTime.now(),
        ));

        // Load fresh data in background
        _loadStudentDetailInBackground(event.studentId);
        return;
      }

      // Load from API if not found in current state or cache
      final student = await _studentService.getStudentById(event.studentId);

      if (student != null) {
        // Update cache
        _studentCache[student.id] = student;

        emit(StudentDetailLoaded(
          student: student,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(const StudentsError(
          message: 'Không tìm thấy thông tin thiếu nhi',
          errorCode: 'STUDENT_NOT_FOUND',
        ));
      }
    } catch (e) {
      emit(StudentsError(
        message: 'Không thể tải thông tin thiếu nhi: ${_formatError(e)}',
        errorCode: 'LOAD_STUDENT_DETAIL_ERROR',
      ));
    }
  }

  // Background refresh for student detail
  Future<void> _loadStudentDetailInBackground(String studentId) async {
    try {
      final student = await _studentService.getStudentById(studentId);
      if (student != null) {
        // Update cache silently
        _studentCache[student.id] = student;

        // Update state if still viewing the same student
        if (!isClosed && state is StudentDetailLoaded) {
          final currentDetailState = state as StudentDetailLoaded;
          if (currentDetailState.student.id == studentId) {
            emit(StudentDetailLoaded(
              student: student,
              lastUpdated: DateTime.now(),
            ));
          }
        }
      }
    } catch (e) {
      // Silent fail for background refresh
      print('Background refresh failed for student $studentId: $e');
    }
  }

  Future<void> _onAddStudent(
    AddStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      // Tạo student code nếu chưa có
      final studentCode = event.student.qrId?.isNotEmpty == true
          ? event.student.qrId!
          : 'TN${DateTime.now().millisecondsSinceEpoch}';

      final newStudent = await _studentService.createStudent(
        studentCode: studentCode,
        fullName: event.student.name,
        classId: int.parse(event.student.classId),
        saintName: event.student.saintName,
        birthDate: event.student.birthDate,
        phoneNumber:
            event.student.phone.isNotEmpty ? event.student.phone : null,
        parentPhone1: event.student.parentPhone,
        parentPhone2: event.student.parentPhone2?.isNotEmpty == true
            ? event.student.parentPhone2
            : null,
        address: event.student.address,
      );

      if (newStudent != null) {
        // Update cache
        _studentCache[newStudent.id] = newStudent;

        emit(StudentOperationSuccess(
          message: 'Đã thêm thiếu nhi "${newStudent.name}" thành công',
          operationType: StudentOperationType.add,
          previousState: state is StudentsLoaded
              ? state as StudentsLoaded
              : StudentsLoaded(
                  students: [],
                  filteredStudents: [],
                  searchQuery: '',
                  filter: const StudentFilter(),
                  lastUpdated: DateTime.now(),
                ),
        ));

        // Refresh current list
        final currentState = state;
        if (currentState is StudentsLoaded) {
          if (currentState.currentClassId != null) {
            add(LoadStudents(currentState.currentClassId!));
          } else if (currentState.currentDepartment != null) {
            add(LoadStudentsByDepartment(currentState.currentDepartment!));
          }
        }
      } else {
        emit(const StudentsError(
          message: 'Không thể thêm thiếu nhi. Vui lòng kiểm tra thông tin.',
          errorCode: 'ADD_STUDENT_FAILED',
        ));
      }
    } catch (e) {
      emit(StudentsError(
        message: 'Lỗi thêm thiếu nhi: ${_formatError(e)}',
        errorCode: 'ADD_STUDENT_ERROR',
      ));
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      // Sử dụng adapter để convert StudentModel thành Map
      final updateData =
          BackendStudentAdapter.toBackendUpdateJson(event.student);

      final updatedStudent = await _studentService.updateStudent(
        event.student.id,
        updateData, // Pass Map<String, dynamic> instead of StudentModel
      );

      if (updatedStudent != null) {
        // Update cache
        _studentCache[updatedStudent.id] = updatedStudent;

        final currentState = state;
        if (currentState is StudentsLoaded) {
          emit(StudentOperationSuccess(
            message: 'Đã cập nhật thông tin thiếu nhi',
            operationType: StudentOperationType.update,
            previousState: currentState,
          ));

          // Update local state immediately
          final updatedStudents = currentState.students.map((student) {
            return student.id == event.student.id ? updatedStudent : student;
          }).toList();

          final filteredStudents = _applyFilters(
              updatedStudents, currentState.searchQuery, currentState.filter);

          emit(currentState.copyWith(
            students: updatedStudents,
            filteredStudents: filteredStudents,
            lastUpdated: DateTime.now(),
          ));
        } else if (currentState is StudentDetailLoaded) {
          emit(StudentDetailLoaded(
            student: updatedStudent,
            lastUpdated: DateTime.now(),
          ));
        }
      } else {
        emit(const StudentsError(
          message: 'Không thể cập nhật thông tin thiếu nhi',
          errorCode: 'UPDATE_STUDENT_FAILED',
        ));
      }
    } catch (e) {
      emit(StudentsError(
        message: 'Không thể cập nhật thông tin thiếu nhi: ${_formatError(e)}',
        errorCode: 'UPDATE_STUDENT_ERROR',
      ));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudent event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      final success = await _studentService.deleteStudent(event.studentId);

      if (success) {
        // Remove from cache
        _studentCache.remove(event.studentId);

        final currentState = state;
        if (currentState is StudentsLoaded) {
          emit(StudentOperationSuccess(
            message: 'Đã xóa thiếu nhi',
            operationType: StudentOperationType.delete,
            previousState: currentState,
          ));

          // Refresh the students list
          add(RefreshStudents(forceReload: true));
        }
      } else {
        emit(const StudentsError(
          message: 'Không thể xóa thiếu nhi',
          errorCode: 'DELETE_STUDENT_FAILED',
        ));
      }
    } catch (e) {
      emit(StudentsError(
        message: 'Không thể xóa thiếu nhi: ${_formatError(e)}',
        errorCode: 'DELETE_STUDENT_ERROR',
      ));
    }
  }

  Future<void> _onUpdateStudentAttendance(
    UpdateStudentAttendance event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      // Convert attendance map to attendance records for API
      final attendanceRecords = <AttendanceRecord>[];

      for (final entry in event.attendance.entries) {
        // Parse week key to get date and type
        final parts = entry.key.split('_');
        if (parts.length == 2) {
          final type = parts[0].toLowerCase() == 'thu' ? 'thursday' : 'sunday';

          // Tạo date cho attendance record (có thể dùng date từ key hoặc today)
          final today = DateTime.now();

          // Sử dụng AttendanceRecord.create() với đầy đủ required fields
          attendanceRecords.add(AttendanceRecord.create(
            studentId: int.parse(event.studentId),
            attendanceDate: today, // Required DateTime
            attendanceType: type, // Required String ('thursday' or 'sunday')
            isPresent: entry.value,
            note: 'Manual update', // Optional note
          ));
        }
      }

      // TODO: Call actual API để update attendance
      // final result = await _attendanceService.batchMarkAttendance(
      //   classId: classId,
      //   attendanceDate: today.toIso8601String().split('T')[0],
      //   attendanceType: attendanceType,
      //   attendanceRecords: attendanceRecords,
      // );

      // For now, update local state immediately
      final currentState = state;
      if (currentState is StudentsLoaded) {
        final updatedStudents = currentState.students.map((student) {
          if (student.id == event.studentId) {
            final newAttendance = Map<String, bool>.from(student.attendance);
            newAttendance.addAll(event.attendance);
            final updatedStudent = student.copyWith(
              attendance: newAttendance,
              updatedAt: DateTime.now(),
            );

            // Update cache
            _studentCache[student.id] = updatedStudent;

            return updatedStudent;
          }
          return student;
        }).toList();

        final filteredStudents = _applyFilters(
            updatedStudents, currentState.searchQuery, currentState.filter);

        emit(currentState.copyWith(
          students: updatedStudents,
          filteredStudents: filteredStudents,
          lastUpdated: DateTime.now(),
        ));
      } else if (currentState is StudentDetailLoaded) {
        final newAttendance =
            Map<String, bool>.from(currentState.student.attendance);
        newAttendance.addAll(event.attendance);

        final updatedStudent = currentState.student.copyWith(
          attendance: newAttendance,
          updatedAt: DateTime.now(),
        );

        // Update cache
        _studentCache[updatedStudent.id] = updatedStudent;

        emit(StudentDetailLoaded(
          student: updatedStudent,
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(StudentsError(
        message: 'Không thể cập nhật điểm danh: ${_formatError(e)}',
        errorCode: 'UPDATE_ATTENDANCE_ERROR',
      ));
    }
  }

  Future<void> _onUpdateStudentGrades(
    UpdateStudentGrades event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      // Update grades via API (simplified for now)
      final updateData = {
        'studyScore': event.grades.isNotEmpty ? event.grades.first : 0.0,
      };

      final updatedStudent = await _studentService.updateStudent(
        event.studentId,
        updateData,
      );

      if (updatedStudent != null) {
        // Update cache
        _studentCache[updatedStudent.id] = updatedStudent;

        // Update local state immediately
        final currentState = state;
        if (currentState is StudentsLoaded) {
          final updatedStudents = currentState.students.map((student) {
            if (student.id == event.studentId) {
              return student.copyWith(
                grades: event.grades,
                updatedAt: DateTime.now(),
              );
            }
            return student;
          }).toList();

          final filteredStudents = _applyFilters(
            updatedStudents,
            currentState.searchQuery,
            currentState.filter,
          );

          emit(currentState.copyWith(
            students: updatedStudents,
            filteredStudents: filteredStudents,
            lastUpdated: DateTime.now(),
          ));
        } else if (currentState is StudentDetailLoaded) {
          emit(StudentDetailLoaded(
            student: currentState.student.copyWith(
              grades: event.grades,
              updatedAt: DateTime.now(),
            ),
            lastUpdated: DateTime.now(),
          ));
        }
      }
    } catch (e) {
      emit(StudentsError(
        message: 'Không thể cập nhật điểm số: ${_formatError(e)}',
        errorCode: 'UPDATE_GRADES_ERROR',
      ));
    }
  }

  Future<void> _onBulkUpdateAttendance(
    BulkUpdateAttendance event,
    Emitter<StudentsState> emit,
  ) async {
    try {
      // TODO: Implement bulk attendance update API
      // For now, update local state

      final currentState = state;
      if (currentState is StudentsLoaded) {
        emit(StudentOperationSuccess(
          message:
              'Đã cập nhật điểm danh cho ${event.attendanceUpdates.length} thiếu nhi',
          operationType: StudentOperationType.bulkUpdate,
          previousState: currentState,
        ));
      }
    } catch (e) {
      emit(StudentsError(
        message: 'Không thể cập nhật điểm danh hàng loạt: ${_formatError(e)}',
        errorCode: 'BULK_UPDATE_ATTENDANCE_ERROR',
      ));
    }
  }

  Future<void> _onSearchStudents(
    SearchStudents event,
    Emitter<StudentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is StudentsLoaded) {
      final filteredStudents = _applyFilters(
        currentState.students,
        event.query,
        currentState.filter,
      );

      emit(currentState.copyWith(
        filteredStudents: filteredStudents,
        searchQuery: event.query,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onFilterStudents(
    FilterStudents event,
    Emitter<StudentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is StudentsLoaded) {
      final filteredStudents = _applyFilters(
        currentState.students,
        currentState.searchQuery,
        event.filter,
      );

      emit(currentState.copyWith(
        filteredStudents: filteredStudents,
        filter: event.filter,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onRefreshStudents(
    RefreshStudents event,
    Emitter<StudentsState> emit,
  ) async {
    final currentState = state;

    if (currentState is StudentsLoaded) {
      if (event.forceReload) {
        emit(StudentsRefreshing(currentState));
      }

      // Clear cache for fresh data
      if (event.forceReload) {
        _studentCache.clear();
      }

      // Reload data
      if (currentState.currentClassId != null) {
        add(LoadStudents(currentState.currentClassId!));
      } else if (currentState.currentDepartment != null) {
        add(LoadStudentsByDepartment(currentState.currentDepartment!));
      }
    }
  }

  Future<void> _onBackToStudentsList(
    BackToStudentsList event,
    Emitter<StudentsState> emit,
  ) async {
    if (event.previousState != null) {
      emit(event.previousState!);
    } else if (event.classId != null) {
      add(LoadStudents(event.classId!));
    } else if (_savedNavigationState != null) {
      emit(_savedNavigationState!);
    } else {
      emit(const StudentsError(
        message: 'Không thể quay lại danh sách thiếu nhi',
        errorCode: 'NAVIGATION_ERROR',
      ));
    }
  }

  Future<void> _onForceRefreshStudents(
    ForceRefreshStudents event,
    Emitter<StudentsState> emit,
  ) async {
    // Clear cache for fresh data
    _studentCache.clear();

    if (event.classId != null) {
      add(LoadStudents(event.classId!));
    } else if (event.department != null) {
      add(LoadStudentsByDepartment(event.department!));
    }
  }

  Future<void> _onSaveNavigationState(
    SaveNavigationState event,
    Emitter<StudentsState> emit,
  ) async {
    _savedNavigationState = event.state;
  }

  // Helper method to check if data is fresh (within 5 minutes)
  bool _isDataFresh(DateTime lastUpdated) {
    return DateTime.now().difference(lastUpdated).inMinutes < 5;
  }

  // Helper method to format errors for user display
  String _formatError(dynamic error) {
    final errorStr = error.toString();

    // Common error patterns and user-friendly messages
    if (errorStr.contains('Network')) {
      return 'Lỗi kết nối mạng';
    } else if (errorStr.contains('timeout')) {
      return 'Quá thời gian chờ';
    } else if (errorStr.contains('404')) {
      return 'Không tìm thấy dữ liệu';
    } else if (errorStr.contains('401')) {
      return 'Không có quyền truy cập';
    } else if (errorStr.contains('500')) {
      return 'Lỗi server';
    }

    return errorStr.length > 100
        ? '${errorStr.substring(0, 100)}...'
        : errorStr;
  }

  // Helper method to apply search and filters
  List<StudentModel> _applyFilters(
    List<StudentModel> students,
    String searchQuery,
    StudentFilter filter,
  ) {
    var filtered = students;

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((student) {
        return student.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            student.id.contains(searchQuery) ||
            student.phone.contains(searchQuery) ||
            (student.qrId?.contains(searchQuery) ?? false);
      }).toList();
    }

    // Apply attendance filter
    if (filter.attendanceFilter != null) {
      filtered = filtered.where((student) {
        switch (filter.attendanceFilter!) {
          case AttendanceFilter.excellent:
            return student.attendanceRate >= 95;
          case AttendanceFilter.good:
            return student.attendanceRate >= 80 && student.attendanceRate < 95;
          case AttendanceFilter.poor:
            return student.attendanceRate < 80;
        }
      }).toList();
    }

    // Apply grade filter
    if (filter.gradeFilter != null) {
      filtered = filtered.where((student) {
        switch (filter.gradeFilter!) {
          case GradeFilter.excellent:
            return student.averageGrade >= 9;
          case GradeFilter.good:
            return student.averageGrade >= 7 && student.averageGrade < 9;
          case GradeFilter.average:
            return student.averageGrade >= 5 && student.averageGrade < 7;
          case GradeFilter.poor:
            return student.averageGrade < 5;
        }
      }).toList();
    }

    // Apply sorting
    switch (filter.sortBy) {
      case StudentSortBy.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case StudentSortBy.attendanceRate:
        filtered.sort((a, b) => b.attendanceRate.compareTo(a.attendanceRate));
        break;
      case StudentSortBy.averageGrade:
        filtered.sort((a, b) => b.averageGrade.compareTo(a.averageGrade));
        break;
      case StudentSortBy.birthDate:
        filtered.sort((a, b) => a.birthDate.compareTo(b.birthDate));
        break;
    }

    return filtered;
  }
}
