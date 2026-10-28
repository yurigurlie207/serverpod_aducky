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
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

class TwilioService {
  static String? getPassword(Session session, String key) {
    // 1. Check environment variable (e.g. TWILIO_ACCOUNT_SID)
    final envKey = key
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (m) => '_${m.group(0)}',
        )
        .toUpperCase();
    final envVal = Platform.environment[envKey];
    if (envVal != null && envVal.trim().isNotEmpty) {
      return envVal.trim();
    }

    // 2. Check session.passwords
    final sessionVal = session.passwords[key];
    if (sessionVal != null && sessionVal.trim().isNotEmpty) {
      return sessionVal.trim();
    }

    // 3. Fallback: dynamically read config/passwords.yaml on disk
    try {
      final file = File('config/passwords.yaml');
      if (file.existsSync()) {
        final lines = file.readAsLinesSync();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.startsWith('$key:')) {
            final val = trimmed
                .substring('$key:'.length)
                .trim()
                .replaceAll("'", '')
                .replaceAll('"', '');
            if (val.isNotEmpty) {
              return val;
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  static bool isConfigured(Session session) {
    final accountSid = getPassword(session, 'twilioAccountSid');
    final authToken = getPassword(session, 'twilioAuthToken');
    final fromNumber = getPassword(session, 'twilioPhoneNumber');

    final hasSid =
        accountSid != null &&
        accountSid.trim().isNotEmpty &&
        !accountSid.contains('YOUR_');
    final hasToken =
        authToken != null &&
        authToken.trim().isNotEmpty &&
        !authToken.contains('YOUR_');
    final hasFrom =
        fromNumber != null &&
        fromNumber.trim().isNotEmpty &&
        !fromNumber.contains('YOUR_');

    return hasSid && hasToken && hasFrom;
  }

  static Future<bool> sendSms(
    Session session, {
    required String toPhoneNumber,
    required String message,
  }) async {
    final accountSid = getPassword(session, 'twilioAccountSid');
    final authToken = getPassword(session, 'twilioAuthToken');
    final fromNumber = getPassword(session, 'twilioPhoneNumber');

    final configured = isConfigured(session);
    if (!configured) {
      session.log(
        '📱 [SMS Notification Log (Twilio unconfigured)]: To: $toPhoneNumber | Message: $message',
        level: LogLevel.info,
      );
      return false;
    }

    // Format destination number to standard E.164 (e.g. +13333333333)
    final digits = toPhoneNumber.replaceAll(RegExp(r'\D'), '');
    String formattedTo;
    if (toPhoneNumber.trim().startsWith('+')) {
      formattedTo = '+${toPhoneNumber.replaceAll(RegExp(r'[^\d]'), '')}';
    } else if (digits.length == 10) {
      formattedTo = '+1$digits';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      formattedTo = '+$digits';
    } else {
      formattedTo = '+$digits';
    }

    try {
      final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/${accountSid!.trim()}/Messages.json',
      );
      final basicAuth = base64Encode(
        utf8.encode('${accountSid.trim()}:${authToken!.trim()}'),
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Basic $basicAuth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': formattedTo,
          'From': fromNumber!.trim(),
          'Body': message,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        session.log('📱 [Twilio SMS Sent Successfully] To: $formattedTo');
        return true;
      } else {
        session.log(
          '❌ [Twilio SMS Failed] Status: ${response.statusCode}, Body: ${response.body}',
          level: LogLevel.error,
        );
        return false;
      }
    } catch (e, stackTrace) {
      session.log(
        '❌ [Twilio SMS Exception] Error: $e',
        level: LogLevel.error,
        exception: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
