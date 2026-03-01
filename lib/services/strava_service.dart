// lib/services/strava_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StravaService {
  // Base URL for the Cloud Functions region
  static const _baseUrl =
      'https://us-central1-maxreponline.cloudfunctions.net';

  /// Gets a fresh Firebase ID token to authenticate requests.
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    // force: true refreshes the token regardless of caching
    return user.getIdToken(true);
  }

  /// Retrieves the secure OAuth URL from the backend and launches it in the browser
  Future<void> launchStravaAuth() async {
    try {
      final token = await _getIdToken();
      if (token == null) {
        debugPrint('Cannot link Strava: User is not logged in.');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/stravaLinkUrl'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        debugPrint('stravaLinkUrl error ${response.statusCode}: ${response.body}');
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final url = data['url'] as String;

      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        debugPrint('Could not launch Strava auth URL');
      }
    } catch (e) {
      debugPrint('Error launching Strava Auth: $e');
    }
  }

  /// Calls the secure backend function to fetch today's walking stats.
  /// Returns a Map: {'distance_km': double, 'pace_str': String}
  Future<Map<String, dynamic>?> fetchTodayWalkingStats() async {
    try {
      final token = await _getIdToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/fetchTodayWalk'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        debugPrint('fetchTodayWalk error ${response.statusCode}: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'distance_km': (data['distance_km'] as num).toDouble(),
        'pace_str': data['pace_str'] as String,
      };
    } catch (e) {
      debugPrint('Error fetching Strava stats from backend: $e');
      return null;
    }
  }
}
