import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmailRequested extends AuthEvent {
  const LoginWithEmailRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterWithEmailRequested extends AuthEvent {
  const RegisterWithEmailRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ForgotPasswordRequested extends AuthEvent {
  const ForgotPasswordRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Cập nhật [UserEntity] sau khi làm bài / nhận thưởng nhiệm vụ (đồng bộ Gamification).
class UserProfileRefreshed extends AuthEvent {
  const UserProfileRefreshed(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}
