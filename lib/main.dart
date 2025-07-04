import 'package:flutter/material.dart';
import 'welcome_screen.dart';

void main() {
  runApp(const ChickenFarmApp());
}

class ChickenFarmApp extends StatelessWidget {
  const ChickenFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicken Farm',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WelcomeScreen(),
    );
  }
}
