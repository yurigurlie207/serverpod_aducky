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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serverpod_aducky_client/serverpod_aducky_client.dart';
import '../client.dart';
import '../theme/app_theme.dart';

class SmsNotificationService {
  /// Sends a countdown departure alert (at 30, 20, or 10 minutes before departure).
  static Future<bool> sendDepartureNotification({
    required BuildContext context,
    required String phoneNumber,
    required CalendarEvent event,
    required int milestoneMinutes,
    required DateTime leaveByTime,
    required DateTime eventStartTime,
  }) async {
    final eventStartStr = DateFormat(
      'h:mm a',
    ).format(eventStartTime.toLocal()).toLowerCase();
    final leaveByStr = DateFormat(
      'h:mm a',
    ).format(leaveByTime.toLocal()).toLowerCase();

    final String message;
    if (milestoneMinutes == 30) {
      message =
          "a Ducky: 30 minutes until departure for '${event.title}'! Leave by $leaveByStr to arrive calmly on time ($eventStartStr).";
    } else if (milestoneMinutes == 20) {
      message =
          "a Ducky: 20 minutes until departure for '${event.title}'! Get ready to leave by $leaveByStr.";
    } else if (milestoneMinutes == 10) {
      message =
          "a Ducky: 10 minutes until departure for '${event.title}'! Time to leave by $leaveByStr to make your $eventStartStr destination.";
    } else {
      message =
          "a Ducky: $milestoneMinutes mins until departure for '${event.title}'! Leave by $leaveByStr to arrive on time ($eventStartStr).";
    }

    debugPrint(
      '📱 [SMS Alert $milestoneMinutes min] To: $phoneNumber | Body: "$message"',
    );

    bool twilioDelivered = false;
    try {
      twilioDelivered = await client.notification.sendDepartureAlert(
        toPhoneNumber: phoneNumber,
        eventTitle: event.title,
        minutesBeforeDeparture: milestoneMinutes,
        leaveByTime: leaveByTime.toUtc(),
        eventStartTime: eventStartTime.toUtc(),
      );
    } catch (e) {
      debugPrint('Error invoking notification.sendDepartureAlert: $e');
    }

    if (!context.mounted) return twilioDelivered;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.darkTeal,
        duration: const Duration(seconds: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppTheme.goldenYellow.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.goldenYellow.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sms_rounded,
                color: AppTheme.goldenYellow,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Text Notification ($milestoneMinutes min alert)',
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.goldenYellow,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        phoneNumber,
                        style: GoogleFonts.fredoka(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    twilioDelivered
                        ? 'Twilio SMS Delivered ✓'
                        : 'Simulated in-app (add Twilio keys in passwords.yaml)',
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      color: twilioDelivered
                          ? Colors.greenAccent
                          : Colors.orangeAccent.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return twilioDelivered;
  }

  /// Sends a test SMS to the user's phone number to verify Twilio integration.
  static Future<bool> sendTestSms({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    bool delivered = false;
    try {
      delivered = await client.notification.sendTestSms(
        toPhoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('Error sending test SMS via client: $e');
    }

    if (!context.mounted) return delivered;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.darkTeal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: delivered ? Colors.greenAccent : AppTheme.goldenYellow,
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        content: Row(
          children: [
            Icon(
              delivered
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: delivered ? Colors.greenAccent : AppTheme.goldenYellow,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivered
                        ? 'Test SMS Delivered via Twilio ✓'
                        : 'Test SMS Triggered',
                    style: GoogleFonts.fredoka(
                      color: delivered
                          ? Colors.greenAccent
                          : AppTheme.goldenYellow,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    delivered
                        ? 'Sent to $phoneNumber: "You have enabled notifications from a Ducky"'
                        : 'Message sent to $phoneNumber: "You have enabled notifications from a Ducky". Set Twilio credentials in config/passwords.yaml for carrier delivery.',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return delivered;
  }

  /// Backward-compatible 15-minute alert helper.
  static Future<void> send15MinuteNotification({
    required BuildContext context,
    required String phoneNumber,
    required CalendarEvent event,
    required Duration remaining,
    required DateTime leaveByTime,
  }) async {
    await sendDepartureNotification(
      context: context,
      phoneNumber: phoneNumber,
      event: event,
      milestoneMinutes: 15,
      leaveByTime: leaveByTime,
      eventStartTime: event.startTime,
    );
  }
}
