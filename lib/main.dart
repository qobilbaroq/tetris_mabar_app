import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'core/config/app_config.dart';
import 'core/network/network_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Auto-detect server URL
  final serverUrl = await AppConfig.getServerUrl();
  print('🌐 Server URL: $serverUrl');
  
  // Initialize network manager with detected server URL
  NetworkManager.instance.setServerUrl(serverUrl);
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
        fontFamily: 'Inter',
      ),
      home: const HomeScreen(),
    );
  }
}