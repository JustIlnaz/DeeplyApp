import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';

import 'screens/auth/loading_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/couple_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/features_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  DioClient.onAuthError = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoadingScreen()),
      (route) => false,
    );
  };
  runApp(const DeeplyApp());
}

class DeeplyApp extends StatelessWidget {
  const DeeplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CoupleProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FeaturesProvider()),
      ],
      child: MaterialApp(
        title: 'Deeply',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        navigatorKey: navigatorKey,
        home: const LoadingScreen(),
      ),
    );
  }
}
