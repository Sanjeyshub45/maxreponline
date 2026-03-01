// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/leaderboard_entry.dart';
import '../models/feed_post.dart';
import '../models/workout_model.dart';

class FirestoreService {
  // Lazy getter — only accesses Firebase when a method is actually called,
  // preventing [core/no-app] if instantiated before Firebase.initializeApp().
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ─── Users ───────────────────────────────────────────────────────────────

  Future<void> createOrUpdateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Stream<UserModel?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  Future<void> linkStrava(String uid) async {
    await _db.collection('users').doc(uid).update({
      'strava_linked': true,
    });
  }

  // ─── Leaderboard ─────────────────────────────────────────────────────────

  Stream<List<LeaderboardEntry>> streamLeaderboard(
    LeaderboardFilter filter, {
    String? filterValue,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('users')
        .orderBy('pulse_points', descending: true)
        .limit(50);

    switch (filter) {
      case LeaderboardFilter.global:
        break;
      case LeaderboardFilter.organization:
        if (filterValue != null && filterValue.isNotEmpty) {
          query = query.where('org_id', isEqualTo: filterValue);
        }
        break;
      case LeaderboardFilter.location:
        if (filterValue != null && filterValue.isNotEmpty) {
          query = query.where('district', isEqualTo: filterValue);
        }
        break;
      case LeaderboardFilter.weightClass:
        if (filterValue == 'heavyweight') {
          query = query.where('bmi', isGreaterThan: 30);
        }
        break;
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.asMap().entries.map((entry) {
        return LeaderboardEntry.fromMap(entry.value.data(), entry.key + 1);
      }).toList();
    });
  }

  // ─── Workouts ─────────────────────────────────────────────────────────────

  Future<void> logWorkout(WorkoutModel workout) async {
    final userRef = _db.collection('users').doc(workout.userId);
    final workoutRef = userRef.collection('workouts').doc(); // Auto-ID

    await _db.runTransaction((transaction) async {
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) throw Exception('User not found');

      final userData = userSnap.data()!;
      final user = UserModel.fromMap(userData);

      // 1. Calculate PR points (only for reps > maxPushups)
      double prPoints = 0;
      int newMaxPushups = user.maxPushups;
      
      if (workout.reps > user.maxPushups) {
        final deltaReps = workout.reps - user.maxPushups;
        
        // Calculate points ONLY for the difference
        prPoints = WorkoutModel.calculateStrengthPoints(
            deltaReps, user.weightKg, user.genderMultiplier);
            
        newMaxPushups = workout.reps;
      }

      // 2. Calculate Consistency Points
      int consistencyPoints = 0;
      int newStreak = user.currentStreak;
      final now = DateTime.now();
      
      // Determine if a new day has started since last workout
      bool isNewDay = true;
      if (user.lastWorkoutDate != null) {
        final last = user.lastWorkoutDate!;
        if (last.year == now.year && last.month == now.month && last.day == now.day) {
          isNewDay = false; // Already worked out today
        }
      }

      if (isNewDay) {
        consistencyPoints = 10; // Daily base points
        
        if (user.lastWorkoutDate != null) {
          final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
          final lastDateOnly = DateTime(
              user.lastWorkoutDate!.year, user.lastWorkoutDate!.month, user.lastWorkoutDate!.day);
              
          if (lastDateOnly == yesterday) {
            newStreak++; // Streak continues
          } else {
            newStreak = 1; // Streak broken, restart
          }
        } else {
          newStreak = 1; // First ever workout
        }
      }

      final totalPointsEarned = prPoints + consistencyPoints;

      // Update the Workout record to reflect the *actual* points earned this session
      final actualWorkout = WorkoutModel(
        id: workoutRef.id,
        userId: workout.userId,
        reps: workout.reps,
        bodyWeightKg: workout.bodyWeightKg,
        strengthPoints: totalPointsEarned,
        timestamp: now,
      );

      // 3. Commit the changes
      transaction.set(workoutRef, actualWorkout.toMap());
      
      transaction.update(userRef, {
        'max_pushups': newMaxPushups,
        'current_streak': newStreak,
        'pulse_points': user.pulsePoints + totalPointsEarned,
        'strength_score': user.strengthScore + prPoints,
        'vitality_score': user.vitalityScore + consistencyPoints,
        'last_workout_date': Timestamp.fromDate(now),
      });
    });
  }

  Stream<List<WorkoutModel>> streamUserWorkouts(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => WorkoutModel.fromMap(d.id, d.data()))
            .toList());
  }


  // ─── Pulse Feed ──────────────────────────────────────────────────────────

  Stream<List<FeedPost>> streamFeed({int limit = 30}) {
    return _db
        .collection('feed')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedPost.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> createFeedPost(FeedPost post) async {
    await _db.collection('feed').add(post.toMap());
  }

  Future<void> addKudos(String postId, String fromUid) async {
    await _db.collection('feed').doc(postId).update({
      'kudos': FieldValue.increment(1),
      'kudos_from': FieldValue.arrayUnion([fromUid]),
    });
  }
}
