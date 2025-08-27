import 'package:equatable/equatable.dart';

abstract class ClassesEvent extends Equatable {
  const ClassesEvent();

  @override
  List<Object?> get props => [];
}

class LoadClassesData extends ClassesEvent {
  final int departmentId;
  final String departmentName;

  const LoadClassesData({
    required this.departmentId,
    required this.departmentName,
  });

  @override
  List<Object?> get props => [departmentId, departmentName];
}

class RefreshClassesData extends ClassesEvent {
  const RefreshClassesData();
}