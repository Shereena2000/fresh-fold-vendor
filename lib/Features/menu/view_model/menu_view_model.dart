import 'package:flutter/material.dart';

import '../../auth/model/vendor_model.dart';
import '../../auth/view_model.dart/auth_view_model.dart';

class MenuViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;

  MenuViewModel(this._authViewModel) {
    // Load vendor data when view model is created
    loadVendorData();
  }

  VendorModel? get currentVendor => _authViewModel.currentVendor;
  bool get isLoading => _authViewModel.isLoading;
  String? get errorMessage => _authViewModel.errorMessage;

  // Load vendor data
  Future<void> loadVendorData() async {
    await _authViewModel.loadVendorData();
    notifyListeners();
  }

  // Stream vendor data for real-time updates
  Stream<VendorModel?> streamVendorData() {
    return _authViewModel.streamVendorData();
  }

  // Logout
  Future<bool> logout() async {
    return await _authViewModel.signOut();
  }

  // Get vendor display name
  String getVendorName() {
    return currentVendor?.fullName ?? 'User';
  }

  // Get vendor email
  String getVendorEmail() {
    return currentVendor?.email ?? 'No email';
  }

  // Get initials from vendor name
  String getInitials() {
    String name = getVendorName();
    List<String> nameParts = name.trim().split(' ');
    
    if (nameParts.isEmpty) return 'U';

    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    return (nameParts[0][0] + nameParts[nameParts.length - 1][0])
        .toUpperCase();
  }
}

