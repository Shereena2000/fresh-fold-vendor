import 'package:flutter/material.dart';
import 'package:fresh_fold_shop_keeper/Settings/utils/p_pages.dart';

import '../../model/client_model.dart';
import '../../model/shedule_model.dart';
import '../../view_model/order_view_model.dart';
import 'order_card.dart';

class ResponsiveOrderList extends StatelessWidget {
  final List<ScheduleModel> orders;
  final ShopkeeperOrderViewModel viewModel;

  const ResponsiveOrderList({
    super.key,
    required this.orders,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isWeb = screenWidth > 900;
        final isTablet = screenWidth > 600 && screenWidth <= 900;
        
        if (isWeb || isTablet) {
          final crossAxisCount = isWeb ? 2 : 1;
          return GridView.builder(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWeb ? 2.5 : 2,
            ),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final schedule = orders[index];
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
                        context,
                        PPages.orderDetailPageUi,
                        arguments: schedule,
                      );
                    },
                  );
                },
              );
            },
          );
        } else {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final schedule = orders[index];
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
                        context,
                        PPages.orderDetailPageUi,
                        arguments: schedule,
                      );
                    },
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

