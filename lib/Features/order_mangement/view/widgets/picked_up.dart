import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../view_model/order_view_model.dart' show ShopkeeperOrderViewModel;
import 'responsive_order_list.dart';

class PickedUp extends StatefulWidget {
  const PickedUp({super.key});

  @override
  State<PickedUp> createState() => _PickedUpState();
}

class _PickedUpState extends State<PickedUp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShopkeeperOrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(child: CircularProgressIndicator(color: PColors.primaryColor));
        }

        if (viewModel.pickedUp.isEmpty) {
          return _buildEmptyState('No picked up orders', Icons.local_shipping_outlined);
        }

        return ResponsiveOrderList(
          orders: viewModel.pickedUp,
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
