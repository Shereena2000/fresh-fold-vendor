import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Settings/utils/p_colors.dart';
import '../../order_mangement/view_model/order_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to real-time order updates
    Future.microtask(() {
      context.read<ShopkeeperOrderViewModel>().startListeningToOrders();
    });
  }

  @override
  void dispose() {
    // Stop listening when screen is disposed
    context.read<ShopkeeperOrderViewModel>().stopListeningToOrders();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    
    return Scaffold(
      backgroundColor: PColors.scaffoldColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8),
            // Real-time indicator
            Icon(Icons.circle, size: 8, color: Colors.greenAccent),
          ],
        ),
        backgroundColor: PColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Manual refresh - restart the listener
              context.read<ShopkeeperOrderViewModel>().startListeningToOrders();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<ShopkeeperOrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: PColors.primaryColor),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Restart real-time listener on pull-to-refresh
              viewModel.startListeningToOrders();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 1400 : double.infinity,
                  ),
                  padding: EdgeInsets.all(isWeb ? 32 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeCard(),

                      SizedBox(height: 24),

                      // Quick Stats Header
                      Text(
                        'Order Statistics',
                        style: TextStyle(
                          fontSize: isWeb ? 24 : 20,
                          fontWeight: FontWeight.w700,
                          color: PColors.primaryColor,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Active Orders Grid - Responsive
                      _buildResponsiveStatCards(
                        viewModel,
                        isWeb,
                        isTablet,
                      ),

                      SizedBox(height: 24),

                      // Completed Section
                      Text(
                        'Completed & Cancelled',
                        style: TextStyle(
                          fontSize: isWeb ? 24 : 20,
                          fontWeight: FontWeight.w700,
                          color: PColors.primaryColor,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Completed cards grid
                      _buildCompletedCardsGrid(viewModel, isWeb, isTablet),

                      SizedBox(height: 24),

                      // Total Orders Summary
                      _buildTotalSummaryCard(viewModel),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveStatCards(
    ShopkeeperOrderViewModel viewModel,
    bool isWeb,
    bool isTablet,
  ) {
    final crossAxisCount = isWeb ? 3 : (isTablet ? 2 : 1);
    
    final statCards = [
      {
        'title': 'Pickup Requests',
        'count': viewModel.pickupRequests.length.toString(),
        'icon': Icons.pending_actions,
        'color': Colors.orange,
      },
      {
        'title': 'Confirmed Orders',
        'count': viewModel.confirmed.length.toString(),
        'icon': Icons.check_circle_outline,
        'color': Colors.blue,
      },
      {
        'title': 'Picked Up',
        'count': viewModel.pickedUp.length.toString(),
        'icon': Icons.local_shipping_outlined,
        'color': Colors.purple,
      },
      {
        'title': 'Processing',
        'count': viewModel.processing.length.toString(),
        'icon': Icons.settings,
        'color': Colors.indigo,
      },
      {
        'title': 'Ready to Deliver',
        'count': viewModel.readyToDeliver.length.toString(),
        'icon': Icons.inventory_2_outlined,
        'color': Colors.teal,
      },
      {
        'title': 'Delivered',
        'count': viewModel.delivered.length.toString(),
        'icon': Icons.done_all,
        'color': Colors.green,
      },
    ];

    if (isWeb || isTablet) {
      // Grid layout for web and tablet
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isWeb ? 2.5 : 2,
        ),
        itemCount: statCards.length,
        itemBuilder: (context, index) {
          final card = statCards[index];
          return _buildStatCard(
            card['title'] as String,
            card['count'] as String,
            card['icon'] as IconData,
            card['color'] as Color,
            (card['color'] as Color).withOpacity(0.1),
          );
        },
      );
    } else {
      // Column layout for mobile
      return Column(
        children: statCards.map((card) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _buildStatCard(
              card['title'] as String,
              card['count'] as String,
              card['icon'] as IconData,
              card['color'] as Color,
              (card['color'] as Color).withOpacity(0.1),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildCompletedCardsGrid(
    ShopkeeperOrderViewModel viewModel,
    bool isWeb,
    bool isTablet,
  ) {
    if (isWeb || isTablet) {
      final crossAxisCount = isWeb ? 4 : 2;
      return GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isWeb ? 1.2 : 1,
        children: [
          _buildMiniStatCard(
            'Paid',
            viewModel.paid.length.toString(),
            Icons.payment,
            PColors.successGreen,
          ),
          _buildMiniStatCard(
            'Cancelled',
            viewModel.cancelled.length.toString(),
            Icons.cancel,
            PColors.errorRed,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buildMiniStatCard(
              'Paid',
              viewModel.paid.length.toString(),
              Icons.payment,
              PColors.successGreen,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildMiniStatCard(
              'Cancelled',
              viewModel.cancelled.length.toString(),
              Icons.cancel,
              PColors.errorRed,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PColors.primaryColor, PColors.secondoryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.store, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      'Fresh Fold Manager',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manage all your laundry orders in one place',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColors.lightGray, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:    
                      Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color:     Colors.blue,
                      size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: PColors.darkGray.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color:     Colors.blue,
                     
                  ),
                ),
              ],
            ),
          ),
      
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(ShopkeeperOrderViewModel viewModel) {
    final totalOrders =
        viewModel.pickupRequests.length +
        viewModel.confirmed.length +
        viewModel.pickedUp.length +
        viewModel.processing.length +
        viewModel.readyToDeliver.length +
        viewModel.delivered.length +
        viewModel.paid.length +
        viewModel.cancelled.length;

    final activeOrders =
        viewModel.pickupRequests.length +
        viewModel.confirmed.length +
        viewModel.pickedUp.length +
        viewModel.processing.length +
        viewModel.readyToDeliver.length +
        viewModel.delivered.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PColors.lightBlue.withOpacity(0.3),
            PColors.primaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PColors.lightBlue.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Total Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PColors.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      totalOrders.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: PColors.primaryColor,
                      ),
                    ),
                    Text(
                      'Total Orders',
                      style: TextStyle(
                        fontSize: 13,
                        color: PColors.darkGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 1.5,
                color: PColors.primaryColor.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      activeOrders.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Active Orders',
                      style: TextStyle(
                        fontSize: 13,
                        color: PColors.darkGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
