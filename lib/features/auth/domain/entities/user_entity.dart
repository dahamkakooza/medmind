import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final bool emailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.dateJoined,
    this.lastLogin,
    required this.emailVerified,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoURL,
    dateJoined,
    lastLogin,
    emailVerified,
  ];

  bool get isAnonymous => id.isEmpty;

  static const empty = UserEntity(
    id: '',
    email: '',
    dateJoined: DateTime(0),
    emailVerified: false,
  );
}