import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Initial State
class AuthInitial extends AuthState {}

// Loading States
class AuthLoading extends AuthState {}

class SignInLoading extends AuthState {}

class SignUpLoading extends AuthState {}

class GoogleSignInLoading extends AuthState {}

class PasswordResetLoading extends AuthState {}

// Success States
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class SignUpSuccess extends AuthState {
  final UserEntity user;

  const SignUpSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class PasswordResetSuccess extends AuthState {
  final String email;

  const PasswordResetSuccess({required this.email});

  @override
  List<Object> get props => [email];
}

class EmailVerificationSent extends AuthState {}

// Error States
class AuthError extends AuthState {
  final String message;
  final String code;

  const AuthError({required this.message, required this.code});

  @override
  List<Object> get props => [message, code];
}

class SignInError extends AuthError {
  const SignInError({required super.message, required super.code});
}

class SignUpError extends AuthError {
  const SignUpError({required super.message, required super.code});
}

class GoogleSignInError extends AuthError {
  const GoogleSignInError({required super.message, required super.code});
}

class PasswordResetError extends AuthError {
  const PasswordResetError({required super.message, required super.code});
}