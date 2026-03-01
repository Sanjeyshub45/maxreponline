// lib/models/feed_post.dart

class FeedPost {
  final String id;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String type; // 'workout' | 'rank_up' | 'milestone'
  final String content;
  final int kudos;
  final DateTime timestamp;
  final Map<String, dynamic> metadata; // e.g., {reps, points, newRank}

  const FeedPost({
    required this.id,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.type,
    required this.content,
    this.kudos = 0,
    required this.timestamp,
    this.metadata = const {},
  });

  factory FeedPost.fromMap(String id, Map<String, dynamic> map) {
    return FeedPost(
      id: id,
      userId: map['user_id'] ?? '',
      displayName: map['display_name'] ?? 'Anonymous',
      photoUrl: map['photo_url'],
      type: map['type'] ?? 'workout',
      content: map['content'] ?? '',
      kudos: (map['kudos'] ?? 0).toInt(),
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as dynamic).toDate()
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'display_name': displayName,
      if (photoUrl != null) 'photo_url': photoUrl,
      'type': type,
      'content': content,
      'kudos': kudos,
      'timestamp': timestamp,
      'metadata': metadata,
    };
  }
}
