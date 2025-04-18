import 'package:flutter/material.dart';
import 'package:food/dashboard_screen.dart';
import 'package:food/menu_screen.dart';
import 'package:food/order_screen.dart';
import 'package:food/report_screen.dart';

class FoodPOSBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const FoodPOSBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            Icons.grid_view,
            'Dashboard',
            currentIndex == 0,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            ),
          ),
          _buildNavItem(
            context,
            Icons.shopping_cart_outlined,
            'Orders',
            currentIndex == 1,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OrderScreen()),
            ),
          ),
          _buildNavItem(
            context,
            Icons.restaurant_menu,
            'Menu',
            currentIndex == 2,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MenuScreen()),
            ),
          ),
          _buildNavItem(
            context,
            Icons.bar_chart,
            'Reports',
            currentIndex == 3,
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ReportScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.deepOrange : Colors.grey,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.deepOrange : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}