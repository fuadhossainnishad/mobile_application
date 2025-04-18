import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'menu_screen.dart';
import 'report_screen.dart';
import 'payment_details_screen.dart';
import 'start_screen.dart';
import 'dashboard_screen.dart';
import 'order_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Poppins',
      ),
      home: const StartScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/order': (context) => const OrderScreen(),
        '/menu': (context) => const MenuScreen(),
        '/report': (context) => const ReportScreen(),
        '/payment_details': (context) => const PaymentDetailsScreen(),
      },
    );
  }
}