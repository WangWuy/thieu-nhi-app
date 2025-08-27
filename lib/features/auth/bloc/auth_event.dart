import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final UserRole role;
  final String department;
  final String className;
  final String holyName;
  final String fullName;
  final DateTime birthDate;
  final String phone;
  final String address;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.username,
    required this.role,
    required this.department,
    required this.className,
    required this.holyName,
    required this.fullName,
    required this.birthDate,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        username,
        role,
        department,
        className,
        holyName,
        fullName,
        birthDate,
        phone,
        address
      ];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final UserModel? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final UserModel updatedUser;

  const AuthUpdateProfileRequested(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}
