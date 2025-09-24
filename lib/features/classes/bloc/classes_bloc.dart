// lib/features/classes/bloc/classes_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/services/class_service.dart';
import 'classes_event.dart';
import 'classes_state.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final ClassService _classService;

  ClassesBloc({required ClassService classService})
      : _classService = classService,
        super(const ClassesInitial()) {
    on<LoadClassesData>(_onLoadClassesData);
    on<RefreshClassesData>(_onRefreshClassesData);
  }

  Future<void> _onLoadClassesData(
    LoadClassesData event,
    Emitter<ClassesState> emit,
  ) async {
    emit(const ClassesLoading());
    try {
      final classes = await _classService.getClassesByDepartment(event.departmentId);
      emit(ClassesLoaded(
        classes: classes,
        departmentName: event.departmentName,
        departmentId: event.departmentId,
      ));
    } catch (e) {
      emit(ClassesError(message: 'Không thể tải danh sách lớp: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshClassesData(
    RefreshClassesData event,
    Emitter<ClassesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ClassesLoaded) return;

    try {
      final classes = await _classService.getClassesByDepartment(currentState.departmentId);
      emit(currentState.copyWith(classes: classes));
    } catch (e) {
      emit(const ClassesError(message: 'Không thể làm mới dữ liệu'));
    }
  }
}