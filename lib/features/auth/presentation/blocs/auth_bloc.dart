import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignInWithGoogle signInWithGoogle;
  final SignUp signUp;
  final SignOut signOut;
  final AuthRepository authRepository;

  AuthBloc({
    required this.signInWithEmailAndPassword,
    required this.signInWithGoogle,
    required this.signUp,
    required this.signOut,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
  }

  void _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(SignInLoading());
    final result = await signInWithEmailAndPassword.call(
      SignInParams(email: event.email, password: event.password),
    );
    _handleAuthResult(result, emit);
  }

  void _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(SignUpLoading());
    final result = await signUp.call(
      SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );
    _handleAuthResult(result, emit, isSignUp: true);
  }

  void _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(GoogleSignInLoading());
    final result = await signInWithGoogle.call(const NoParams());
    _handleAuthResult(result, emit);
  }

  void _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await signOut.call(const NoParams()); // ADDED const

    result.fold(
      (failure) =>
          emit(AuthError(message: failure.message, code: failure.code)),
      (_) => emit(Unauthenticated()),
    );
  }

  void _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(PasswordResetLoading());
    final result = await authRepository.sendPasswordResetEmail(event.email);
    result.fold(
          (failure) => emit(PasswordResetError(message: failure.message, code: '')),
          (_) => emit(PasswordResetSuccess(email: event.email)),
    );
  }

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    print('🔄 AuthBloc - Checking authentication status...');

    // Add delay to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    final currentUser = await authRepository.getCurrentUser();
    print('👤 AuthBloc - Current user: $currentUser');
    print('👤 AuthBloc - User ID: ${currentUser?.id}');

    // FIXED: Remove the empty ID check - only check for null
    if (currentUser != null) {
      print('✅ AuthBloc - User authenticated, emitting Authenticated state');
      emit(Authenticated(user: currentUser));
    } else {
      print('❌ AuthBloc - No user found, emitting Unauthenticated state');
      emit(Unauthenticated());
    }
  }

  void _onSendEmailVerificationRequested(SendEmailVerificationRequested event, Emitter<AuthState> emit) async {
    emit(EmailVerificationLoading());
    final result = await authRepository.sendEmailVerification();
    result.fold(
          (failure) => emit(EmailVerificationError(message: failure.message, code: '')),
          (_) => emit(EmailVerificationSent()),
    );
  }

  void _handleAuthResult(
    Either<Failure, dynamic> result,
    Emitter<AuthState> emit, {
    bool isSignUp = false,
  }) {
    result.fold(
      (failure) {
        if (isSignUp) {
          emit(SignUpError(message: failure.message, code: ''));
        } else {
          emit(SignInError(message: failure.message, code: ''));
        }
      },
      (user) {
        if (isSignUp) {
          emit(SignUpSuccess(user: user));
          // Delay navigation to show success state
          Future.delayed(const Duration(milliseconds: 1500), () {
            emit(Authenticated(user: user));
          });
        } else {
          emit(Authenticated(user: user));
        }
      },
    );
  }
}