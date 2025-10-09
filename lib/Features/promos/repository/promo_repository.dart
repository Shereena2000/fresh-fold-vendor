import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/promo_model.dart';

class PromoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save promo to Firebase
  Future<void> savePromo(PromoModel promo) async {
    try {
      await _firestore
          .collection('promos')
          .doc(promo.promoId)
          .set(promo.toMap());
    } catch (e) {
      throw Exception('Failed to save promo: $e');
    }
  }

  /// Get all promos
  Future<List<PromoModel>> getAllPromos() async {
    try {
      final querySnapshot = await _firestore
          .collection('promos')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PromoModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get promos: $e');
    }
  }

  /// Stream all promos for real-time updates
  Stream<List<PromoModel>> streamAllPromos() {
    return _firestore
        .collection('promos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromoModel.fromMap(doc.data()))
            .toList());
  }

  /// Delete promo
  Future<void> deletePromo(String promoId) async {
    try {
      await _firestore.collection('promos').doc(promoId).delete();
    } catch (e) {
      throw Exception('Failed to delete promo: $e');
    }
  }

  /// Get promos by vendor
  Future<List<PromoModel>> getPromosByVendor(String vendorUid) async {
    try {
      final querySnapshot = await _firestore
          .collection('promos')
          .where('uploadedBy', isEqualTo: vendorUid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PromoModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get vendor promos: $e');
    }
  }
}


