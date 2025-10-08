import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../model/client_model.dart';
import '../../view_model/order_view_model.dart';
import 'order_card.dart';

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

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: viewModel.cancelled.length,
          itemBuilder: (context, index) {
            final schedule = viewModel.cancelled[index];
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
