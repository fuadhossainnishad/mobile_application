import 'package:flutter/material.dart';
import 'package:food/auth/backend_service.dart';
import 'package:food/bottom_nav_bar.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _backendService = BackendService();
  final _logger = Logger();
  List<Map<String, dynamic>> _payments = [];
  String? _role;
  bool _isLoading = false;

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
      final payments = await _backendService.getPaymentReports();

      if (!mounted) return;

      setState(() {
        _role = role;
        _payments = payments;
        _isLoading = false;
      });
      _logger.d('ReportScreen fetched: role=$role, payments=${payments.length}');
    } catch (e) {
      _logger.e('ReportScreen fetch error: $e');
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
              'Reports',
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
          : _payments.isEmpty
              ? const Center(child: Text('No payment reports'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.payment, color: Colors.deepOrange),
                        title: Text('Method: ${payment['paymentMethod'] ?? 'Unknown'}'),
                        subtitle: Text(
                          'Amount: ${(payment['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'} BDT',
                        ),
                        trailing: Text(
                          payment['transactionId'] ?? 'N/A',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: const FoodPOSBottomNavBar(currentIndex: 3),
    );
  }
}