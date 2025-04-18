import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:food/dashboard_screen.dart';
import 'package:food/menu_screen.dart';
import 'package:food/order_screen.dart';
import 'package:food/report_screen.dart';
import 'package:food/payment_success_screen.dart';

class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  String? selectedPaymentMethod;
  String? transactionId;
  final TextEditingController _transactionIdController = TextEditingController();

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  void _showTransactionIdDialog(String paymentMethod) {
    // Don't show transaction ID dialog for Cash payment
    if (paymentMethod == 'Cash') {
      setState(() {
        selectedPaymentMethod = paymentMethod;
        transactionId = 'N/A';
      });
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter $paymentMethod Transaction ID'),
          content: TextField(
            controller: _transactionIdController,
            decoration: const InputDecoration(
              hintText: 'Enter transaction ID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedPaymentMethod = paymentMethod;
                  transactionId = _transactionIdController.text;
                });
                _transactionIdController.clear();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _processPayment() {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    if (selectedPaymentMethod != 'Cash' && (transactionId == null || transactionId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter transaction ID')),
      );
      return;
    }

    // Navigate to payment success screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          paymentMethod: selectedPaymentMethod!,
          transactionId: transactionId,
        ),
      ),
    );
  }

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
          // Payment selection status
          if (selectedPaymentMethod != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected: $selectedPaymentMethod',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (transactionId != null && transactionId != 'N/A')
                          Text(
                            'Transaction ID: $transactionId',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.deepOrange),
                    onPressed: () {
                      if (selectedPaymentMethod != 'Cash') {
                        _transactionIdController.text = transactionId ?? '';
                        _showTransactionIdDialog(selectedPaymentMethod!);
                      } else {
                        setState(() {
                          selectedPaymentMethod = null;
                          transactionId = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildPaymentOptionWithImage(context, 'Cash', 'assets/icons/cash_icon.png'),
                  _buildPaymentOptionWithImage(context, 'bKash', 'assets/icons/bkash_icon.png'),
                  _buildPaymentOptionWithImage(context, 'Nagad', 'assets/icons/nagad_icon.png'),
                  _buildPaymentOptionWithImage(context, 'Rocket', 'assets/icons/rocket_icon.png'),
                  _buildPaymentOptionWithImage(context, 'VISA', 'assets/icons/visa_icon.png'),
                  _buildPaymentOptionWithImage(context, 'Mastercard', 'assets/icons/mastercard_icon.png'),
                ],
              ),
            ),
          ),

          // Proceed button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Proceed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
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
                  child: _buildNavItem(Icons.grid_view, 'Dashboard', false),
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
                  child: _buildNavItem(Icons.restaurant_menu, 'Menu', false),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportScreen()),
                    );
                  },
                  child: _buildNavItem(Icons.bar_chart, 'Reports', true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionWithImage(BuildContext context, String label, String imagePath) {
    bool isSelected = selectedPaymentMethod == label;

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.deepOrange : Colors.grey[200]!,
          width: isSelected ? 2.0 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          _showTransactionIdDialog(label);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.asset(
                    imagePath,
                    height: 55,
                    width: 55,
                    fit: BoxFit.contain,
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.deepOrange.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.deepOrange : Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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