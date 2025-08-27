import 'package:equatable/equatable.dart';
import '../../../core/models/class_model.dart';

abstract class ClassesState extends Equatable {
  const ClassesState();

  @override
  List<Object?> get props => [];
}

class ClassesInitial extends ClassesState {
  const ClassesInitial();
}

class ClassesLoading extends ClassesState {
  const ClassesLoading();
}

class ClassesLoaded extends ClassesState {
  final List<ClassModel> classes;
  final String departmentName;
  final int departmentId;

  const ClassesLoaded({
    required this.classes,
    required this.departmentName,
    required this.departmentId,
  });

  @override
  List<Object?> get props => [classes, departmentName, departmentId];

  ClassesLoaded copyWith({
    List<ClassModel>? classes,
    String? departmentName,
    int? departmentId,
  }) {
    return ClassesLoaded(
      classes: classes ?? this.classes,
      departmentName: departmentName ?? this.departmentName,
      departmentId: departmentId ?? this.departmentId,
    );
  }

  int get totalClasses => classes.length;
  bool get hasClasses => classes.isNotEmpty;
}

class ClassesError extends ClassesState {
  final String message;

  const ClassesError({required this.message});

  @override
  List<Object?> get props => [message];
}