import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart'; // We will create a model for PlaceSuggestion

class PlacesEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<PlaceSuggestion>> getSuggestions(
    Session session,
    String query,
  ) async {
    if (query.isEmpty) return [];

    final mapsApiKey = session.passwords['googleMapsApiKey'] ?? '';
    if (mapsApiKey.isEmpty) return [];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$mapsApiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['predictions'] != null) {
          final predictions = data['predictions'] as List;
          return predictions
              .map(
                (p) => PlaceSuggestion(
                  description: p['description'] as String,
                  placeId: p['place_id'] as String,
                ),
              )
              .toList();
        }
      } else {
        session.log(
          'Google API error: ${response.statusCode} - ${response.body}',
          level: LogLevel.error,
        );
      }
    } catch (e) {
      session.log('Error fetching suggestions: $e', level: LogLevel.error);
    }
    return [];
  }

  Future<LocationDetails?> getPlaceDetails(
    Session session,
    String placeId,
  ) async {
    final mapsApiKey = session.passwords['googleMapsApiKey'] ?? '';
    if (mapsApiKey.isEmpty) return null;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?place_id=${Uri.encodeComponent(placeId)}&key=$mapsApiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LocationDetails(
            lat: location['lat'] as double,
            lng: location['lng'] as double,
          );
        }
      }
    } catch (e) {
      session.log('Error fetching place details: $e', level: LogLevel.error);
    }
    return null;
  }
}
