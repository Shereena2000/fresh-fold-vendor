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
    return Scaffold(
      appBar: CustomAppBar(title: "Orders"),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: CustomTabSection(
                  contentHPadding: 10,
                  fontSize: 12,
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
    );
  }
}
