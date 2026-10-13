/*
 * Copyright (c) 2026 MyCompany LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';

class TravelEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<TravelResult> getTravelTime(
    Session session, {
    required String origin,
    required String destination,
    required String mode,
  }) async {
    final mapsApiKey = session.passwords['googleMapsApiKey'] ?? '';

    // Google Maps Distance Matrix API url
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json'
      '?origins=${Uri.encodeComponent(origin)}'
      '&destinations=${Uri.encodeComponent(destination)}'
      '&mode=$mode'
      '&departure_time=now'
      '&key=$mapsApiKey',
    );

    int durationMinutes = 0;
    String distanceText = 'Unknown';

    if (mapsApiKey.isNotEmpty) {
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'OK' && data['rows'].isNotEmpty) {
            final elements = data['rows'][0]['elements'];
            if (elements.isNotEmpty && elements[0]['status'] == 'OK') {
              // 'duration_in_traffic' is available when departure_time is provided
              final durationObj =
                  elements[0]['duration_in_traffic'] ?? elements[0]['duration'];
              final seconds = durationObj['value'] as int;
              durationMinutes = (seconds / 60).ceil();
              distanceText = elements[0]['distance']['text'];
            }
          }
        }
      } catch (e) {
        session.log('Error fetching distance: $e', level: LogLevel.error);
      }
    } else {
      // Mock data if API key is not set
      durationMinutes = 25;
      distanceText = '10 km';
    }

    return TravelResult(
      durationMinutes: durationMinutes,
      distanceText: distanceText,
      weatherBufferMinutes: 0,
      totalMinutes: durationMinutes,
    );
  }
}
