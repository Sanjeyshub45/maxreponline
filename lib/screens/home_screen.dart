// lib/screens/home_screen.dart
// Root shell: bottom nav + tab bodies (Dashboard, Log, Leaderboard, Feed, Profile)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'leaderboard_screen.dart';
import 'workout_log_screen.dart';
import 'pulse_feed_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool demoMode;
  const HomeScreen({super.key, this.demoMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  final List<_Tab> _tabs = const [
    _Tab(icon: Icons.home_outlined,    activeIcon: Icons.home,                label: 'Home'),
    _Tab(icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center, label: 'Log'),
    _Tab(icon: Icons.leaderboard_outlined, activeIcon: Icons.leaderboard,     label: 'Ranks'),
    _Tab(icon: Icons.dynamic_feed_outlined, activeIcon: Icons.dynamic_feed,   label: 'Feed'),
    _Tab(icon: Icons.person_outline,   activeIcon: Icons.person,              label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LeaderboardProvider(demoMode: widget.demoMode),
        ),
        ChangeNotifierProvider(
          create: (_) => FeedProvider(demoMode: widget.demoMode),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _tab,
            children: const [
              DashboardScreen(),
              WorkoutLogScreen(),
              LeaderboardScreen(),
              PulseFeedScreen(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: _buildNav(),
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          top: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (i) {
          final t = _tabs[i];
          final selected = _tab == i;
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: selected
                  ? BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected ? t.activeIcon : t.icon,
                    color:
                        selected ? AppTheme.primary : AppTheme.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab({required this.icon, required this.activeIcon, required this.label});
}
