import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../view_model/order_view_model.dart';
import 'responsive_order_list.dart';

class Paid extends StatelessWidget {
  const Paid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopkeeperOrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return  Center(child: CircularProgressIndicator(color: PColors.primaryColor));
        }

        if (viewModel.paid.isEmpty) {
          return _buildEmptyState('No paid orders', Icons.payment_outlined);
        }

        return ResponsiveOrderList(
          orders: viewModel.paid,
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
          const SizedBox(height: 16),
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
