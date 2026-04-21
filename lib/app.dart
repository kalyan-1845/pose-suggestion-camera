import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

/// Root MaterialApp with dark theme and splash entry point
class PoseAICameraApp extends StatelessWidget {
  const PoseAICameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose AI Camera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
