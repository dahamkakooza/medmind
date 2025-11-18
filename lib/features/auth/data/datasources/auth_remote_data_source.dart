import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signInWithGoogle();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._googleSignIn,
  );

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    print('🔵 [AUTH] Starting email/password sign in for: $email');
    try {
      print('🔵 [AUTH] Calling FirebaseAuth.signInWithEmailAndPassword...');
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🔵 [AUTH] Sign in successful. User: ${userCredential.user?.uid}');
      
      if (userCredential.user == null) {
        print('🔴 [AUTH] Error: User is null after sign in');
        throw const ServerException(message: 'Sign in failed: User is null');
      }

      final userModel = UserModel.fromFirebaseUser(userCredential.user!);
      print('✅ [AUTH] Sign in complete. User email: ${userModel.email}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      print('🔴 [AUTH] FirebaseAuthException: code=${e.code}, message=${e.message}');
      throw ServerException(message: _handleFirebaseAuthError(e));
    } catch (e) {
      print('🔴 [AUTH] Unexpected error: $e');
      throw ServerException(message: 'Sign in failed: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    print('🟢 [AUTH] Starting Google Sign-In...');
    try {
      print('🟢 [AUTH] Calling GoogleSignIn.signIn()...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('🟡 [AUTH] Google sign in cancelled by user');
        throw const ServerException(message: 'Google sign in cancelled');
      }

      print('🟢 [AUTH] Google user obtained: ${googleUser.email}');

      print('🟢 [AUTH] Getting authentication details...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🟢 [AUTH] Access token: ${googleAuth.accessToken?.substring(0, 20)}...');
      print('🟢 [AUTH] ID token: ${googleAuth.idToken?.substring(0, 20)}...');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🟢 [AUTH] Signing in to Firebase with Google credential...');
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      print('🟢 [AUTH] Firebase sign in successful. User: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        print('🔴 [AUTH] Error: User is null after Firebase sign in');
        throw const ServerException(message: 'Google sign in failed: User is null');
      }

      final userModel = UserModel.fromFirebaseUser(userCredential.user!);
      print('✅ [AUTH] Google sign in complete. User email: ${userModel.email}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      print('🔴 [AUTH] FirebaseAuthException: code=${e.code}, message=${e.message}');
      throw ServerException(message: _handleFirebaseAuthError(e));
    } catch (e) {
      print('🔴 [AUTH] Unexpected error during Google sign in: $e');
      throw ServerException(message: 'Google sign in failed: $e');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    print('🟣 [AUTH] Starting sign up for: $email');
    try {
      print('🟣 [AUTH] Calling FirebaseAuth.createUserWithEmailAndPassword...');
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🟣 [AUTH] User created successfully. UID: ${userCredential.user?.uid}');

      if (userCredential.user == null) {
        print('🔴 [AUTH] Error: User is null after sign up');
        throw const ServerException(message: 'Sign up failed: User is null');
      }

      print('🟣 [AUTH] Updating display name to: $displayName');
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        print('🔴 [AUTH] Error: Failed to get updated user');
        throw const ServerException(message: 'Failed to get updated user');
      }

      final userModel = UserModel.fromFirebaseUser(updatedUser);
      print('✅ [AUTH] Sign up complete. User: ${userModel.email}, Name: ${userModel.displayName}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      print('🔴 [AUTH] FirebaseAuthException during sign up: code=${e.code}, message=${e.message}');
      throw ServerException(message: _handleFirebaseAuthError(e));
    } catch (e) {
      print('🔴 [AUTH] Unexpected error during sign up: $e');
      throw ServerException(message: 'Sign up failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw ServerException(message: 'Sign out failed: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(message: _handleFirebaseAuthError(e));
    } catch (e) {
      throw ServerException(message: 'Password reset failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      throw ServerException(message: 'Failed to get current user: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
