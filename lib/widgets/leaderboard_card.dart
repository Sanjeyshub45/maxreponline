// lib/widgets/leaderboard_card.dart

import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../theme/app_theme.dart';

class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardCard({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // Yellow background for current user (matches reference exactly)
        color: isCurrentUser ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser ? null : Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: [
          // ─── Rank ──────────────────────────────────────────────────────
          SizedBox(
            width: 32,
            child: isTop3
                ? Text(
                    _medal(entry.rank),
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Colors.black.withValues(alpha: 0.15)
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${entry.rank}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isCurrentUser
                            ? Colors.black
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // ─── Avatar ────────────────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrentUser
                  ? Colors.black.withValues(alpha: 0.2)
                  : AppTheme.surfaceVariant,
            ),
            child: entry.photoUrl != null
                ? ClipOval(
                    child:
                        Image.network(entry.photoUrl!, fit: BoxFit.cover))
                : Center(
                    child: Text(
                      entry.displayName.isNotEmpty
                          ? entry.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isCurrentUser
                            ? Colors.black
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // ─── Name ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isCurrentUser
                        ? Colors.black
                        : AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCurrentUser)
                  Text(
                    'You',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // ─── Score ─────────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_pct(entry)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isCurrentUser ? Colors.black : AppTheme.textPrimary,
                ),
              ),
              Text(
                '${entry.pulsePoints} pts',
                style: TextStyle(
                  fontSize: 12,
                  color: isCurrentUser
                      ? Colors.black.withValues(alpha: 0.6)
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _medal(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    return '🥉';
  }

  // Express pulsePoints as a percentage of a 10k max
  int _pct(LeaderboardEntry e) =>
      ((e.pulsePoints / 10000) * 100).clamp(0, 999).round();
}
