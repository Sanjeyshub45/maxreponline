// lib/providers/leaderboard_provider.dart

import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';
import '../services/firestore_service.dart';
import '../services/demo_data.dart';

class LeaderboardProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final bool demoMode;

  LeaderboardFilter _filter = LeaderboardFilter.global;
  String? _filterValue;

  LeaderboardFilter get filter => _filter;
  String? get filterValue => _filterValue;

  LeaderboardProvider({this.demoMode = false});

  void setFilter(LeaderboardFilter filter, {String? filterValue}) {
    _filter = filter;
    _filterValue = filterValue;
    notifyListeners();
  }

  Stream<List<LeaderboardEntry>> get leaderboardStream {
    if (demoMode) {
      return Stream.value(DemoData.leaderboard);
    }
    return _firestoreService.streamLeaderboard(_filter, filterValue: _filterValue);
  }
}
