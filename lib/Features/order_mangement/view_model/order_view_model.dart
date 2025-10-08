import 'package:flutter/material.dart';

import '../model/client_model.dart';
import '../model/shedule_model.dart';
import '../repository/order_manage_repository.dart';

class ShopkeeperOrderViewModel extends ChangeNotifier {
  final ShopkeeperOrderRepository _repository = ShopkeeperOrderRepository();

  List<ScheduleModel> _pickupRequests = [];
  List<ScheduleModel> _confirmed = [];
  List<ScheduleModel> _pickedUp = [];
  List<ScheduleModel> _processing = [];
  List<ScheduleModel> _readyToDeliver = [];
  List<ScheduleModel> _delivered = [];
  List<ScheduleModel> _paid = [];
  List<ScheduleModel> _cancelled = [];

  List<ScheduleModel> get pickupRequests => _pickupRequests;
  List<ScheduleModel> get confirmed => _confirmed;
  List<ScheduleModel> get pickedUp => _pickedUp;
  List<ScheduleModel> get processing => _processing;
  List<ScheduleModel> get readyToDeliver => _readyToDeliver;
  List<ScheduleModel> get delivered => _delivered;
  List<ScheduleModel> get paid => _paid;
  List<ScheduleModel> get cancelled => _cancelled;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetch all orders and categorize them
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<ScheduleModel> allOrders = await _repository.getAllOrders();
      _categorizeOrders(allOrders);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Categorize orders by status
  void _categorizeOrders(List<ScheduleModel> allOrders) {
    _pickupRequests = allOrders.where((o) => o.status == 'pending' || o.status == 'pickup_requested').toList();
    _confirmed = allOrders.where((o) => o.status == 'confirmed').toList();
    _pickedUp = allOrders.where((o) => o.status == 'picked_up').toList();
    _processing = allOrders.where((o) => o.status == 'processing').toList();
    _readyToDeliver = allOrders.where((o) => o.status == 'ready').toList();
    _delivered = allOrders.where((o) => o.status == 'delivered').toList();
    _paid = allOrders.where((o) => o.status == 'paid').toList();
    _cancelled = allOrders.where((o) => o.status == 'cancelled').toList();
  }

  /// Update order status
  Future<void> updateOrderStatus(String userId, String scheduleId, String newStatus) async {
    try {
      await _repository.updateOrderStatus(userId, scheduleId, newStatus);
      await fetchAllOrders();
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
      notifyListeners();
    }
  }

  /// Get user details for an order
  Future<UserModel?> getUserDetails(String userId) async {
    try {
      return await _repository.getUserDetails(userId);
    } catch (e) {
      _errorMessage = 'Failed to get user details: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
