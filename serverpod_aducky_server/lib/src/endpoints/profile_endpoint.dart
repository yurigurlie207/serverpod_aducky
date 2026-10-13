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
    if (profile == null) {
      profile = UserLocationProfile(
        authUserId: authUserId,
        homeAddress: homeAddress,
        homeLat: homeLat,
        homeLng: homeLng,
        meetingBufferMinutes: meetingBufferMinutes ?? 0,
      );
      return await UserLocationProfile.db.insertRow(session, profile);
    } else {
      profile.homeAddress = homeAddress;
      profile.homeLat = homeLat;
      profile.homeLng = homeLng;
      profile.meetingBufferMinutes =
          meetingBufferMinutes ?? profile.meetingBufferMinutes ?? 0;
      return await UserLocationProfile.db.updateRow(session, profile);
    }
  }
}
