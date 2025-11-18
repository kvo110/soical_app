// lib/models/app_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// basic user model
class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime registeredAt;

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.registeredAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: map['role'] ?? '',
      registeredAt:
          (map['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
