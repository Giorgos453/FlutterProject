import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/weather_provider.dart';
import 'screens/main_screen.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const SolBuddyApp());
}

class SolBuddyApp extends StatelessWidget {
  const SolBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(const WeatherService()),
        ),
      ],
      child: MaterialApp(
        title: 'SolBuddy Madrid',
        theme: AppTheme.theme,
        home: const MainScreen(),
      ),
    );
  }
}
