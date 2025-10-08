import 'package:flutter/material.dart';
import 'package:fresh_fold_shop_keeper/Settings/utils/p_pages.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../model/client_model.dart';
import '../../view_model/order_view_model.dart';
import 'order_card.dart';

class PickedRequest extends StatefulWidget {
  const PickedRequest({super.key});

  @override
  State<PickedRequest> createState() => _PickedRequestState();
}

class _PickedRequestState extends State<PickedRequest> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ShopkeeperOrderViewModel>().fetchAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopkeeperOrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: PColors.primaryColor),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: PColors.errorRed),
                SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PColors.errorRed),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.fetchAllOrders(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.pickupRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: PColors.lightGray),
                SizedBox(height: 16),
                Text(
                  'No pickup requests',
                  style: TextStyle(
                    fontSize: 16,
                    color: PColors.darkGray.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: viewModel.pickupRequests.length,
          itemBuilder: (context, index) {
            final schedule = viewModel.pickupRequests[index];
            return FutureBuilder<UserModel?>(
              future: viewModel.getUserDetails(schedule.userId),
              builder: (context, snapshot) {
                String customerName = 'Loading...';
                if (snapshot.hasData && snapshot.data != null) {
                  customerName = snapshot.data!.fullName ?? 'Unknown';
                }
                
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
}
