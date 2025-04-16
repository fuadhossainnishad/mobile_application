import 'package:flutter/material.dart';
import 'package:food/auth/backend_service.dart';
import 'package:food/auth/cart_item.dart';
import 'package:food/bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String paymentMethod;
  final String? transactionId;
  final List<CartItem>? cartItems;

  const PaymentSuccessScreen({
    super.key,
    required this.paymentMethod,
    this.transactionId,
    this.cartItems,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isPrinting = false;
  String? _role;
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    try {
      final role = await BackendService().getUserRole();
      if (mounted) {
        setState(() {
          _role = role;
        });
        _logger.d('PaymentSuccessScreen fetched role: $role');
      }
    } catch (e) {
      _logger.e('PaymentSuccessScreen role fetch error: $e');
    }
  }

  Future<void> _printInvoice() async {
    setState(() {
      _isPrinting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isPrinting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice printed successfully'),
        duration: Duration(seconds: 2),
      ),
    );
    _logger.d('Invoice printed for payment: ${widget.paymentMethod}');
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
                  _role == 'Admin' ? 'Admin' : _role == 'Buyer' ? 'Buyer' : 'Guest',
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const Text(
                    'Payment Done',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Method: ${widget.paymentMethod}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (widget.transactionId != null && widget.transactionId != 'N/A')
                    Text(
                      'Transaction ID: ${widget.transactionId}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  if (widget.cartItems != null && widget.cartItems!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Order Details:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...widget.cartItems!.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '${item.food['name'] as String? ?? 'Unknown'} x ${item.quantity} - ${(item.food['price'] as num? ?? 0) * item.quantity} BDT',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isPrinting ? null : _printInvoice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isPrinting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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
          const FoodPOSBottomNavBar(currentIndex: 1),
        ],
      ),
    );
  }
}