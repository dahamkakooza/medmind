import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Email & Password Events
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, password, displayName];
}

// Google Sign-In Event
class GoogleSignInRequested extends AuthEvent {}

// Sign Out Event
class SignOutRequested extends AuthEvent {}

// Password Reset Event
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

// Check Authentication Status
class AuthCheckRequested extends AuthEvent {}

// Email Verification
class SendEmailVerificationRequested extends AuthEvent {}