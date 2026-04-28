import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const SolBuddyApp());
}

class SolBuddyApp extends StatelessWidget {
  const SolBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolBuddy Madrid',
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}
