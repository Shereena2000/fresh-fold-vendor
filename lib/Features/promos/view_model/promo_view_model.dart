import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/promo_model.dart';
import '../repository/promo_repository.dart';
import '../../service/cloudinary_service.dart';

class PromoViewModel extends ChangeNotifier {
  final PromoRepository _repository = PromoRepository();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  List<PromoModel> _promos = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  String? _successMessage;

  List<PromoModel> get promos => _promos;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Load all promos
  Future<void> loadPromos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _promos = await _repository.getAllPromos();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream all promos
  Stream<List<PromoModel>> streamPromos() {
    return _repository.streamAllPromos();
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to pick image: $e';
      notifyListeners();
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to capture image: $e';
      notifyListeners();
      return null;
    }
  }

  /// Upload promo image
  Future<bool> uploadPromo(File imageFile, String vendorUid) async {
    _isUploading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Upload to Cloudinary
      final uploadResult = await _cloudinaryService.uploadImage(imageFile);
      
      if (uploadResult == null) {
        throw Exception('Failed to upload image to Cloudinary');
      }

      // Create promo model
      final promo = PromoModel(
        promoId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: uploadResult['url'],
        publicId: uploadResult['public_id'],
        uploadedBy: vendorUid,
        createdAt: DateTime.now(),
      );

      // Save to Firebase
      await _repository.savePromo(promo);

      _successMessage = 'Promo uploaded successfully!';
      _isUploading = false;
      
      // Reload promos
      await loadPromos();
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upload promo: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete promo
  Future<bool> deletePromo(PromoModel promo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete from Cloudinary (optional - can be done later via backend)
      await _cloudinaryService.deleteImage(promo.publicId);

      // Delete from Firebase
      await _repository.deletePromo(promo.promoId);

      // Remove from local list
      _promos.removeWhere((p) => p.promoId == promo.promoId);

      _successMessage = 'Promo deleted successfully';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete promo: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}


