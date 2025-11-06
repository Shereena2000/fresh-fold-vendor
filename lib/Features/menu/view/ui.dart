import 'package:flutter/material.dart';
import 'package:fresh_fold_shop_keeper/Settings/common/widgets/custom_app_bar.dart';
import 'package:fresh_fold_shop_keeper/Settings/common/widgets/custom_outline_button.dart';
import 'package:fresh_fold_shop_keeper/Settings/utils/p_colors.dart';
import 'package:fresh_fold_shop_keeper/Settings/utils/p_pages.dart';
import 'package:fresh_fold_shop_keeper/Settings/utils/p_text_styles.dart';
import 'package:provider/provider.dart';

import '../../auth/model/vendor_model.dart';
import '../../wrapper/view_model/navigation_provider.dart';
import '../view_model/menu_view_model.dart';
import '../../promos/view/promo_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _handleLogout(context);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final menuViewModel = Provider.of<MenuViewModel>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    bool success = await menuViewModel.logout();

    // Remove loading indicator
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      // Reset navigation to home screen for next login
      if (context.mounted) {
        Provider.of<NavigationProvider>(context, listen: false).resetIndex();
      }

      // Navigate to login screen and remove all previous routes
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', // Replace with your login route name
          (route) => false,
        );
      }
    } else {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(menuViewModel.errorMessage ?? 'Logout failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final horizontalPadding = isWeb ? 32.0 : (isTablet ? 24.0 : 16.0);
    
    return Scaffold(
      appBar: CustomAppBar(title: "Menu"),
      body: StreamBuilder<VendorModel?>(
        stream: context.watch<MenuViewModel>().streamVendorData(),
        builder: (context, snapshot) {
          final menuViewModel = context.read<MenuViewModel>();

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 800 : double.infinity,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                children: [
                // User Profile Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Profile Avatar with Initials
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: PColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              menuViewModel.getInitials(),
                              style: PTextStyles.displayMedium.copyWith(
                                color: PColors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vendor Name
                              Text(
                                menuViewModel.getVendorName(),
                                style: PTextStyles.headlineMedium.copyWith(
                                  color: PColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Vendor Email
                              Text(
                                menuViewModel.getVendorEmail(),
                                style: PTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Menu Items
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        context: context,
                        title: "Manage Promos",
                        icon: Icons.campaign_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PromoManagementScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuTile(
                        context: context,
                        title: "Privacy Policy",
                        icon: Icons.privacy_tip_outlined,
                        onTap: () =>
                            Navigator.pushNamed(context, PPages.privacyPageUi),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Logout Section
                Column(
                  children: [
                    Text("Ready to leave?", style: PTextStyles.bodySmall),
                    const SizedBox(height: 16),
                    CustomOutlineButton(
                      onPressed: () => _showLogoutDialog(context),
                      text: "Log Out",
                    ),
                  ],
                ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600, size: 22),
      title: Text(title, style: PTextStyles.bodyMedium),
      trailing: Icon(Icons.chevron_right, color: PColors.black, size: 24),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: Border(
        bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
    );
  }
}
