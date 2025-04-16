import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _logger = Logger();

  Future<String?> addMenuItem({
    required String name,
    required double price,
    required String imagePath,
  }) async {
    try {
      _logger.d('Starting addMenuItem: name=$name, price=$price, imagePath=$imagePath');
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('AddMenuItem: No user logged in');
        return 'User not logged in';
      }
      _logger.d('User authenticated: ${user.uid}');

      final data = {
        'name': name,
        'price': price,
        'imageUrl': imagePath,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };
      _logger.d('Writing to Firestore: $data');
      await _firestore.collection('menu_items').add(data).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Firestore write timed out');
        },
      );

      _logger.i('Added menu item: $name with imageUrl: $imagePath');
      return null; // Success
    } catch (e) {
      _logger.e('AddMenuItem error: $e');
      return 'Failed to add item: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    try {
      final snapshot = await _firestore.collection('menu_items').get();
      final items = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      _logger.d('Fetched ${items.length} menu items: $items');
      return items;
    } catch (e) {
      _logger.e('GetMenuItems error: $e');
      return [];
    }
  }

  Future<String?> addOrder({
    required List<Map<String, dynamic>> items,
    required String table,
    required double totalPrice,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('AddOrder: No user logged in');
        return 'User not logged in';
      }
      await _firestore.collection('orders').add({
        'items': items,
        'table': table,
        'totalPrice': totalPrice,
        'status': 'Cooking',
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Added order for table: $table');
      return null;
    } catch (e) {
      _logger.e('AddOrder error: $e');
      return 'Failed to add order';
    }
  }

  Future<String?> addPayment({
    required String paymentMethod,
    required String? transactionId,
    required double amount,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('AddPayment: No user logged in');
        return 'User not logged in';
      }
      await _firestore.collection('payments').add({
        'paymentMethod': paymentMethod,
        'transactionId': transactionId ?? 'N/A',
        'amount': amount,
        'items': items,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Added payment: $amount via $paymentMethod');
      return null;
    } catch (e) {
      _logger.e('AddPayment error: $e');
      return 'Failed to add payment';
    }
  }

  Future<Map<String, dynamic>> getTodaySales() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      final totalOrders = snapshot.docs.length;
      final totalSales = snapshot.docs.fold<double>(
        0.0,
        (total, doc) => total + (doc.data()['totalPrice'] as num).toDouble(),
      );
      _logger.d('Fetched today sales: $totalOrders orders, $totalSales BDT');
      return {'totalOrders': totalOrders, 'totalSales': totalSales};
    } catch (e) {
      _logger.e('GetTodaySales error: $e');
      return {'totalOrders': 0, 'totalSales': 0.0};
    }
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      final orders = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      _logger.d('Fetched ${orders.length} orders');
      return orders;
    } catch (e) {
      _logger.e('GetOrders error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentReports() async {
    try {
      final snapshot = await _firestore.collection('payments').get();
      final payments = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      _logger.d('Fetched ${payments.length} payment reports');
      return payments;
    } catch (e) {
      _logger.e('GetPaymentReports error: $e');
      return [];
    }
  }

  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedRole = prefs.getString('role');
      if (cachedRole != null) {
        _logger.d('GetUserRole: Cached role: $cachedRole');
        return cachedRole;
      }
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('GetUserRole: No user logged in');
        return null;
      }
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        _logger.w('GetUserRole: No user document for UID: ${user.uid}');
        return null;
      }
      final role = doc.data()?['role'] as String?;
      _logger.d('GetUserRole: Fetched role: $role for UID: ${user.uid}');
      if (role != null) {
        await prefs.setString('role', role);
      }
      return role;
    } catch (e) {
      _logger.e('GetUserRole error: $e');
      return null;
    }
  }
}