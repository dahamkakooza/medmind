
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  factory UserEntity.fromFirebaseUser(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoURL: user.photoURL,
      dateJoined: user.metadata.creationTime ?? DateTime.now(),
      lastLogin: user.metadata.lastSignInTime,
      emailVerified: user.emailVerified,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      dateJoined: DateTime.parse(json['dateJoined'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'dateJoined': dateJoined.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'emailVerified': emailVerified,
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? dateJoined,
    DateTime? lastLogin,
    bool? emailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  static final empty = UserEntity(
    id: '',
    email: '',
    dateJoined: DateTime(0),
    emailVerified: false,
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  String get formattedDateJoined {
    return '${dateJoined.day}/${dateJoined.month}/${dateJoined.year}';
  }

  String get formattedLastLogin {
    if (lastLogin == null) return 'Never';
    return '${lastLogin!.day}/${lastLogin!.month}/${lastLogin!.year}';
  }

  bool get hasProfilePicture => photoURL != null && photoURL!.isNotEmpty;
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

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
}