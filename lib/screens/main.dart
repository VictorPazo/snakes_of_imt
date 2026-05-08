import 'package:flutter/material.dart';
import 'camera.dart';
import 'home.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snakes of IMT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF126516),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}