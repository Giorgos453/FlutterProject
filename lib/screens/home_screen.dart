import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/user_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/sol_avatar.dart';
import '../widgets/stat_card.dart';
import '../widgets/state_views.dart';
import '../widgets/xp_bar.dart';

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
      final weather = context.read<WeatherProvider>();
      if (weather.data == null) weather.loadWeather();
    });
  }

  Future<void> _onRefresh() =>
      context.read<WeatherProvider>().loadWeather();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SolBuddy Madrid')),
      body: Consumer2<UserProvider, WeatherProvider>(
        builder: (context, userProv, weatherProv, _) {
          final user = userProv.user;
          final temp = weatherProv.data?.temperature;
          final stage = temp != null ? user.stageFor(temp) : user.solStage;
          final effectiveXp =
              temp != null ? user.effectiveStateValue(temp) : user.xp;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: kScreenPadding,
                vertical: 24,
              ),
              children: [
                Center(child: SolAvatar(stage: stage, size: 160)),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    stage.name.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
                  child: XpBar(xp: effectiveXp, stage: stage),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value: '${user.currentStreak}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.place,
                        label: 'Cool Spots',
                        value: '${user.visitedSpotIds.length}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.quiz,
                        label: 'Quizzes',
                        value: '${user.quizzesPlayed}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildWeatherSection(weatherProv),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherSection(WeatherProvider weather) {
    return switch (weather.status) {
      WeatherStatus.idle ||
      WeatherStatus.loading =>
        const Padding(
          padding: EdgeInsets.all(kScreenPadding),
          child: LoadingView(message: 'Loading weather…'),
        ),
      WeatherStatus.error => ErrorView(
          message: weather.errorMessage ?? 'Could not load weather',
          onRetry: weather.loadWeather,
        ),
      WeatherStatus.success => _WeatherCard(weather: weather),
    };
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: kScreenPadding),
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
