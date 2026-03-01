// lib/screens/dashboard_screen.dart
// Home tab — circular Pulse Score arc, weekly stats, quick actions

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/strava_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Initialise once so FutureBuilder doesn't restart on every rebuild
  late final Future<Map<String, dynamic>?> _stravaFuture =
      StravaService().fetchTodayWalkingStats();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserAuthProvider>().user;
    final pulse = user?.pulsePoints ?? 0;
    final activity = user?.activityScore ?? 0.0;
    final strength = user?.strengthScore ?? 0.0;
    final vitality = user?.vitalityScore ?? 0.0;

    // Pulse Score as 0–100 percentage for the arc
    final maxPulse = 10000;
    final progress = (pulse / maxPulse).clamp(0.0, 1.0);
    final pct = (progress * 100).toStringAsFixed(0);

    return CustomScrollView(
      slivers: [
        // ─── Top bar ───────────────────────────────────────────────────────
        SliverSafeArea(
          bottom: false,
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null && user.orgName.isNotEmpty
                            ? user.orgName
                            : 'MaxRep',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      Text(
                        user?.displayName ?? 'Athlete',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      border: Border.all(color: AppTheme.primary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        user?.displayName.isNotEmpty == true
                            ? user!.displayName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── Circular arc score ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 260,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(260, 200),
                      painter: _ArcPainter(progress: progress),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        const Text('You are at',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                        Text(
                          '$pct%',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const Text('Pulse Score',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                    // Small indicator dot on arc end
                  ],
                ),
              ),
            ),
          ),
        ),

        // ─── Points-to-next-milestone ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt,
                      color: AppTheme.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${(maxPulse - pulse).clamp(0, maxPulse)} pts to reach the 100% mark.',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── Quick stats row ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _statCard('$pulse', 'Pulse Points', Icons.flash_on_outlined),
                const SizedBox(width: 12),
                _statCard(
                    (activity * 0.4 + strength * 0.3 + vitality * 0.3).toStringAsFixed(0),
                    'Weekly Score',
                    Icons.trending_up),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // ─── Strava Today's Walk Integration ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _stravaFuture,
              builder: (ctx, snapshot) {
                // Determine states
                final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
                final bool hasData = snapshot.hasData && snapshot.data != null;
                
                String distance = '0.00';
                String pace = '0:00';

                if (hasData) {
                  distance = (snapshot.data!['distance_km'] as double).toStringAsFixed(2);
                  pace = snapshot.data!['pace_str'] as String;
                }

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFC4C02).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFC4C02).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.directions_walk,
                                color: Color(0xFFFC4C02), size: 18),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Today\'s Walk',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                          if (isLoading)
                            const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFC4C02),
                              ),
                            )
                          else ...[
                            const Icon(Icons.check_circle, 
                                color: Color(0xFFFC4C02), size: 16),
                            const SizedBox(width: 4),
                            const Text('Synced', 
                                style: TextStyle(color: Color(0xFFFC4C02), fontSize: 12, fontWeight: FontWeight.w600)),
                          ]
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${distance}km',
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900)),
                                const Text('Total Distance',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$pace /km',
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900)),
                                const Text('Average Pace',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // ─── Score breakdown ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Score Breakdown',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1)),
                const SizedBox(height: 12),
                _scoreBar('⚡ Activity', activity, AppTheme.primary, '40%'),
                const SizedBox(height: 10),
                _scoreBar('💪 Strength', strength, AppTheme.vitality, '30%'),
                const SizedBox(height: 10),
                _scoreBar('🔥 Vitality', vitality, const Color(0xFFFF9F0A), '30%'),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _scoreBar(String label, double value, Color color, String weight) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: AppTheme.surfaceVariant,
              color: color,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            value.toStringAsFixed(0),
            textAlign: TextAlign.right,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13),
          ),
        ),
        const SizedBox(width: 6),
        Text(weight,
            style: const TextStyle(
                color: AppTheme.textTertiary, fontSize: 11)),
      ],
    );
  }
}

/// Draws the horseshoe arc (240°) from bottom-left to bottom-right.
class _ArcPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  const _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 18.0;
    const startAngle = 150.0 * math.pi / 180; // bottom-left
    const sweepTotal = 240.0 * math.pi / 180; // 240-degree arc

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + 10),
      width: size.width - strokeWidth,
      height: size.height * 1.3 - strokeWidth,
    );

    // Background track
    final trackPaint = Paint()
      ..color = AppTheme.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);

    if (progress <= 0) return;

    // Progress arc — gradient-like using two colors
    final progressPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        rect, startAngle, sweepTotal * progress, false, progressPaint);

    // Glow dot at tip
    final angle = startAngle + sweepTotal * progress;
    final cx = rect.center.dx + (rect.width / 2) * math.cos(angle);
    final cy = rect.center.dy + (rect.height / 2) * math.sin(angle);

    final dotPaint = Paint()..color = AppTheme.primary;
    canvas.drawCircle(Offset(cx, cy), 9, dotPaint);

    final dotCorePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(cx, cy), 4, dotCorePaint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}
