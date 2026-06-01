import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/leaderboard_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/state_views.dart';

/// Profile screen showing user stats, leaderboard, and logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<LeaderboardEntry>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture =
        context.read<FirestoreService>().fetchLeaderboard();
  }

  void _refresh() {
    setState(() {
      _leaderboardFuture =
          context.read<FirestoreService>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final uid = context.watch<AuthProvider>().uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── User stats header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                kScreenPadding, kScreenPadding, kScreenPadding, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(kScreenPadding),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: kScreenPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName.isNotEmpty
                                ? user.displayName
                                : 'Anonymous',
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.xp} XP  ·  '
                            'Streak ${user.currentStreak}  ·  '
                            '${user.visitedSpotIds.length} spots  ·  '
                            '${user.quizzesPlayed} quizzes',
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Leaderboard ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kScreenPadding),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Leaderboard',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<LeaderboardEntry>>(
              future: _leaderboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView(message: 'Loading leaderboard…');
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Could not load leaderboard',
                    onRetry: _refresh,
                  );
                }
                final entries = snapshot.data!;
                if (entries.isEmpty) {
                  return const EmptyView(
                    icon: Icons.leaderboard_outlined,
                    message: 'No players yet — be the first!',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kScreenPadding),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isMe = entry.uid == uid;
                    return Card(
                      color: isMe
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(120)
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          entry.displayName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: isMe
                              ? const TextStyle(fontWeight: FontWeight.bold)
                              : null,
                        ),
                        trailing: Text(
                          '${entry.xp} XP',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ── Logout ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(kScreenPadding),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.read<AuthProvider>().signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
