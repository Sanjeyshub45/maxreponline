// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int age;
  final String gender; // 'male' | 'female'
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String orgId; // company / college slug
  final String orgName; // human-readable name from Places API
  final String orgType; // 'company' | 'college'
  final String department;
  final String district;
  final String state;
  final String country;
  final int pulsePoints;
  final bool stravaLinked;
  final String? photoUrl;
  // Pulse Score sub-components (0–100 each)
  final double activityScore;
  final double strengthScore;
  final double vitalityScore;

  const UserModel({
    required this.uid,
    this.email = '',
    required this.displayName,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    this.orgId = '',
    this.orgName = '',
    this.orgType = 'company',
    this.department = '',
    this.district = '',
    this.state = '',
    this.country = '',
    this.pulsePoints = 0,
    this.stravaLinked = false,
    this.photoUrl,
    this.activityScore = 0,
    this.strengthScore = 0,
    this.vitalityScore = 0,
    this.maxPushups = 0,
    this.currentStreak = 0,
    this.lastWorkoutDate,
  });

  // Tracking fields for PRs and Consistency
  final int maxPushups;
  final int currentStreak;
  final DateTime? lastWorkoutDate;

  static double calculateBmi(double weightKg, double heightCm) {
    final h = heightCm / 100;
    return weightKg / (h * h);
  }

  /// BMI effort multiplier for cardio: heavier users get bonus (1.0x – 1.5x)
  double get bmiMultiplier {
    final idealBmi = gender == 'female' ? 21.5 : 22.0;
    if (bmi <= idealBmi) return 1.0;
    final excess = bmi - idealBmi;
    return (1.0 + (excess * 0.02)).clamp(1.0, 1.5);
  }

  /// Gender equity multiplier for strength (pushups)
  double get genderMultiplier => gender == 'female' ? 1.25 : 1.0;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['display_name'] ?? '',
      age: (map['age'] ?? 0).toInt(),
      gender: map['gender'] ?? 'male',
      heightCm: (map['height_cm'] ?? 0).toDouble(),
      weightKg: (map['weight_kg'] ?? 0).toDouble(),
      bmi: (map['bmi'] ?? 0).toDouble(),
      orgId: map['org_id'] ?? '',
      orgName: map['org_name'] ?? '',
      orgType: map['org_type'] ?? 'company',
      department: map['department'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      pulsePoints: (map['pulse_points'] ?? 0).toInt(),
      stravaLinked: map['strava_linked'] ?? false,
      photoUrl: map['photo_url'],
      activityScore: (map['activity_score'] ?? 0).toDouble(),
      strengthScore: (map['strength_score'] ?? 0).toDouble(),
      vitalityScore: (map['vitality_score'] ?? 0).toDouble(),
      maxPushups: (map['max_pushups'] ?? 0).toInt(),
      currentStreak: (map['current_streak'] ?? 0).toInt(),
      lastWorkoutDate: map['last_workout_date'] != null
          ? (map['last_workout_date'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'age': age,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': bmi,
      'org_id': orgId,
      'org_name': orgName,
      'org_type': orgType,
      'department': department,
      'district': district,
      'state': state,
      'country': country,
      'pulse_points': pulsePoints,
      'strava_linked': stravaLinked,
      if (photoUrl != null) 'photo_url': photoUrl,
      'activity_score': activityScore,
      'strength_score': strengthScore,
      'vitality_score': vitalityScore,
      'max_pushups': maxPushups,
      'current_streak': currentStreak,
      if (lastWorkoutDate != null) 'last_workout_date': lastWorkoutDate,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? bmi,
    String? orgId,
    String? orgName,
    String? orgType,
    String? department,
    String? district,
    String? state,
    String? country,
    int? pulsePoints,
    bool? stravaLinked,
    String? photoUrl,
    double? activityScore,
    double? strengthScore,
    double? vitalityScore,
    int? maxPushups,
    int? currentStreak,
    DateTime? lastWorkoutDate,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      orgId: orgId ?? this.orgId,
      orgName: orgName ?? this.orgName,
      orgType: orgType ?? this.orgType,
      department: department ?? this.department,
      district: district ?? this.district,
      state: state ?? this.state,
      country: country ?? this.country,
      pulsePoints: pulsePoints ?? this.pulsePoints,
      stravaLinked: stravaLinked ?? this.stravaLinked,
      photoUrl: photoUrl ?? this.photoUrl,
      activityScore: activityScore ?? this.activityScore,
      strengthScore: strengthScore ?? this.strengthScore,
      vitalityScore: vitalityScore ?? this.vitalityScore,
      maxPushups: maxPushups ?? this.maxPushups,
      currentStreak: currentStreak ?? this.currentStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
    );
  }
}
