import 'package:flutter/material.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view/widgets/cancelled.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view/widgets/completed.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view/widgets/confirmed.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view/widgets/deliverd.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view/widgets/picked_request.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view/widgets/picked_up.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view/widgets/proccessing.dart';
import 'package:fresh_fold_shop_keeper/Features/order_mangement/view/widgets/ready_to_deliver.dart';

import '../../../Settings/common/widgets/custom_app_bar.dart';
import '../../../Settings/common/widgets/custom_tab_section.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    
    return Scaffold(
      appBar: CustomAppBar(title: "Orders"),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isWeb ? 1400 : double.infinity,
            ),
            padding: EdgeInsets.all(isWeb ? 24 : 16),
            child: Column(
              children: [
                Expanded(
                  child: CustomTabSection(
                    contentHPadding: isWeb ? 20 : (isTablet ? 15 : 10),
                    fontSize: isWeb ? 14 : 12,
                    tabTitles: const [
                      "Pickup Requests",
                      "Confirmed",
                      "Picked Up",
                      "Processing",
                      "Ready to Deliver",
                      "Deliverved",
                      "Paid",
                      "Cancelled",
                    ],
                    tabContents: const [
                      PickedRequest(),
                      Confirmed(),
                      PickedUp(),
                      Processing(),
                      ReadyToDeliver(),
                      Delivered(),
                      Paid(),
                      Cancelled(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
