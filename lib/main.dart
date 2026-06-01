import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'models/daily_check_result.dart';
import 'providers/auth_provider.dart';
import 'providers/map_provider.dart';
import 'providers/user_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';
import 'widgets/state_views.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SolBuddyApp());
}

class SolBuddyApp extends StatelessWidget {
  const SolBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return MultiProvider(
      providers: [
        Provider<FirestoreService>.value(value: firestoreService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            firestoreService: firestoreService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherProvider(const WeatherService()),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(firestoreService: firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => MapProvider(
            weatherService: const WeatherService(),
            locationService: const LocationService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SolBuddy Madrid',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Routes to login or the main app based on authentication state.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _loadedUid;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.unknown) {
      return const Scaffold(body: LoadingView());
    }

    if (auth.status == AuthStatus.unauthenticated ||
        auth.status == AuthStatus.authenticating) {
      _loadedUid = null;
      return const LoginScreen();
    }

    if (auth.uid != null && auth.uid != _loadedUid) {
      _loadedUid = auth.uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initUserSession(auth.uid!);
      });
    }

    return const MainScreen();
  }

  Future<void> _initUserSession(String uid) async {
    final userProvider = context.read<UserProvider>();
    await userProvider.loadForUser(uid);

    if (!mounted) return;
    final weatherProvider = context.read<WeatherProvider>();
    if (weatherProvider.data == null) {
      await weatherProvider.loadWeather();
    }

    if (!mounted) return;
    final temp = context.read<WeatherProvider>().data?.temperature;
    if (temp != null) {
      final result = await userProvider.runDailyCheck(temp);
      if (!mounted) return;
      _showDailyCheckFeedback(result);
    }
  }

  void _showDailyCheckFeedback(DailyCheckResult result) {
    if (!result.hasChanges) return;

    final lines = <String>[];
    if (result.dailyLoginXp > 0) {
      lines.add('+${result.dailyLoginXp} XP Daily Login');
    }
    if (result.streakBonus > 0) {
      lines.add('+${result.streakBonus} XP  ${XpReward.sevenDayStreak}-day Streak!');
    }
    if (result.currentStreak > 1) {
      lines.add('Streak: ${result.currentStreak} days');
    }
    if (result.inactivityPenalty != 0) {
      lines.add('${result.inactivityPenalty} XP Inactivity');
    }
    if (result.tempPenalty != 0) {
      lines.add('${result.tempPenalty} XP Heat penalty');
    }

    if (lines.isEmpty) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(lines.join('  ·  ')),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(kScreenPadding),
      ));
  }
}
