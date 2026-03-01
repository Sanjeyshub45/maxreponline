// lib/services/places_service.dart
//
// Google Places Autocomplete + Geocoding for the Profile Setup screen.
// API key: provided by user (AIzaSyBA5a0i-3-iXobw3QSs1No1uggevU6TPFQ)

import 'dart:convert';
import 'package:http/http.dart' as http;

const _kApiKey = 'AIzaSyBA5a0i-3-iXobw3QSs1No1uggevU6TPFQ';

class PlacePrediction {
  final String placeId;
  final String mainText;       // e.g. "IIT Bombay"
  final String secondaryText;  // e.g. "Mumbai, Maharashtra, India"

  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  String get fullText =>
      secondaryText.isNotEmpty ? '$mainText, $secondaryText' : mainText;
}

class PlaceDetails {
  final String name;
  final String district;
  final String state;
  final String country;

  const PlaceDetails({
    required this.name,
    required this.district,
    required this.state,
    required this.country,
  });
}

class PlacesService {
  static const _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  /// Fetch autocomplete predictions for a college/organisation query.
  Future<List<PlacePrediction>> autocomplete(String input) async {
    if (input.trim().length < 2) return [];

    final uri = Uri.parse(_autocompleteUrl).replace(queryParameters: {
      'input': input,
      'types': 'establishment',
      'key': _kApiKey,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return [];

      final predictions = data['predictions'] as List<dynamic>;
      return predictions.map((p) {
        final structured = p['structured_formatting'] as Map<String, dynamic>;
        return PlacePrediction(
          placeId: p['place_id'] as String,
          mainText: structured['main_text'] as String? ?? '',
          secondaryText: structured['secondary_text'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch district, state, country for a given [placeId].
  Future<PlaceDetails?> getDetails(String placeId, String placeName) async {
    final uri = Uri.parse(_detailsUrl).replace(queryParameters: {
      'place_id': placeId,
      'fields': 'name,address_components',
      'key': _kApiKey,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final result = data['result'] as Map<String, dynamic>;
      final components =
          result['address_components'] as List<dynamic>? ?? [];

      String district = '';
      String state = '';
      String country = '';

      for (final comp in components) {
        final types = List<String>.from(comp['types'] as List<dynamic>);
        final longName = comp['long_name'] as String;

        if (types.contains('locality') ||
            types.contains('administrative_area_level_2') ||
            types.contains('sublocality_level_1')) {
          if (district.isEmpty) district = longName;
        }
        if (types.contains('administrative_area_level_1')) {
          state = longName;
        }
        if (types.contains('country')) {
          country = longName;
        }
      }

      return PlaceDetails(
        name: result['name'] as String? ?? placeName,
        district: district,
        state: state,
        country: country,
      );
    } catch (_) {
      return null;
    }
  }
}
