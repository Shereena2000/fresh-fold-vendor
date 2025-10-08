import 'package:flutter/material.dart';
import '../model/billing_item.dart';
import '../../PriceList/model/price_item_model.dart';

class OrderDetailViewModel extends ChangeNotifier {
  List<BillingItem> _billingItems = [];
  double _totalAmount = 0.0;

  List<BillingItem> get billingItems => _billingItems;
  double get totalAmount => _totalAmount;

  // Get items that have quantity > 0
  List<BillingItem> get addedItems =>
      _billingItems.where((item) => item.quantity > 0).toList();

  // Initialize billing items from price list
  void initializeBillingItems(
    List<PriceItemModel> priceItems,
    String washType,
  ) {
    _billingItems = priceItems.map((item) {
      double price = _getPriceForWashType(item, washType);
      String priceType = _getPriceTypeForWashType(washType);
      
      return BillingItem(
        priceItem: item,
        priceType: priceType,
        quantity: 0,
        unitPrice: price,
      );
    }).toList();
    
    _calculateTotal();
    notifyListeners();
  }

  // Update quantity for a specific item
  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _billingItems.length && newQuantity >= 0) {
      _billingItems[index].quantity = newQuantity;
      _calculateTotal();
      notifyListeners();
    }
  }

  // Calculate total amount
  void _calculateTotal() {
    _totalAmount = _billingItems.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  // Get price based on wash type
  double _getPriceForWashType(PriceItemModel item, String washType) {
    switch (washType.toLowerCase()) {
      case 'dry_clean':
        return double.tryParse(item.dryWash) ?? 0.0;
      case 'wash_press':
        return double.tryParse(item.wetWash) ?? 0.0;
      case 'press_only':
        return double.tryParse(item.steamPress) ?? 0.0;
      default:
        return 0.0;
    }
  }

  // Get price type string
  String _getPriceTypeForWashType(String washType) {
    switch (washType.toLowerCase()) {
      case 'dry_clean':
        return 'dryWash';
      case 'wash_press':
        return 'wetWash';
      case 'press_only':
        return 'steamPress';
      default:
        return '';
    }
  }

  // Clear all billing items
  void clearBilling() {
    for (var item in _billingItems) {
      item.quantity = 0;
    }
    _calculateTotal();
    notifyListeners();
  }

  // Get billing summary
  Map<String, dynamic> getBillingSummary() {
    return {
      'items': addedItems.map((item) => item.toMap()).toList(),
      'totalAmount': _totalAmount,
      'itemCount': addedItems.length,
      'totalQuantity': addedItems.fold(0, (sum, item) => sum + item.quantity),
    };
  }
}