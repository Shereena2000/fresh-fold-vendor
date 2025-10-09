import 'package:cloud_firestore/cloud_firestore.dart';

class PromoModel {
  final String promoId;
  final String imageUrl;
  final String publicId; // Cloudinary public ID for deletion
  final String uploadedBy; // Vendor UID
  final DateTime createdAt;
  final DateTime? updatedAt;

  PromoModel({
    required this.promoId,
    required this.imageUrl,
    required this.publicId,
    required this.uploadedBy,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'promoId': promoId,
      'imageUrl': imageUrl,
      'publicId': publicId,
      'uploadedBy': uploadedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory PromoModel.fromMap(Map<String, dynamic> map) {
    return PromoModel(
      promoId: map['promoId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      publicId: map['publicId'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  PromoModel copyWith({
    String? promoId,
    String? imageUrl,
    String? publicId,
    String? uploadedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromoModel(
      promoId: promoId ?? this.promoId,
      imageUrl: imageUrl ?? this.imageUrl,
      publicId: publicId ?? this.publicId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


