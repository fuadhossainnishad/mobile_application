import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _logger = Logger();

  // Add a new menu item
  Future<String?> addMenuItem({
    required String name,
    required double price,
    File? imageFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('AddMenuItem: No user logged in');
        return 'User not logged in.';
      }

      String? imageUrl;
      if (imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('menu_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
        _logger.d('Uploaded image: $imageUrl');
      }

      await _firestore.collection('menu_items').add({
        'name': name,
        'price': price,
        'imageUrl': imageUrl ?? '',
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Added menu item: $name');
      return null; // Success
    } catch (e) {
      _logger.e('AddMenuItem error: $e');
      return 'Failed to add item: $e';
    }
  }

  // Get all menu items
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    try {
      final snapshot = await _firestore.collection('menu_items').get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      _logger.e('GetMenuItems error: $e');
      return [];
    }
  }

  // Add an order
  Future<String?> addOrder({
    required List<Map<String, dynamic>> items,
    required String table,
    required double totalPrice,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('AddOrder: No user logged in');
        return 'User not logged in.';
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
      return null; // Success
    } catch (e) {
      _logger.e('AddOrder error: $e');
      return 'Failed to add order: $e';
    }
  }

  // Add payment details
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
        return 'User not logged in.';
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
      return null; // Success
    } catch (e) {
      _logger.e('AddPayment error: $e');
      return 'Failed to add payment: $e';
    }
  }

  // Get today's sales data
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

      int totalOrders = snapshot.docs.length;
      double totalSales = snapshot.docs.fold(
        0.0,
        (total, doc) => total + (doc.data()['totalPrice'] as num).toDouble(),
      );

      _logger.d('Fetched today sales: $totalOrders orders, $totalSales BDT');
      return {
        'totalOrders': totalOrders,
        'totalSales': totalSales,
      };
    } catch (e) {
      _logger.e('GetTodaySales error: $e');
      return {'totalOrders': 0, 'totalSales': 0.0};
    }
  }

  // Get all orders
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      final orders = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      _logger.d('Fetched ${orders.length} orders');
      return orders;
    } catch (e) {
      _logger.e('GetOrders error: $e');
      return [];
    }
  }

  // Get payment reports
  Future<List<Map<String, dynamic>>> getPaymentReports() async {
    try {
      final snapshot = await _firestore.collection('payments').get();
      final payments = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      _logger.d('Fetched ${payments.length} payment reports');
      return payments;
    } catch (e) {
      _logger.e('GetPaymentReports error: $e');
      return [];
    }
  }

  // Get user role
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