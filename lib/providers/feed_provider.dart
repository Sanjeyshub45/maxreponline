// lib/providers/feed_provider.dart

import 'package:flutter/foundation.dart';
import '../models/feed_post.dart';
import '../services/firestore_service.dart';
import '../services/demo_data.dart';

class FeedProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final bool demoMode;

  // Local kudos state for demo mode
  final Map<String, int> _kudosOverride = {};

  FeedProvider({this.demoMode = false});

  Stream<List<FeedPost>> get feedStream {
    if (demoMode) {
      return Stream.value(DemoData.feed);
    }
    return _firestoreService.streamFeed();
  }

  Future<void> addKudos(String postId, String fromUid) async {
    if (demoMode) {
      _kudosOverride[postId] = (_kudosOverride[postId] ?? 0) + 1;
      notifyListeners();
      return;
    }
    await _firestoreService.addKudos(postId, fromUid);
  }
}
