import 'package:flutter/material.dart';
import 'package:fresh_fold_shop_keeper/Settings/common/widgets/custom_elevated_button.dart';
import 'package:fresh_fold_shop_keeper/Settings/constants/sized_box.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../Settings/utils/p_colors.dart';
import '../../order_mangement/model/client_model.dart';
import '../../order_mangement/model/shedule_model.dart';
import '../../order_mangement/view_model/order_view_model.dart';
import '../../PriceList/view_model/price_view.model.dart';
import '../model/billing_item.dart';
import '../view_model.dart/oder_detail_view_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final ScheduleModel schedule;

  const OrderDetailScreen({super.key, required this.schedule});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  UserModel? customer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCustomerDetails();
    await _loadPriceItems();
  }

  Future<void> _loadCustomerDetails() async {
    final viewModel = context.read<ShopkeeperOrderViewModel>();
    final user = await viewModel.getUserDetails(widget.schedule.userId);
    setState(() {
      customer = user;
    });
  }

  Future<void> _loadPriceItems() async {
    final priceViewModel = context.read<PriceViewModel>();
    final billingViewModel = context.read<OrderDetailViewModel>();

    await priceViewModel.loadCategoryItems(
      widget.schedule.serviceType.toLowerCase(),
    );

    final items = priceViewModel.getItemsForCategory(
      widget.schedule.serviceType.toLowerCase(),
    );

    // Initialize billing items in the view model
    billingViewModel.initializeBillingItems(items, widget.schedule.washType);

    // Load existing billing details for THIS specific order
    await billingViewModel.loadBillingDetails(
      widget.schedule.userId,
      widget.schedule.scheduleId,
    );

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _handleSetPayment(OrderDetailViewModel billingViewModel) async {
    // Check if items are added
    if (billingViewModel.addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add items to the bill first'),
          backgroundColor: PColors.errorRed,
        ),
      );
      return;
    }

    // Show confirmation dialog for THIS specific order
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Payment Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: ${widget.schedule.scheduleId}',
              style: TextStyle(fontSize: 12, color: PColors.darkGray),
            ),
            SizedBox(height: 12),
            Text('Total Items: ${billingViewModel.addedItems.length}'),
            SizedBox(height: 8),
            Text(
              'Total Amount: ₹${billingViewModel.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PColors.primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This will send a payment request to the customer for this order.',
              style: TextStyle(fontSize: 13, color: PColors.darkGray),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Save billing details for THIS specific order
    final success = await billingViewModel.saveBillingDetails(
      userId: widget.schedule.userId,
      scheduleId: widget.schedule.scheduleId,
      serviceType: widget.schedule.serviceType,
      washType: widget.schedule.washType,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment request sent successfully!'),
          backgroundColor: PColors.successGreen,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              billingViewModel.errorMessage ?? 'Failed to save payment'),
          backgroundColor: PColors.errorRed,
        ),
      );
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final viewModel = context.read<ShopkeeperOrderViewModel>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    await viewModel.updateOrderStatus(
      widget.schedule.userId,
      widget.schedule.scheduleId,
      newStatus,
    );

    Navigator.pop(context); // Close loading dialog
    Navigator.pop(context); // Go back to list

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated successfully'),
        backgroundColor: PColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: PColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<OrderDetailViewModel>(
              builder: (context, billingViewModel, child) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Order Details Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              PColors.primaryColor,
                              PColors.secondoryColor,
                            ],
                          ),
                        ),
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildInfoRow(
                              'Schedule ID',
                              widget.schedule.scheduleId,
                              Icons.tag,
                            ),
                            _buildInfoRow(
                              'Status',
                              widget.schedule.status.toUpperCase(),
                              Icons.info_outline,
                            ),
                            _buildInfoRow(
                              'Service Type',
                              _formatServiceType(widget.schedule.serviceType),
                              Icons.star_outline,
                            ),
                            _buildInfoRow(
                              'Wash Type',
                              _formatWashType(widget.schedule.washType),
                              Icons.local_laundry_service,
                            ),
                            _buildInfoRow(
                              'Pickup Date',
                              DateFormat(
                                'dd MMM yyyy',
                              ).format(widget.schedule.pickupDate),
                              Icons.calendar_today,
                            ),
                            _buildInfoRow(
                              'Time Slot',
                              widget.schedule.timeSlot,
                              Icons.access_time,
                            ),
                            _buildInfoRow(
                              'Pickup Location',
                              widget.schedule.pickupLocation,
                              Icons.location_on,
                              isAddress: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Customer Details Section
                      if (customer != null) ...[
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: PColors.lightGray,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: PColors.primaryColor.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Customer Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: PColors.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 16),
                                _buildDetailRow(
                                  'Name',
                                  customer!.fullName ?? 'N/A',
                                  Icons.person,
                                ),
                                _buildDetailRow(
                                  'Phone',
                                  customer!.phoneNumber,
                                  Icons.phone,
                                ),
                                _buildDetailRow(
                                  'Email',
                                  customer!.email ?? 'N/A',
                                  Icons.email,
                                ),
                                _buildDetailRow(
                                  'City',
                                  customer!.city ?? 'N/A',
                                  Icons.location_city,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 16),

                      // Billing Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: PColors.lightGray,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: PColors.primaryColor.withOpacity(0.08),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Billing Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: PColors.primaryColor,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: PColors.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _formatServiceType(
                                        widget.schedule.serviceType,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: PColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                _formatWashType(widget.schedule.washType),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: PColors.darkGray.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 16),

                              // Add Item Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _showAddItemDialog,
                                  icon: Icon(Icons.add_circle_outline),
                                  label: Text('Add Item to Bill'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: PColors.primaryColor,
                                    side: BorderSide(
                                      color: PColors.primaryColor,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),
                              Divider(color: PColors.lightGray),
                              SizedBox(height: 12),

                              // Items List (only items with quantity > 0)
                              ...billingViewModel.billingItems
                                  .asMap()
                                  .entries
                                  .where((entry) => entry.value.quantity > 0)
                                  .map((entry) {
                                    int index = entry.key;
                                    BillingItem item = entry.value;
                                    return _buildBillingItemRow(item, index);
                                  })
                                  .toList(),

                              if (billingViewModel.addedItems.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 48,
                                          color: PColors.darkGray.withOpacity(
                                            0.3,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'No items added yet',
                                          style: TextStyle(
                                            color: PColors.darkGray.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Tap "Add Item to Bill" to get started',
                                          style: TextStyle(
                                            color: PColors.darkGray.withOpacity(
                                              0.4,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              SizedBox(height: 16),
                              Divider(color: PColors.lightGray, thickness: 2),
                              SizedBox(height: 12),

                              // Total Section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: PColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    '₹${billingViewModel.totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: PColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Payment Button - Works for THIS specific order only
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _buildPaymentButton(billingViewModel),
                      ),

                      SizeBoxH(16),
                      // Status USpdate Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: PColors.lightGray,
                              width: 1.5,
                            ),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Order Status',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: PColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildStatusButton(
                                'Confirm Order',
                                'confirmed',
                                Colors.blue,
                              ),
                              _buildStatusButton(
                                'Mark as Picked Up',
                                'picked_up',
                                Colors.orange,
                              ),
                              _buildStatusButton(
                                'Start Processing',
                                'processing',
                                Colors.purple,
                              ),
                              _buildStatusButton(
                                'Ready to Deliver',
                                'ready',
                                Colors.teal,
                              ),
                              _buildStatusButton(
                                'Mark as Delivered',
                                'delivered',
                                Colors.indigo,
                              ),
                              _buildStatusButton(
                                'Mark as Paid',
                                'paid',
                                PColors.successGreen,
                              ),
                              _buildStatusButton(
                                'Cancel Order',
                                'cancelled',
                                PColors.errorRed,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isAddress = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isAddress
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: isAddress ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: PColors.primaryColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: PColors.darkGray.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, String status, Color color) {
    final currentStatus = widget.schedule.status;
    final isCurrentStatus = currentStatus == status;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isCurrentStatus
              ? null
              : () => _showConfirmDialog(label, status),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentStatus ? PColors.lightGray : color,
            disabledBackgroundColor: PColors.lightGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCurrentStatus)
                Icon(Icons.check_circle, size: 20, color: PColors.darkGray)
              else
                Icon(Icons.arrow_forward, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                isCurrentStatus ? 'Current Status' : label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCurrentStatus ? PColors.darkGray : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(String label, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Status Update'),
        content: Text('Are you sure you want to $label?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _formatServiceType(String type) {
    switch (type.toLowerCase()) {
      case 'regular':
        return 'Regular';
      case 'express':
        return 'Express';
      case 'premium':
        return 'Premium';
      default:
        return type;
    }
  }

  String _formatWashType(String type) {
    switch (type.toLowerCase()) {
      case 'dry_clean':
        return 'Dry Cleaning & Steam Press';
      case 'wash_press':
        return 'Wash & Steam Press';
      case 'press_only':
        return 'Steam Press Only';
      default:
        return type;
    }
  }

  Widget _buildBillingItemRow(BillingItem item, int index) {
    final billingViewModel = context.read<OrderDetailViewModel>();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.priceItem.itemName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: PColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${item.unitPrice.toStringAsFixed(2)} per item',
                      style: TextStyle(
                        fontSize: 12,
                        color: PColors.darkGray.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // Remove button
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => billingViewModel.updateQuantity(index, 0),
                color: PColors.errorRed,
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                tooltip: 'Remove item',
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: PColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 18),
                      onPressed: item.quantity > 1
                          ? () => billingViewModel.updateQuantity(
                              index,
                              item.quantity - 1,
                            )
                          : null,
                      color: PColors.primaryColor,
                      constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      constraints: BoxConstraints(minWidth: 40),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: PColors.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 18),
                      onPressed: () => billingViewModel.updateQuantity(
                        index,
                        item.quantity + 1,
                      ),
                      color: PColors.primaryColor,
                      constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              // Subtotal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(
                      fontSize: 11,
                      color: PColors.darkGray.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '₹${item.itemTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final billingViewModel = context.read<OrderDetailViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _AddItemBottomSheet(billingViewModel: billingViewModel),
    );
  }

  // Payment button that works for THIS current order only
  Widget _buildPaymentButton(OrderDetailViewModel billingViewModel) {
    String buttonText;
    List<Color>? gradientColors;
    bool isDisabled = false;
    VoidCallback? onPressed;

    final paymentStatus = billingViewModel.paymentStatus;
    final hasItems = billingViewModel.addedItems.isNotEmpty;

    switch (paymentStatus) {
      case 'pay_request':
        buttonText = 'Payment Request Sent';
        gradientColors = [Colors.orange, Colors.deepOrange];
        isDisabled = true;
        break;
      case 'paid':
        buttonText = 'Payment Completed ✓';
        gradientColors = [
          PColors.successGreen,
          PColors.successGreen.withOpacity(0.7)
        ];
        isDisabled = true;
        break;
      case 'cancelled':
        buttonText = 'Payment Cancelled';
        gradientColors = [PColors.errorRed, PColors.errorRed.withOpacity(0.7)];
        isDisabled = true;
        break;
      default:
        buttonText = hasItems ? 'Set Payment Amount' : 'Add Items First';
        isDisabled = !hasItems;
        gradientColors = null;
    }

    onPressed = isDisabled ? null : () => _handleSetPayment(billingViewModel);

    return CustomElavatedTextButton(
      text: buttonText,
      onPressed: billingViewModel.isSaving ? null : onPressed,
      gradientColors:
          isDisabled ? [PColors.lightGray, PColors.lightGray] : gradientColors,
      icon: billingViewModel.isSaving
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : paymentStatus == 'paid'
              ? Icon(Icons.check_circle, color: Colors.white, size: 20)
              : paymentStatus == 'pay_request'
                  ? Icon(Icons.pending, color: Colors.white, size: 20)
                  : Icon(Icons.payment, color: Colors.white, size: 20),
    );
  }
}

class _AddItemBottomSheet extends StatefulWidget {
  final OrderDetailViewModel billingViewModel;

  const _AddItemBottomSheet({required this.billingViewModel});

  @override
  State<_AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<_AddItemBottomSheet> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<int, BillingItem>> get filteredItems {
    final entries = widget.billingViewModel.billingItems
        .asMap()
        .entries
        .toList();
    if (searchQuery.isEmpty) return entries;

    return entries.where((entry) {
      return entry.value.priceItem.itemName.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderDetailViewModel>(
      builder: (context, billingViewModel, child) {
        final filteredList = filteredItems;

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Item',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: PColors.primaryColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: PColors.darkGray,
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search items...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: PColors.primaryColor,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: PColors.scaffoldColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Items count
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredList.length} items',
                          style: TextStyle(
                            fontSize: 13,
                            color: PColors.darkGray.withOpacity(0.7),
                          ),
                        ),
                        if (searchQuery.isNotEmpty && filteredList.isEmpty)
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 13,
                              color: PColors.errorRed,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),
                  Divider(height: 1),

                  // Items list
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: PColors.darkGray.withOpacity(0.3),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  searchQuery.isEmpty
                                      ? 'No items available'
                                      : 'No items match "${searchQuery}"',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: PColors.darkGray.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: filteredList.length,
                            itemBuilder: (context, listIndex) {
                              final entry = filteredList[listIndex];
                              final index = entry.key;
                              final item = entry.value;

                              return _buildSelectableItem(item, index);
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectableItem(BillingItem item, int index) {
    final isAdded = item.quantity > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isAdded ? PColors.primaryColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdded
              ? PColors.primaryColor.withOpacity(0.3)
              : PColors.lightGray,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          item.priceItem.itemName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: PColors.primaryColor,
          ),
        ),
        subtitle: Text(
          '₹${item.unitPrice.toStringAsFixed(2)} per item',
          style: TextStyle(
            fontSize: 13,
            color: PColors.darkGray.withOpacity(0.6),
          ),
        ),
        trailing: isAdded
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Added (${item.quantity})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : Icon(Icons.add_circle_outline, color: PColors.primaryColor),
        onTap: () {
          if (isAdded) {
            // If already added, increment quantity
            widget.billingViewModel.updateQuantity(index, item.quantity + 1);
          } else {
            // Add item with quantity 1
            widget.billingViewModel.updateQuantity(index, 1);
          }
        },
      ),
    );
  }
}
