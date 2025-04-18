import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:food/dashboard_screen.dart';
import 'package:food/menu_screen.dart';
import 'package:food/order_screen.dart';
import 'package:food/report_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String paymentMethod;
  final String? transactionId;

  const PaymentSuccessScreen({
    Key? key,
    required this.paymentMethod,
    this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current date formatted
    final String currentDate = DateFormat('d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  currentDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Text(
              'Payment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 16,
                ),
              ],
            ),
          ),
        ],
        leadingWidth: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Done Text
                  const Text(
                    'Payment Done',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment details
                  Text(
                    'Method: $paymentMethod',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (transactionId != null && transactionId != 'N/A')
                    Text(
                      'Transaction ID: $transactionId',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  const SizedBox(height: 40),

                  // Print Invoice Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement print invoice functionality
                        _printInvoice(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Print Invoice',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: _buildNavItem(Icons.dashboard_outlined, 'Dashboard', true),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderScreen()),
                    );
                  },
                  child: _buildNavItem(Icons.shopping_cart_outlined, 'Orders', false),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuScreen()),
                    );
                  },
                  child: _buildNavItem(Icons.restaurant_menu_outlined, 'Menu', false),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportScreen()),
                    );
                  },
                  child: _buildNavItem(Icons.insert_chart_outlined, 'Reports', false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _printInvoice(BuildContext context) {
    // Show a message that printing has started
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printing invoice...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Here you would implement actual printing functionality
    // This could connect to a receipt printer or generate a PDF
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
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
    );
  }
}