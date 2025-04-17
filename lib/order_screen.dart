// order_screen.dart
import 'package:flutter/material.dart';
import 'package:food/bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late List<CartItem> _cartItems;
  final String _currentDate = DateFormat('d MMMM yyyy').format(DateTime.now());
  final int _orderNumber = 12;

  @override
  void initState() {
    super.initState();
    // Initialize all food items with quantity 1 by default
    _cartItems = [
      CartItem(
        food: FoodItem(
          name: 'French Fry',
          image: 'assets/images/french_fry.png',
          price: 120,
        ),
        quantity: 1,
      ),
      CartItem(
        food: FoodItem(
          name: 'Pasta Alfredo',
          image: 'assets/images/pasta.png',
          price: 200,
        ),
        quantity: 1,
      ),
      CartItem(
        food: FoodItem(
          name: 'Cappuccino',
          image: 'assets/images/cappuccino.png',
          price: 150,
        ),
        quantity: 1,
      ),
      CartItem(
        food: FoodItem(
          name: 'Rice Bowl 1',
          image: 'assets/images/rice_bowl1.png',
          price: 280,
        ),
        quantity: 1,
      ),
      CartItem(
        food: FoodItem(
          name: 'Rice Bowl 2',
          image: 'assets/images/rice_bowl2.png',
          price: 280,
        ),
        quantity: 1,
      ),
      CartItem(
        food: FoodItem(
          name: 'Crab',
          image: 'assets/images/crab.png',
          price: 340,
        ),
        quantity: 1,
      ),
      CartItem(
        food: FoodItem(
          name: 'Chicken Curry',
          image: 'assets/images/chicken_curry.png',
          price: 250,
        ),
        quantity: 1,
      ),
      CartItem(
        food: FoodItem(
          name: 'Watermelon Juice',
          image: 'assets/images/watermelon_juice.png',
          price: 100,
        ),
        quantity: 1,
      ),
      CartItem(
        food: FoodItem(
          name: 'Oven Baked Pasta',
          image: 'assets/images/oven_baked_pasta.png',
          price: 300,
        ),
        quantity: 1,
      ),
    ];
  }

  void _addToCart(FoodItem foodItem) {
    setState(() {
      // Check if the item is already in the cart
      final existingIndex = _cartItems.indexWhere((item) => item.food.name == foodItem.name);
      if (existingIndex >= 0) {
        // Increment the quantity if it's already in the cart
        _cartItems[existingIndex].quantity++;
      } else {
        // Add new item to cart with quantity 1
        _cartItems.add(CartItem(food: foodItem, quantity: 1));
      }
    });
  }

  void _removeFromCart(FoodItem foodItem) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item.food.name == foodItem.name);
      if (existingIndex >= 0) {
        if (_cartItems[existingIndex].quantity > 1) {
          // Decrement the quantity
          _cartItems[existingIndex].quantity--;
        } else {
          // Remove the item from cart if quantity becomes 0
          _cartItems.removeAt(existingIndex);
        }
      }
    });
  }

  int _getQuantity(String foodName) {
    final existingItem = _cartItems.firstWhere(
          (item) => item.food.name == foodName,
      orElse: () => CartItem(food: FoodItem(name: '', image: '', price: 0), quantity: 0),
    );
    return existingItem.quantity;
  }

  int get _totalQuantity {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.food.price * item.quantity));
  }

  // Get list of all available food items
  List<FoodItem> get _allFoodItems {
    return [
      FoodItem(
        name: 'French Fry',
        image: 'assets/images/french_fry.png',
        price: 120,
      ),
      FoodItem(
        name: 'Pasta Alfredo',
        image: 'assets/images/pasta.png',
        price: 200,
      ),
      FoodItem(
        name: 'Cappuccino',
        image: 'assets/images/cappuccino.png',
        price: 150,
      ),
      FoodItem(
        name: 'Rice Bowl 1',
        image: 'assets/images/rice_bowl1.png',
        price: 280,
      ),
      FoodItem(
        name: 'Rice Bowl 2',
        image: 'assets/images/rice_bowl2.png',
        price: 250,
      ),
      FoodItem(
        name: 'Crab',
        image: 'assets/images/crab.png',
        price: 340,
      ),
      FoodItem(
        name: 'Chicken Curry',
        image: 'assets/images/chicken_curry.png',
        price: 250,
      ),
      FoodItem(
        name: 'Watermelon Juice',
        image: 'assets/images/watermelon_juice.png',
        price: 100,
      ),
      FoodItem(
        name: 'Oven Baked Pasta',
        image: 'assets/images/oven_baked_pasta.png',
        price: 300,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                  _currentDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Text(
              'Order',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order No: $_orderNumber',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Table',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tap to Search Product',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
                children: _allFoodItems.map((foodItem) {
                  return FoodItemCard(
                    foodItem: foodItem,
                    quantity: _getQuantity(foodItem.name),
                    onAdd: _addToCart,
                    onRemove: _removeFromCart,
                  );
                }).toList(),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'More',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Item',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Price',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${_cartItems.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '$_totalQuantity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FoodPOSBottomNavBar(currentIndex: 1),
    );
  }
}

class FoodItem {
  final String name;
  final String image;
  final double price;

  FoodItem({
    required this.name,
    required this.image,
    required this.price,
  });
}

class CartItem {
  final FoodItem food;
  int quantity;

  CartItem({
    required this.food,
    required this.quantity,
  });
}

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final int quantity;
  final Function(FoodItem) onAdd;
  final Function(FoodItem) onRemove;

  const FoodItemCard({
    Key? key,
    required this.foodItem,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Image.asset(
                  foodItem.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => onRemove(foodItem),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        color: Colors.red,
                        child: Text(
                          'REMOVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => onAdd(foodItem),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        color: Colors.green,
                        child: Text(
                          'ADD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}