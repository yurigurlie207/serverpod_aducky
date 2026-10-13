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

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsLauncherService {
  /// Opens Google Maps directions between [origin] and [destination].
  /// On mobile devices, this opens the Google Maps app.
  /// On web or desktop, it opens Google Maps directions in the browser.
  static Future<bool> openGoogleMapsDirections({
    required String origin,
    required String destination,
    String? transportMode,
  }) async {
    final cleanOrigin = origin.trim();
    final cleanDest = destination.trim();
    if (cleanOrigin.isEmpty || cleanDest.isEmpty) {
      return false;
    }

    String mode = 'driving';
    final lower = (transportMode ?? 'driving').toLowerCase();
    if (lower.contains('walk')) {
      mode = 'walking';
    } else if (lower.contains('bike') || lower.contains('bicycl')) {
      mode = 'bicycling';
    } else if (lower.contains('transit') ||
        lower.contains('bus') ||
        lower.contains('train')) {
      mode = 'transit';
    }

    // Google Maps universal directions URL (cross-platform, iOS, Android, Web)
    final universalUri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': cleanOrigin,
      'destination': cleanDest,
      'travelmode': mode,
    });

    // Native iOS Google Maps app scheme if available
    final iosSchemeUri = Uri.parse(
      'comgooglemaps://?saddr=${Uri.encodeComponent(cleanOrigin)}'
      '&daddr=${Uri.encodeComponent(cleanDest)}'
      '&directionsmode=$mode',
    );

    try {
      // 1. Try native Google Maps URL scheme if on iOS and supported
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        if (await canLaunchUrl(iosSchemeUri)) {
          return await launchUrl(
            iosSchemeUri,
            mode: LaunchMode.externalApplication,
          );
        }
      }

      // 2. Launch universal Google Maps URL with externalApplication mode
      // This routes directly to Google Maps app on Android and iOS (if installed),
      // and opens the browser on Web / Desktop.
      if (await canLaunchUrl(universalUri)) {
        return await launchUrl(
          universalUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Error launching Google Maps directions: $e');
    }

    // 3. Fallback to default browser launch
    try {
      return await launchUrl(universalUri);
    } catch (e) {
      debugPrint('Fallback launchUrl failed: $e');
      return false;
    }
  }
}
