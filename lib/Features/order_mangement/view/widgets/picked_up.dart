import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../model/client_model.dart';
import '../../view_model/order_view_model.dart' show ShopkeeperOrderViewModel;
import 'order_card.dart';

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

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: viewModel.pickedUp.length,
          itemBuilder: (context, index) {
            final schedule = viewModel.pickedUp[index];
            return FutureBuilder<UserModel?>(
              future: viewModel.getUserDetails(schedule.userId),
              builder: (context, snapshot) {
                String customerName = snapshot.hasData && snapshot.data != null
                    ? snapshot.data!.fullName ?? 'Unknown'
                    : 'Loading...';
                
                return ShopkeeperOrderCard(
                  schedule: schedule,
                  customerName: customerName,
                  onModify: () {
                      Navigator.pushNamed(
                  context,PPages.orderDetailPageUi,arguments: schedule
                    );
                  },
                );
              },
            );
          },
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
