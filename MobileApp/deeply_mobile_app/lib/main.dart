import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/loading_screen.dart';

void main() {
  runApp(const DeeplyApp());
}

class DeeplyApp extends StatelessWidget {
  const DeeplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deeply',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const LoadingScreen(),
    );
  }
}
