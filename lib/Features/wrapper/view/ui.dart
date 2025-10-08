import 'package:flutter/material.dart';
import 'package:fresh_fold_shop_keeper/Features/menu/view/ui.dart';

import 'package:provider/provider.dart';

import '../../../Settings/utils/p_colors.dart';
import '../../PriceList/view/ui.dart';
import '../../home/view/ui.dart';
import '../../order_mangement/view/ui.dart';
import '../view_model/navigation_provider.dart';

class WrapperScreen extends StatelessWidget {
  WrapperScreen({super.key});

  final List<Widget> _pages = [
    HomeScreen(),
    OrderScreen(),
    PriceListScreen(),

    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(icon: Icons.home, label: 'Home'),
      NavItem(icon: Icons.shopping_bag, label: 'Orders'),
      NavItem(icon: Icons.list_alt, label: 'Price List'),

      NavItem(icon: Icons.menu, label: 'Menu'),
    ];

    return Scaffold(
      body: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return _pages[navigationProvider.selectedIndex];
        },
      ),
      bottomNavigationBar: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, child) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: PColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(navItems.length, (index) {
                final isSelected = navigationProvider.selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    navigationProvider.setSelectedIndex(index);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: isSelected ? 15 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PColors.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          navItems[index].icon,
                          color: isSelected ? PColors.white : PColors.black,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 8),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.0,
                            child: Text(
                              navItems[index].label,
                              style: TextStyle(
                                color: PColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}
