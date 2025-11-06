import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../view_model/order_view_model.dart';
import 'responsive_order_list.dart';

class Cancelled extends StatefulWidget {
  const Cancelled({super.key});

  @override
  State<Cancelled> createState() => _CancelledState();
}

class _CancelledState extends State<Cancelled> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShopkeeperOrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(child: CircularProgressIndicator(color: PColors.primaryColor));
        }

        if (viewModel.cancelled.isEmpty) {
          return _buildEmptyState('No cancelled orders', Icons.cancel);
        }

        return ResponsiveOrderList(
          orders: viewModel.cancelled,
          viewModel: viewModel,
        );
      },
    );
  }
  Widget _buildEmptyState(String message, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: PColors.lightGray),
        SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: PColors.darkGray.withOpacity(0.6),
          ),
        ),
      ],
    ),
  );
}
}
