// lib/screens/pulse_feed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/feed_post.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/feed_post_card.dart';
import '../theme/app_theme.dart';

class PulseFeedScreen extends StatelessWidget {
  const PulseFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final user = context.watch<UserAuthProvider>().user;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pulse Feed',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Latest from your community',
                      style:
                          TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.bolt,
                      color: AppTheme.primary, size: 20),
                ),
              ],
            ),
          ),

          // ─── Feed ─────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<FeedPost>>(
              stream: feedProvider.feedStream,
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading feed',
                        style:
                            const TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primary),
                  );
                }
                final posts = snapshot.data!;
                if (posts.isEmpty) return _emptyState();

                return ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: posts.length,
                  separatorBuilder: (context2, idx) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final post = posts[i];
                    return FeedPostCard(
                      post: post,
                      currentUserId: user?.uid ?? '',
                      onKudos: () =>
                          feedProvider.addKudos(post.id, user?.uid ?? ''),
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dynamic_feed_outlined,
              size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('The feed is quiet…',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Log a workout and start the conversation!',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
