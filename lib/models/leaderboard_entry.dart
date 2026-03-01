// lib/models/leaderboard_entry.dart

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int pulsePoints;
  final String? photoUrl;
  final int rank;
  final double activityScore;
  final double strengthScore;
  final double vitalityScore;
  final double bmi;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.pulsePoints,
    this.photoUrl,
    required this.rank,
    this.activityScore = 0,
    this.strengthScore = 0,
    this.vitalityScore = 0,
    this.bmi = 22,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardEntry(
      uid: map['uid'] ?? '',
      displayName: map['display_name'] ?? 'Anonymous',
      pulsePoints: (map['pulse_points'] ?? 0).toInt(),
      photoUrl: map['photo_url'],
      rank: rank,
      activityScore: (map['activity_score'] ?? 0).toDouble(),
      strengthScore: (map['strength_score'] ?? 0).toDouble(),
      vitalityScore: (map['vitality_score'] ?? 0).toDouble(),
      bmi: (map['bmi'] ?? 22).toDouble(),
    );
  }
}

enum LeaderboardFilter { global, location, organization, weightClass }

extension LeaderboardFilterLabel on LeaderboardFilter {
  String get label {
    switch (this) {
      case LeaderboardFilter.global:
        return 'Global';
      case LeaderboardFilter.location:
        return 'Location';
      case LeaderboardFilter.organization:
        return 'My Org';
      case LeaderboardFilter.weightClass:
        return 'Weight Class';
    }
  }
}
