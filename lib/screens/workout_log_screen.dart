// lib/screens/workout_log_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workout_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final FirestoreService _db = FirestoreService();

  // Log dialog state
  int _reps = 20;

  Future<void> _showLogBottomSheet(BuildContext context) async {
    final user = context.read<UserAuthProvider>().user;
    if (user == null) return;

    _reps = user.maxPushups == 0 ? 20 : user.maxPushups + 1; // Default to a new PR
    
    // Calculate if it's a new day for consistency points
    bool isNewDay = true;
    if (user.lastWorkoutDate != null) {
      final last = user.lastWorkoutDate!;
      final now = DateTime.now();
      if (last.year == now.year && last.month == now.month && last.day == now.day) {
        isNewDay = false;
      }
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          
          // Live calculation for the preview UI
          double prPointsPreview = 0;
          if (_reps > user.maxPushups) {
            final delta = _reps - user.maxPushups;
            prPointsPreview = WorkoutModel.calculateStrengthPoints(
                delta, user.weightKg, user.genderMultiplier);
          }
          final int consistencyPreview = isNewDay ? 10 : 0;
          final double totalPreview = prPointsPreview + consistencyPreview;

          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Log Pushups',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),

                // Reps counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundBtn(Icons.remove, () {
                      setSheet(() {
                        if (_reps > 1) _reps--;
                      });
                    }),
                    const SizedBox(width: 24),
                    Column(
                      children: [
                        Text('$_reps',
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                height: 1)),
                        const Text('reps',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    _roundBtn(Icons.add, () {
                      setSheet(() {
                        _reps++;
                      });
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // Points preview 
                if (totalPreview > 0)
                  Column(
                    children: [
                      if (prPointsPreview > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '🌟 New PR! +${prPointsPreview.toStringAsFixed(1)} Strength Pts',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      if (consistencyPreview > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.vitality.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '🔥 Daily Streak! +$consistencyPreview Vitality Pts',
                                style: const TextStyle(
                                    color: AppTheme.vitality,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  Center(
                    child: Text(
                      'Must beat your PR of ${user.maxPushups} reps to earn Strength Points\n(Daily streak points already claimed today)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ),

                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // We pass the absolute reps user performed;
                        // FirestoreService calculates the exact delta inside Transaction.
                        final workout = WorkoutModel(
                          userId: user.uid,
                          reps: _reps,
                          bodyWeightKg: user.weightKg,
                          strengthPoints: totalPreview, // Display value; Server recalculates securely
                          timestamp: DateTime.now(),
                        );
                        await _db.logWorkout(workout);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                         if (ctx.mounted) {
                           ScaffoldMessenger.of(ctx).showSnackBar(
                             SnackBar(
                               content: Text('Failed to save: $e'),
                               backgroundColor: Colors.red.shade900,
                               behavior: SnackBarBehavior.floating,
                             ),
                           );
                         }
                      }
                    },
                    child: const Text('Save Workout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserAuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70), // Lift above bottom nav
        child: FloatingActionButton(
          onPressed: () => _showLogBottomSheet(context),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.black,
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      body: StreamBuilder<List<WorkoutModel>>(
        stream: _db.streamUserWorkouts(user.uid),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 2),
            );
          }

          final workouts = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // ─── Header ────────────────────────────────────────────────
              SliverSafeArea(
                bottom: false,
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Workouts',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary)),
                        ),
                        Icon(Icons.calendar_today_outlined,
                            color: AppTheme.textSecondary, size: 20),
                      ],
                    ),
                  ),
                ),
              ),

              if (workouts.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fitness_center,
                            size: 52, color: AppTheme.textTertiary),
                        SizedBox(height: 16),
                        Text('No workouts yet',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text('Tap + to log your first workout',
                            style: TextStyle(
                                color: AppTheme.textTertiary, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                ..._buildDateGroups(workouts),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDateGroups(List<WorkoutModel> workouts) {
    // Group by date
    final Map<String, List<WorkoutModel>> groups = {};
    for (final w in workouts) {
      final key = DateFormat('d MMMM').format(w.timestamp);
      groups.putIfAbsent(key, () => []).add(w);
    }

    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      // Date header (large, like "28 March")
      widgets.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Text(
            entry.key,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800),
          ),
        ),
      ));

      // Workout items for this date
      for (final w in entry.value) {
        widgets.add(SliverToBoxAdapter(child: _workoutRow(w)));
      }
    }

    return widgets;
  }

  Widget _workoutRow(WorkoutModel w) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('💪', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pushups',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  Text(
                    '${w.reps} reps',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${w.strengthPoints.toStringAsFixed(0)} pts',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                Text(
                  DateFormat('h:mm a').format(w.timestamp),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceVariant,
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }
}
