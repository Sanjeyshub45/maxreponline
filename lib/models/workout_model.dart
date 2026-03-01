// lib/models/workout_model.dart

class WorkoutModel {
  final String? id;
  final String userId;
  final int reps;
  final double bodyWeightKg;
  final double strengthPoints;
  final DateTime timestamp;

  const WorkoutModel({
    this.id,
    required this.userId,
    required this.reps,
    required this.bodyWeightKg,
    required this.strengthPoints,
    required this.timestamp,
  });

  /// Server-side formula:
  /// StrengthPoints = (reps × bodyWeight × 0.70) × genderMultiplier
  static double calculateStrengthPoints(
    int reps,
    double bodyWeightKg,
    double genderMultiplier,
  ) {
    return (reps * bodyWeightKg * 0.70) * genderMultiplier;
  }

  factory WorkoutModel.fromMap(String id, Map<String, dynamic> map) {
    return WorkoutModel(
      id: id,
      userId: map['user_id'] ?? '',
      reps: (map['reps'] ?? 0).toInt(),
      bodyWeightKg: (map['body_weight_kg'] ?? 0).toDouble(),
      strengthPoints: (map['strength_points'] ?? 0).toDouble(),
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'reps': reps,
      'body_weight_kg': bodyWeightKg,
      'strength_points': strengthPoints,
      'timestamp': timestamp,
    };
  }
}
