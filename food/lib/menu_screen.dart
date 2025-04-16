import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food/add_item_screen.dart';
import 'package:food/auth/backend_service.dart';
import 'package:food/bottom_nav_bar.dart';
import 'package:food/order_screen.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> _menuItems = [];
  bool _isLoading = false;
  String? _role;
  final _backendService = BackendService();
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final role = await _backendService.getUserRole();
      final menuItems = await _backendService.getMenuItems();

      if (!mounted) return;

      setState(() {
        _role = role;
        _menuItems = menuItems;
        _isLoading = false;
      });
      _logger.d('MenuScreen fetched: role=$role, items=${menuItems.length}');
    } catch (e) {
      _logger.e('MenuScreen fetch error: $e');
      setState(() {
        _isLoading = false;
      });
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
              'Menu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          if (_role == 'Admin')
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _fetchData,
            ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menuItems.isEmpty
              ? const Center(child: Text('No menu items available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final imageUrl = item['imageUrl'] as String?;
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              )
                            : const Icon(Icons.fastfood, size: 50),
                        title: Text(
                          item['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'} BDT',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: _role == 'Buyer'
                            ? IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderScreen(selectedItem: item),
                                    ),
                                  );
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
      floatingActionButton: _role == 'Admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemScreen()),
                ).then((_) => _fetchData());
              },
              backgroundColor: Colors.deepOrange,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: const FoodPOSBottomNavBar(currentIndex: 2),
    );
  }
}