import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final bool emailVerified;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String>? healthConditions;
  final List<String>? allergies;
  final EmergencyContactModel? emergencyContact;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.dateJoined,
    this.lastLogin,
    required this.emailVerified,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.healthConditions,
    this.allergies,
    this.emergencyContact,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      dateJoined: DateTime.parse(json['dateJoined'] as String),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      healthConditions: json['healthConditions'] != null
          ? List<String>.from(json['healthConditions'] as List)
          : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : null,
      emergencyContact: json['emergencyContact'] != null
          ? EmergencyContactModel.fromJson(json['emergencyContact'] as Map<String, dynamic>)
          : null,
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
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'healthConditions': healthConditions,
      'allergies': allergies,
      'emergencyContact': emergencyContact?.toJson(),
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? dateJoined,
    DateTime? lastLogin,
    bool? emailVerified,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? healthConditions,
    List<String>? allergies,
    EmergencyContactModel? emergencyContact,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      healthConditions: healthConditions ?? this.healthConditions,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
    );
  }

  static final empty = UserProfileModel(
    id: '',
    email: '',
    displayName: '',
    dateJoined: DateTime(0),
    emailVerified: false,
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoURL,
        dateJoined,
        lastLogin,
        emailVerified,
        phoneNumber,
        dateOfBirth,
        gender,
        healthConditions,
        allergies,
        emergencyContact,
      ];
}

class EmergencyContactModel extends Equatable {
  final String name;
  final String phoneNumber;
  final String relationship;
  final String? email;

  const EmergencyContactModel({
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.email,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: json['relationship'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'email': email,
    };
  }

  EmergencyContactModel copyWith({
    String? name,
    String? phoneNumber,
    String? relationship,
    String? email,
  }) {
    return EmergencyContactModel(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [name, phoneNumber, relationship, email];
}
