import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SolBuddy Madrid')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sol lives here ☀️ — coming soon'),
            const SizedBox(height: 32),
            Consumer<WeatherProvider>(
              builder: (context, weather, _) {
                return switch (weather.status) {
                  WeatherStatus.idle ||
                  WeatherStatus.loading =>
                    const CircularProgressIndicator(),
                  WeatherStatus.error => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weather.errorMessage ?? 'Unknown error',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: weather.loadWeather,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  WeatherStatus.success => _WeatherCard(weather: weather),
                };
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.weather});

  final WeatherProvider weather;

  @override
  Widget build(BuildContext context) {
    final data = weather.data!;
    final heatLevel = data.heatLevel;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${data.temperature.toStringAsFixed(1)} °C',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                heatLevel.label,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: heatLevel.color,
            ),
          ],
        ),
      ),
    );
  }
}
