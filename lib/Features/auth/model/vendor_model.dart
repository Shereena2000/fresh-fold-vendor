import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String uid;
  final String? fullName;
  final String? email;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VendorModel({
    required this.uid,
    this.fullName,
    this.email,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'],
      email: map['email'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
                ? (map['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(map['updatedAt']))
          : null,
    );
  }

  VendorModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
