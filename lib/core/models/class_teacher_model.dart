import 'package:equatable/equatable.dart';
import 'package:thieu_nhi_app/core/models/class_model.dart';

class ClassTeacher extends Equatable {
  final String id;
  final int classId;
  final String fullName;
  final String? saintName;
  final bool isPrimary;
  final ClassModel? classInfo;

  ClassTeacher({
    required this.id,
    required this.classId,
    required this.fullName,
    this.saintName,
    required this.isPrimary,
    this.classInfo,
  });

  String get displayName {
    if (saintName != null && saintName!.isNotEmpty) {
      return '$saintName $fullName';
    }
    return fullName;
  }

  @override
  List<Object?> get props => [
        id,
        classId,
        fullName,
        saintName,
        isPrimary,
        classInfo,
      ];
}