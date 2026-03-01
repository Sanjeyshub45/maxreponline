// lib/widgets/feed_post_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/feed_post.dart';
import '../theme/app_theme.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPost post;
  final String currentUserId;
  final VoidCallback onKudos;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onKudos,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(post.type);
    final timeAgo = _timeAgo(post.timestamp);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────────────────
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: typeColor.withValues(alpha: 0.2),
                ),
                child: post.photoUrl != null
                    ? ClipOval(
                        child:
                            Image.network(post.photoUrl!, fit: BoxFit.cover))
                    : Center(
                        child: Text(
                          post.displayName.isNotEmpty
                              ? post.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            fontSize: 14)),
                    Text(timeAgo,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              // Type badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _typeBadge(post.type),
                  style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ─── Content ─────────────────────────────────────────────────
          Text(post.content,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.4)),

          // ─── Metadata pill ────────────────────────────────────────────
          if (post.metadata.containsKey('points')) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
              ),
              child: Text(
                '⚡ +${post.metadata['points']} Pulse Points',
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ─── Kudos ────────────────────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: onKudos,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👏', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'Kudos ${post.kudos > 0 ? post.kudos : ''}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'rank_up':
        return AppTheme.primary;
      case 'milestone':
        return const Color(0xFFFFD700);
      default:
        return AppTheme.accentAlt;
    }
  }

  String _typeBadge(String type) {
    switch (type) {
      case 'rank_up':
        return '📈 RANK UP';
      case 'milestone':
        return '🏆 MILESTONE';
      default:
        return '💪 WORKOUT';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}
