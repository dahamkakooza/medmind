import 'package:equatable/equatable.dart';
import '../../../../core/entities/emergency_contact_entity.dart'; // ADD THIS IMPORT

class UserProfileEntity extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLogin;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> healthConditions;
  final List<String> allergies;
  final List<EmergencyContact> emergencyContacts;

  const UserProfileEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoURL,
    required this.createdAt,
    required this.lastLogin,
    this.dateOfBirth,
    this.gender,
    this.healthConditions = const [],
    this.allergies = const [],
    this.emergencyContacts = const [],
  });

  @override
  List<Object?> get props => [
    id,
    displayName,
    email,
    photoURL,
    createdAt,
    lastLogin,
    dateOfBirth,
    gender,
    healthConditions,
    allergies,
    emergencyContacts,
  ];

  UserProfileEntity copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? healthConditions,
    List<String>? allergies,
    List<EmergencyContact>? emergencyContacts,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      healthConditions: healthConditions ?? this.healthConditions,
      allergies: allergies ?? this.allergies,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }

  // Helper methods
  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    return now.year - dateOfBirth!.year;
  }

  bool get hasEmergencyContacts => emergencyContacts.isNotEmpty;

  bool get hasHealthInfo => healthConditions.isNotEmpty || allergies.isNotEmpty;
}