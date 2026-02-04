import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter', // Anda bisa ganti dengan font yang diinginkan
      ),
      home: const HomeScreen(),
    );
  }
}