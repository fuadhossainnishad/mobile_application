import 'package:flutter/material.dart';
import 'package:food/auth/backend_service.dart';
import 'package:food/auth/cart_item.dart';
import 'package:food/bottom_nav_bar.dart';
import 'package:food/payment_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class OrderScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedItem;

  const OrderScreen({super.key, this.selectedItem});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _backendService = BackendService();
  final _logger = Logger();
  List<CartItem> _cartItems = [];
  String? _role;
  bool _isLoading = false;
  final TextEditingController _tableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRole();
    if (widget.selectedItem != null) {
      _cartItems = [
        CartItem(
          food: widget.selectedItem!,
          quantity: 1,
        ),
      ];
    }
  }

  Future<void> _fetchRole() async {
    try {
      final role = await _backendService.getUserRole();
      if (mounted) {
        setState(() {
          _role = role;
        });
        _logger.d('OrderScreen fetched role: $role');
      }
    } catch (e) {
      _logger.e('OrderScreen role fetch error: $e');
    }
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty || _tableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items and specify a table')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final items = _cartItems
        .map((item) => {
              'name': item.food['name'] as String?,
              'quantity': item.quantity,
              'price': item.food['price'] as num?,
            })
        .toList();
    final totalPrice = _cartItems.fold(
      0.0,
      (sum, item) => sum + ((item.food['price'] as num? ?? 0) * item.quantity),
    );

    final result = await _backendService.addOrder(
      items: items,
      table: _tableController.text,
      totalPrice: totalPrice,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetailsScreen(
            cartItems: _cartItems,
            totalPrice: totalPrice,
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
              'Orders',
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _tableController,
              decoration: InputDecoration(
                labelText: 'Table Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(child: Text('No items in cart'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title:
                              Text(item.food['name'] as String? ?? 'Unknown'),
                          subtitle: Text(
                            'Quantity: ${item.quantity} | ${(item.food['price'] as num? ?? 0) * item.quantity} BDT',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) {
                                  _cartItems[index] = CartItem(
                                    food: item.food,
                                    quantity: item.quantity - 1,
                                  );
                                } else {
                                  _cartItems.removeAt(index);
                                }
                              });
                              _logger.d('Removed item: ${item.food['name']}');
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
}
