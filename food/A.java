import 'package:flutter/material.dart';
import 'start_screen.dart';

void main() {
  runApp(const FoodPOSApp());
}

class FoodPOSApp extends StatelessWidget {
  const FoodPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const StartScreen(),
    );
  }
}