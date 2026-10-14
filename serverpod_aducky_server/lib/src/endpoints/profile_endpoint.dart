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

import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'package:serverpod_auth_idp_server/core.dart'; // Ensure core.dart is imported

class ProfileEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<UserLocationProfile?> getProfile(Session session) async {
    final authUserId = session.authenticated?.authUserId;
    if (authUserId == null) return null;

    return await UserLocationProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
  }

  Future<UserLocationProfile> saveProfile(
    Session session, {
    required String homeAddress,
    required double homeLat,
    required double homeLng,
    int? meetingBufferMinutes,
  }) async {
    final authUserId = session.authenticated?.authUserId;
    if (authUserId == null) {
      throw Exception('User not authenticated');
    }

    var profile = await getProfile(session);
    final String oldHomeAddress = profile?.homeAddress.trim() ?? '';
    final String newHomeAddress = homeAddress.trim();
    final int effectiveBufferMinutes =
        meetingBufferMinutes ?? profile?.meetingBufferMinutes ?? 0;

    final UserLocationProfile savedProfile;
    if (profile == null) {
      profile = UserLocationProfile(
        authUserId: authUserId,
        homeAddress: homeAddress,
        homeLat: homeLat,
        homeLng: homeLng,
        meetingBufferMinutes: effectiveBufferMinutes,
      );
      savedProfile = await UserLocationProfile.db.insertRow(session, profile);
    } else {
      profile.homeAddress = homeAddress;
      profile.homeLat = homeLat;
      profile.homeLng = homeLng;
      profile.meetingBufferMinutes = effectiveBufferMinutes;
      savedProfile = await UserLocationProfile.db.updateRow(session, profile);
    }

    // Update all events for this user:
    // 1. Update bufferMinutes for all user events to match updated profile buffer time
    // 2. Update default starting location if home address was updated
    final userEvents = await CalendarEvent.db.find(
      session,
      where: (t) => t.userId.equals(authUserId),
    );
    for (var ev in userEvents) {
      bool changed = false;
      if (newHomeAddress.isNotEmpty) {
        final currentStart = ev.startLocation?.trim();
        final hasNoStart = currentStart == null || currentStart.isEmpty;
        final hadOldDefault =
            oldHomeAddress.isNotEmpty && currentStart == oldHomeAddress;
        if (hasNoStart || hadOldDefault) {
          ev.startLocation = newHomeAddress;
          changed = true;
        }
      } else if (oldHomeAddress.isNotEmpty) {
        final currentStart = ev.startLocation?.trim();
        if (currentStart == oldHomeAddress) {
          ev.startLocation = null;
          changed = true;
        }
      }

      if (ev.bufferMinutes != effectiveBufferMinutes) {
        ev.bufferMinutes = effectiveBufferMinutes;
        changed = true;
      }

      if (changed) {
        await CalendarEvent.db.updateRow(session, ev);
      }
    }

    // Invalidate local memory cache of Google events so all events use updated buffer and location
    String? email;
    try {
      final userProfile = await session.authenticated?.userProfile(session);
      email = userProfile?.email?.trim();
    } catch (_) {}
    await session.caches.local.invalidateKey(
      'cached_google_events_${authUserId.toString()}',
    );
    if (email != null && email.isNotEmpty) {
      await session.caches.local.invalidateKey('cached_google_events_$email');
      await session.caches.local.invalidateKey(
        'cached_google_events_${email.toLowerCase()}',
      );
    }

    return savedProfile;
  }
}
