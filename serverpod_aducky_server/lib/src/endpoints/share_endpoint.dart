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

import 'dart:math' as math;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import '../generated/protocol.dart';
import '../services/twilio_service.dart';

class ShareEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = math.Random.secure();
    final buffer = StringBuffer('dck_');
    for (int i = 0; i < 8; i++) {
      buffer.write(chars[rand.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  /// Creates a shareable live countdown link for an event.
  /// Works for both authenticated users and guests.
  Future<SharedEvent> createShareLink(
    Session session, {
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? startLocation,
    String? transportMode,
    int? travelMinutes,
    int? bufferMinutes,
    String? personName,
  }) async {
    final travel = travelMinutes ?? 0;
    final buffer = bufferMinutes ?? 0;
    final totalPadMinutes = travel + buffer;
    final leaveByTime = startTime.toUtc().subtract(
      Duration(minutes: totalPadMinutes),
    );

    final token = _generateToken();
    final nowUtc = DateTime.now().toUtc();
    final expiresAt = endTime.toUtc().add(const Duration(days: 7));

    final creatorId = session.authenticated?.authUserId;

    final sharedEvent = SharedEvent(
      shareToken: token,
      title: title.trim().isEmpty ? 'Focus Event' : title.trim(),
      startTime: startTime.toUtc(),
      endTime: endTime.toUtc(),
      location: location?.trim().isNotEmpty == true ? location!.trim() : null,
      startLocation: startLocation?.trim().isNotEmpty == true
          ? startLocation!.trim()
          : null,
      transportMode: transportMode ?? 'driving',
      travelMinutes: travel,
      bufferMinutes: buffer,
      leaveByTime: leaveByTime,
      personName: personName?.trim().isNotEmpty == true
          ? personName!.trim()
          : null,
      createdById: creatorId,
      createdAt: nowUtc,
      expiresAt: expiresAt,
    );

    return await SharedEvent.db.insertRow(session, sharedEvent);
  }

  /// Fetches a shared event by its unique share token.
  /// Open to everyone without authentication.
  Future<SharedEvent?> getSharedEvent(
    Session session,
    String token,
  ) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) return null;

    return await SharedEvent.db.findFirstRow(
      session,
      where: (t) => t.shareToken.equals(cleanToken),
    );
  }

  /// Sends the share link to a recipient either via SMS phone number or email.
  Future<bool> sendShareLink(
    Session session, {
    required String token,
    String? phoneNumber,
    String? email,
    required String shareUrl,
  }) async {
    final cleanToken = token.trim();
    final event = await SharedEvent.db.findFirstRow(
      session,
      where: (t) => t.shareToken.equals(cleanToken),
    );

    if (event == null) {
      session.log('Cannot send share link: Token $cleanToken not found.');
      return false;
    }

    bool success = false;

    // Send via SMS
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      final message =
          "a Ducky: Here is the live departure countdown & event details for '${event.title}': ${shareUrl.trim()}";
      final smsResult = await TwilioService.sendSms(
        session,
        toPhoneNumber: phoneNumber.trim(),
        message: message,
      );
      session.log(
        '📱 [Share via SMS] To: $phoneNumber, Result: $smsResult, Link: $shareUrl',
      );
      success = true;
    }

    // Send via Email / Log
    if (email != null && email.trim().isNotEmpty) {
      session.log(
        '✉️ [Share via Email] To: ${email.trim()} | Event: "${event.title}" | Link: ${shareUrl.trim()}',
        level: LogLevel.info,
      );
      success = true;
    }

    return success;
  }
}
