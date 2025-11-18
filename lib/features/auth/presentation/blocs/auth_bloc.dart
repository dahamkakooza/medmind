// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dartz/dartz.dart';
// import '../../domain/usecases/sign_in_with_email_and_password.dart';
// import '../../domain/usecases/sign_in_with_google.dart';
// import '../../domain/usecases/sign_up.dart';
// import '../../domain/usecases/sign_out.dart';
// import '../../../../core/errors/failures.dart';
// import 'auth_event.dart';
// import 'auth_state.dart';
// import '../../../../core/usecases/usecase.dart'; // ADD THIS IMPORT
//
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final SignInWithEmailAndPassword signInWithEmailAndPassword;
//   final SignInWithGoogle signInWithGoogle;
//   final SignUp signUp;
//   final SignOut signOut;
//
//   AuthBloc({
//     required this.signInWithEmailAndPassword,
//     required this.signInWithGoogle,
//     required this.signUp,
//     required this.signOut,
//   }) : super(AuthInitial()) {
//     on<SignInRequested>(_onSignInRequested);
//     on<SignUpRequested>(_onSignUpRequested);
//     on<GoogleSignInRequested>(_onGoogleSignInRequested);
//     on<SignOutRequested>(_onSignOutRequested);
//     on<PasswordResetRequested>(_onPasswordResetRequested);
//     on<AuthCheckRequested>(_onAuthCheckRequested);
//     on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
//   }
//
//   void _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
//     emit(SignInLoading());
//
//     final result = await signInWithEmailAndPassword.call(
//       SignInParams(email: event.email, password: event.password),
//     );
//
//     _handleAuthResult(result, emit);
//   }
//
//   void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
//     emit(SignUpLoading());
//
//     final result = await signUp.call(
//       SignUpParams(
//         email: event.email,
//         password: event.password,
//         displayName: event.displayName,
//       ),
//     );
//
//     _handleAuthResult(result, emit, isSignUp: true);
//   }
//
//   void _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
//     emit(GoogleSignInLoading());
//
//     final result = await signInWithGoogle.call(NoParams());
//
//     _handleAuthResult(result, emit);
//   }
//
//   void _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
//     final result = await signOut.call(NoParams());
//
//     result.fold(
//       (failure) => emit(AuthError(
//         message: failure.message,
//         code: failure.code,
//       )),
//       (_) => emit(Unauthenticated()),
//     );
//   }
//
//   void _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
//     emit(PasswordResetLoading());
//     // Implementation will be added when repository is implemented
//     await Future.delayed(const Duration(seconds: 2)); // Temporary
//     emit(PasswordResetSuccess(email: event.email));
//   }
//
//   void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) {
//     // Implementation will be added when repository is implemented
//     // For now, emit unauthenticated
//     emit(Unauthenticated());
//   }
//
//   void _onSendEmailVerificationRequested(SendEmailVerificationRequested event, Emitter<AuthState> emit) {
//     // Implementation will be added when repository is implemented
//     emit(EmailVerificationSent());
//   }
//
//   void _handleAuthResult(
//     Either<Failure, dynamic> result,
//     Emitter<AuthState> emit, {
//     bool isSignUp = false,
//   }) {
//     result.fold(
//       (failure) {
//         if (isSignUp) {
//           emit(SignUpError(
//             message: failure.message,
//             code: failure.code,
//           ));
//         } else {
//           emit(SignInError(
//             message: failure.message,
//             code: failure.code,
//           ));
//         }
//       },
//       (user) {
//         if (isSignUp) {
//           emit(SignUpSuccess(user: user));
//         } else {
//           emit(Authenticated(user: user));
//         }
//       },
//     );
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart'; // ADDED IMPORT
import '../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_out.dart';
import '../../../../core/errors/failures.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignInWithGoogle signInWithGoogle;
  final SignUp signUp;
  final SignOut signOut;

  AuthBloc({
    required this.signInWithEmailAndPassword,
    required this.signInWithGoogle,
    required this.signUp,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
  }

  void _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(SignInLoading());

    final result = await signInWithEmailAndPassword.call(
      SignInParams(email: event.email, password: event.password),
    );

    _handleAuthResult(result, emit);
  }

  void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
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

  void _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(GoogleSignInLoading());

    final result = await signInWithGoogle.call(const NoParams()); // ADDED const

    _handleAuthResult(result, emit);
  }

  void _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    final result = await signOut.call(const NoParams()); // ADDED const

    result.fold(
          (failure) => emit(AuthError(
        message: failure.message,
        code: failure.code,
      )),
          (_) => emit(Unauthenticated()),
    );
  }

  void _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(PasswordResetLoading());
    // Implementation will be added when repository is implemented
    await Future.delayed(const Duration(seconds: 2)); // Temporary
    emit(PasswordResetSuccess(email: event.email));
  }

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) {
    // Implementation will be added when repository is implemented
    // For now, emit unauthenticated
    emit(Unauthenticated());
  }

  void _onSendEmailVerificationRequested(SendEmailVerificationRequested event, Emitter<AuthState> emit) {
    // Implementation will be added when repository is implemented
    emit(EmailVerificationSent());
  }

  void _handleAuthResult(
      Either<Failure, dynamic> result,
      Emitter<AuthState> emit, {
        bool isSignUp = false,
      }) {
    result.fold(
          (failure) {
        if (isSignUp) {
          emit(SignUpError(
            message: failure.message,
            code: failure.code,
          ));
        } else {
          emit(SignInError(
            message: failure.message,
            code: failure.code,
          ));
        }
      },
          (user) {
        if (isSignUp) {
          emit(SignUpSuccess(user: user));
        } else {
          emit(Authenticated(user: user));
        }
      },
    );
  }
}