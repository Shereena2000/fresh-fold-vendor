import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../Settings/utils/p_colors.dart';
import '../../order_mangement/model/client_model.dart';
import '../../order_mangement/model/shedule_model.dart';
import '../../order_mangement/view_model/order_view_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final ScheduleModel schedule;

  const OrderDetailScreen({
    super.key,
    required this.schedule,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  UserModel? customer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    final viewModel = context.read<ShopkeeperOrderViewModel>();
    final user = await viewModel.getUserDetails(widget.schedule.userId);
    setState(() {
      customer = user;
      isLoading = false;
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    final viewModel = context.read<ShopkeeperOrderViewModel>();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
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
          : SingleChildScrollView(
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
                          DateFormat('dd MMM yyyy').format(widget.schedule.pickupDate),
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
                          border: Border.all(color: PColors.lightGray, width: 1.5),
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
                            _buildDetailRow('Name', customer!.fullName ?? 'N/A', Icons.person),
                            _buildDetailRow('Phone', customer!.phoneNumber, Icons.phone),
                            _buildDetailRow('Email', customer!.email ?? 'N/A', Icons.email),
                            _buildDetailRow('City', customer!.city ?? 'N/A', Icons.location_city),
                          ],
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 16),

                  // Status Update Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: PColors.lightGray, width: 1.5),
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
                          _buildStatusButton('Confirm Order', 'confirmed', Colors.blue),
                          _buildStatusButton('Mark as Picked Up', 'picked_up', Colors.orange),
                          _buildStatusButton('Start Processing', 'processing', Colors.purple),
                          _buildStatusButton('Ready to Deliver', 'ready', Colors.teal),
                          _buildStatusButton('Mark as Delivered', 'delivered', Colors.indigo),
                          _buildStatusButton('Mark as Paid', 'paid', PColors.successGreen),
                          _buildStatusButton('Cancel Order', 'cancelled', PColors.errorRed),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isAddress = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
      case 'regular': return 'Regular';
      case 'express': return 'Express';
      case 'premium': return 'Premium';
      default: return type;
    }
  }

  String _formatWashType(String type) {
    switch (type.toLowerCase()) {
      case 'dry_clean': return 'Dry Cleaning & Steam Press';
      case 'wash_press': return 'Wash & Steam Press';
      case 'press_only': return 'Steam Press Only';
      default: return type;
    }
  }
}
