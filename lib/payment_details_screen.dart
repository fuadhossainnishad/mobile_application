import 'package:flutter/material.dart';
import 'package:food/auth/backend_service.dart';
import 'package:food/auth/cart_item.dart';
import 'package:food/bottom_nav_bar.dart';
import 'package:food/payment_success_screen.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final List<CartItem>? cartItems;
  final double? totalPrice;

  const PaymentDetailsScreen({super.key, this.cartItems, this.totalPrice});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  String? selectedPaymentMethod;
  String? transactionId;
  final TextEditingController _transactionIdController =
      TextEditingController();
  bool _isLoading = false;
  String? _role;
  final _backendService = BackendService();
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    try {
      final role = await _backendService.getUserRole();
      if (mounted) {
        setState(() {
          _role = role;
        });
        _logger.d('PaymentDetailsScreen fetched role: $role');
      }
    } catch (e) {
      _logger.e('PaymentDetailsScreen role fetch error: $e');
    }
  }

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  void _showTransactionIdDialog(String paymentMethod) {
    if (paymentMethod == 'Cash') {
      setState(() {
        selectedPaymentMethod = paymentMethod;
        transactionId = 'N/A';
      });
      _logger.d('Selected payment method: Cash');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter $paymentMethod Transaction ID'),
          content: TextField(
            controller: _transactionIdController,
            decoration: InputDecoration(
              hintText: 'Enter transaction ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                _logger.d(
                    'Selected payment method: $paymentMethod, transactionId: $transactionId');
                _transactionIdController.clear();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    if (selectedPaymentMethod != 'Cash' &&
        (transactionId == null || transactionId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter payment gateway mobile number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final items = widget.cartItems
            ?.map((item) => {
                  'name': item.food['name'] as String?,
                  'quantity': item.quantity,
                  'price': item.food['price'] as num?,
                })
            .toList() ??
        [];

    final result = await _backendService.addPayment(
      paymentMethod: selectedPaymentMethod!,
      transactionId: transactionId,
      amount: widget.totalPrice ?? 0.0,
      items: items,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            paymentMethod: selectedPaymentMethod!,
            transactionId: transactionId,
            cartItems: widget.cartItems,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  _role == 'Admin'
                      ? 'Admin'
                      : _role == 'Buyer'
                          ? 'Buyer'
                          : 'Guest',
                  style: const TextStyle(
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
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected: $selectedPaymentMethod',
                          style: const TextStyle(
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
                    icon: const Icon(Icons.edit, color: Colors.deepOrange),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildPaymentOption(
                      context, 'Cash', 'assets/icons/cash_icon.png'),
                  _buildPaymentOption(
                      context, 'bKash', 'assets/icons/bkash_icon.png'),
                  _buildPaymentOption(
                      context, 'Nagad', 'assets/icons/nagad_icon.png'),
                  _buildPaymentOption(
                      context, 'Rocket', 'assets/icons/rocket_icon.png'),
                  _buildPaymentOption(
                      context, 'VISA', 'assets/icons/visa_icon.png'),
                  _buildPaymentOption(context, 'Mastercard',
                      'assets/icons/mastercard_icon.png'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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
        ],
      ),
      bottomNavigationBar: const FoodPOSBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildPaymentOption(
      BuildContext context, String label, String imagePath) {
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
                      decoration: const BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
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
                  color: isSelected
                      ? Colors.deepOrange.withOpacity(0.1)
                      : Colors.grey[100],
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
}
