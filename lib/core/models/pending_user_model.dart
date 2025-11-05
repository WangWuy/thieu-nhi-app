import 'package:equatable/equatable.dart';
import 'user_model.dart';

class PendingUserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String fullName;
  final String? saintName;
  final String phoneNumber;
  final String address;
  final DateTime? birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PendingUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.fullName,
    this.saintName,
    required this.phoneNumber,
    required this.address,
    this.birthDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  String get displayName {
    if (saintName != null && fullName.isNotEmpty) return '$saintName $fullName';
    if (fullName.isNotEmpty) return fullName;
    return username;
  }

  int get age {
    final now = DateTime.now();
    if (birthDate == null) return 0;
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  PendingUserModel copyWith({
    String? id,
    String? username,
    String? email,
    UserRole? role,
    String? fullName,
    String? saintName,
    String? phoneNumber,
    String? address,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PendingUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      saintName: saintName ?? this.saintName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, username, email, role, fullName, saintName,
    phoneNumber, address, birthDate, createdAt, updatedAt
  ];
}

