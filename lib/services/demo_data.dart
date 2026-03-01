// lib/services/demo_data.dart
//
// Mock data used when Firebase is not yet configured (demo mode).

import '../models/user_model.dart';
import '../models/leaderboard_entry.dart';
import '../models/feed_post.dart';

class DemoData {
  static final UserModel currentUser = UserModel(
    uid: 'demo_user_1',
    displayName: 'Alex Kumar',
    age: 28,
    gender: 'male',
    heightCm: 178,
    weightKg: 82,
    bmi: 25.9,
    orgId: 'acme_corp',
    orgType: 'company',
    department: 'Engineering',
    district: 'Downtown',
    state: 'California',
    country: 'USA',
    pulsePoints: 3820,
    stravaLinked: false,
    activityScore: 68,
    strengthScore: 74,
    vitalityScore: 55,
  );

  static final List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(uid: 'u1', displayName: 'Priya Nair', pulsePoints: 7450, rank: 1, activityScore: 92, strengthScore: 88, vitalityScore: 80, bmi: 21.2),
    LeaderboardEntry(uid: 'u2', displayName: 'James Okafor', pulsePoints: 6800, rank: 2, activityScore: 85, strengthScore: 72, vitalityScore: 90, bmi: 23.5),
    LeaderboardEntry(uid: 'u3', displayName: 'Sara Chen', pulsePoints: 5910, rank: 3, activityScore: 70, strengthScore: 94, vitalityScore: 65, bmi: 22.1),
    LeaderboardEntry(uid: 'u4', displayName: 'Marcus Webb', pulsePoints: 4500, rank: 4, activityScore: 60, strengthScore: 78, vitalityScore: 72, bmi: 27.3),
    LeaderboardEntry(uid: 'demo_user_1', displayName: 'Alex Kumar', pulsePoints: 3820, rank: 5, activityScore: 68, strengthScore: 74, vitalityScore: 55, bmi: 25.9),
    LeaderboardEntry(uid: 'u6', displayName: 'Fatima Hassan', pulsePoints: 3200, rank: 6, activityScore: 55, strengthScore: 61, vitalityScore: 80, bmi: 20.8),
    LeaderboardEntry(uid: 'u7', displayName: 'Leo da Silva', pulsePoints: 2800, rank: 7, activityScore: 48, strengthScore: 70, vitalityScore: 50, bmi: 29.1),
    LeaderboardEntry(uid: 'u8', displayName: 'Hannah Müller', pulsePoints: 2400, rank: 8, activityScore: 40, strengthScore: 55, vitalityScore: 65, bmi: 19.5),
    LeaderboardEntry(uid: 'u9', displayName: 'Raj Patel', pulsePoints: 1900, rank: 9, activityScore: 35, strengthScore: 48, vitalityScore: 55, bmi: 24.7),
    LeaderboardEntry(uid: 'u10', displayName: 'Chloe Martin', pulsePoints: 1200, rank: 10, activityScore: 25, strengthScore: 30, vitalityScore: 40, bmi: 21.0),
  ];

  static final List<FeedPost> feed = [
    FeedPost(
      id: 'f1',
      userId: 'u1',
      displayName: 'Priya Nair',
      type: 'rank_up',
      content: 'Just climbed to #1 globally! 🔥 3km morning run + 60 pushups today.',
      kudos: 14,
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      metadata: {'points': 320},
    ),
    FeedPost(
      id: 'f2',
      userId: 'u2',
      displayName: 'James Okafor',
      type: 'workout',
      content: 'Weekly pushup check-in: 55 reps. Feeling the grind 💪',
      kudos: 7,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      metadata: {'points': 185},
    ),
    FeedPost(
      id: 'f3',
      userId: 'u4',
      displayName: 'Marcus Webb',
      type: 'milestone',
      content: 'Hit 4500 Pulse Points! First time cracking the top-5 in Acme Corp 🏆',
      kudos: 22,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      metadata: {'points': 500},
    ),
    FeedPost(
      id: 'f4',
      userId: 'u3',
      displayName: 'Sara Chen',
      type: 'workout',
      content: 'New PR: 78 unbroken pushups. The gender bonus is REAL — 97 effective reps 😤',
      kudos: 19,
      timestamp: DateTime.now().subtract(const Duration(hours: 9)),
      metadata: {'points': 245},
    ),
    FeedPost(
      id: 'f5',
      userId: 'u6',
      displayName: 'Fatima Hassan',
      type: 'workout',
      content: 'Consistency score finally went green. 8,200 steps yesterday 🚶‍♀️',
      kudos: 5,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {'points': 90},
    ),
  ];
}
