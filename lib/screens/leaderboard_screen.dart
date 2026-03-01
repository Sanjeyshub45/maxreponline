// lib/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/leaderboard_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/leaderboard_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserAuthProvider>().user;
    final lbProvider = context.watch<LeaderboardProvider>();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                // Info icon
                Icon(Icons.info_outline,
                    color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 16),
                // Calendar icon
                Icon(Icons.calendar_today_outlined,
                    color: AppTheme.textSecondary, size: 20),
              ],
            ),
          ),

          // ─── Filter tabs (pill style like reference) ────────────────────────
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: LeaderboardFilter.values.map((f) {
                final selected = lbProvider.filter == f;
                return GestureDetector(
                  onTap: () => lbProvider.setFilter(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.textPrimary
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            selected ? AppTheme.textPrimary : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      f.label,
                      style: TextStyle(
                        color: selected
                            ? AppTheme.background
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // ─── List ──────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<LeaderboardEntry>>(
              stream: lbProvider.leaderboardStream,
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary)),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2),
                  );
                }
                final entries = snapshot.data!;
                if (entries.isEmpty) {
                  return const Center(
                    child: Text('No athletes yet — be the first!',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: entries.length,
                  itemBuilder: (ctx, i) {
                    final e = entries[i];
                    return LeaderboardCard(
                      entry: e,
                      isCurrentUser: e.uid == user?.uid,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
