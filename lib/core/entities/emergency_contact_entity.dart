// lib/core/entities/emergency_contact_entity.dart
import 'package:equatable/equatable.dart';

class EmergencyContact extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final String? email;
  final bool isPrimary;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.email,
    this.isPrimary = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    relationship,
    email,
    isPrimary,
  ];

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    String? email,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
      'email': email,
      'isPrimary': isPrimary,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      relationship: map['relationship'] ?? '',
      email: map['email'],
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  @override
  String toString() {
    return 'EmergencyContact(id: $id, name: $name, phoneNumber: $phoneNumber, relationship: $relationship, email: $email, isPrimary: $isPrimary)';
  }
}