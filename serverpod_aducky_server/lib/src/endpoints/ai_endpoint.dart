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
import '../generated/protocol.dart';

class AiEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  /// Process natural language instructions using Claude (Anthropic API)
  /// to edit, shift, add, or reschedule events for the day.
  Future<AiScheduleResponse> editScheduleWithClaude(
    Session session, {
    required String prompt,
    required List<CalendarEvent> currentEvents,
  }) async {
    // 1. Resolve Anthropic API Key
    final apiKey =
        Platform.environment['ANTHROPIC_API_KEY'] ??
        session.serverpod.getPassword('anthropicApiKey') ??
        session.serverpod.getPassword('claudeApiKey') ??
        session.serverpod.getPassword('anthropic_api_key');

    final bool hasKey = apiKey != null && apiKey.trim().isNotEmpty;

    if (hasKey) {
      try {
        session.log(
          'AiEndpoint: Querying Anthropic Claude API for schedule edit...',
          level: LogLevel.info,
        );
        return await _callClaudeApi(
          session,
          apiKey: apiKey.trim(),
          prompt: prompt,
          currentEvents: currentEvents,
        );
      } catch (e, st) {
        session.log(
          'AiEndpoint: Error calling Claude API: $e\n$st. Falling back to intelligent heuristic scaffold.',
          level: LogLevel.warning,
        );
        // Fall back gracefully to the heuristic processor with error note
        final fallback = _simulateClaudeScheduleEdit(prompt, currentEvents);
        return AiScheduleResponse(
          success: fallback.success,
          summary: '${fallback.summary} (Note: Claude API call error: $e)',
          suggestedEvents: fallback.suggestedEvents,
          actionsTaken: fallback.actionsTaken,
          apiKeyConfigured: true,
          error: e.toString(),
        );
      }
    }

    // 2. If no API key is configured yet, provide intelligent scaffold simulation
    session.log(
      'AiEndpoint: ANTHROPIC_API_KEY not configured. Running intelligent Claude mock scaffold.',
      level: LogLevel.info,
    );
    return _simulateClaudeScheduleEdit(prompt, currentEvents);
  }

  /// Calls Anthropic Claude Messages API (claude-3-5-sonnet-20241022)
  Future<AiScheduleResponse> _callClaudeApi(
    Session session, {
    required String apiKey,
    required String prompt,
    required List<CalendarEvent> currentEvents,
  }) async {
    final now = DateTime.now().toUtc();
    final eventsJson = currentEvents
        .map(
          (e) => {
            'eventId': e.eventId,
            'title': e.title,
            'startTime': e.startTime.toIso8601String(),
            'endTime': e.endTime.toIso8601String(),
            'location': e.location,
            'startLocation': e.startLocation,
            'transportMode': e.transportMode ?? 'driving',
            'isDeleted': e.isDeleted,
          },
        )
        .toList();

    const systemPrompt = '''
You are an expert AI calendar scheduling assistant for 'a Ducky', a mindful productivity and smart calendar app.
The user wants you to edit or adjust their calendar events for today based on their natural language instructions.
Given the user's prompt and current events list in JSON:

Analyze the request and update the schedule accordingly.
You MUST reply with ONLY a single valid JSON object with the following schema:
{
  "summary": "A friendly, concise summary of the changes made (1-2 sentences).",
  "actionsTaken": [
    "Bullet point description of each change"
  ],
  "events": [
    {
      "eventId": "existing eventId or 'ai_new_<timestamp>' if newly created",
      "title": "string",
      "startTime": "ISO-8601 string (e.g. 2026-10-09T14:30:00Z)",
      "endTime": "ISO-8601 string",
      "location": "string or null",
      "startLocation": "string or null",
      "transportMode": "driving | walking | transit | bicycling",
      "isDeleted": false
    }
  ]
}
If the user asks to delete or cancel an event, set its "isDeleted" to true.
Do NOT include markdown backticks or any other text outside the JSON object.
''';

    final userContent =
        '''
Reference Current Time (UTC): ${now.toIso8601String()}

Current Events:
${jsonEncode(eventsJson)}

User Request:
"$prompt"
''';

    final requestBody = jsonEncode({
      'model': 'claude-3-5-sonnet-20241022',
      'max_tokens': 2500,
      'system': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userContent},
      ],
    });

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Claude API returned HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final contentList = data['content'] as List<dynamic>?;
    if (contentList == null || contentList.isEmpty) {
      throw Exception('Empty content returned from Claude API');
    }

    String rawText = '';
    for (final part in contentList) {
      if (part is Map<String, dynamic> && part['text'] != null) {
        rawText += part['text'].toString();
      }
    }

    // Strip code fences if model enclosed JSON in ```json ... ```
    String cleanJson = rawText.trim();
    if (cleanJson.startsWith('```json')) {
      cleanJson = cleanJson.substring(7);
    } else if (cleanJson.startsWith('```')) {
      cleanJson = cleanJson.substring(3);
    }
    if (cleanJson.endsWith('```')) {
      cleanJson = cleanJson.substring(0, cleanJson.length - 3);
    }
    cleanJson = cleanJson.trim();

    final parsedJson = jsonDecode(cleanJson) as Map<String, dynamic>;
    final summary = parsedJson['summary'] as String? ?? 'Schedule updated.';
    final actionsList =
        (parsedJson['actionsTaken'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final eventsRaw = parsedJson['events'] as List<dynamic>? ?? [];
    final List<CalendarEvent> updatedEvents = [];

    for (final item in eventsRaw) {
      if (item is Map<String, dynamic>) {
        final startTimeStr = item['startTime']?.toString();
        final endTimeStr = item['endTime']?.toString();
        if (startTimeStr == null || endTimeStr == null) continue;

        final startTime = DateTime.tryParse(startTimeStr) ?? DateTime.now();
        final endTime =
            DateTime.tryParse(endTimeStr) ??
            startTime.add(const Duration(minutes: 30));

        updatedEvents.add(
          CalendarEvent(
            eventId:
                item['eventId']?.toString() ??
                'ai_${DateTime.now().millisecondsSinceEpoch}',
            title: item['title']?.toString() ?? 'Event',
            startTime: startTime,
            endTime: endTime,
            location: item['location']?.toString(),
            startLocation: item['startLocation']?.toString(),
            transportMode: item['transportMode']?.toString() ?? 'driving',
            bufferMinutes: item['bufferMinutes'] is int
                ? item['bufferMinutes'] as int
                : null,
            isDeleted: item['isDeleted'] == true,
          ),
        );
      }
    }

    return AiScheduleResponse(
      success: true,
      summary: summary,
      suggestedEvents: updatedEvents,
      actionsTaken: actionsList,
      apiKeyConfigured: true,
      error: null,
    );
  }

  /// Intelligent local scaffold simulation for immediate interactive testing
  /// when ANTHROPIC_API_KEY is not yet populated.
  AiScheduleResponse _simulateClaudeScheduleEdit(
    String prompt,
    List<CalendarEvent> currentEvents,
  ) {
    final lower = prompt.toLowerCase();
    final List<CalendarEvent> modifiedEvents = [];
    final List<String> actions = [];
    String summary = '';

    // Copy existing events to work on
    final events = currentEvents
        .map(
          (e) => CalendarEvent(
            id: e.id,
            userId: e.userId,
            eventId: e.eventId,
            title: e.title,
            startTime: e.startTime,
            endTime: e.endTime,
            location: e.location,
            startLocation: e.startLocation,
            transportMode: e.transportMode,
            bufferMinutes: e.bufferMinutes,
            isDeleted: e.isDeleted,
          ),
        )
        .toList();

    // 1. Shifting / delaying events
    if (lower.contains('delay') ||
        lower.contains('push') ||
        lower.contains('shift') ||
        lower.contains('move') ||
        lower.contains('postpone')) {
      int shiftMinutes = 30; // default 30 min shift
      final match = RegExp(r'(\d+)\s*(?:min|m|hour|h|hr)').firstMatch(lower);
      if (match != null) {
        final val = int.tryParse(match.group(1) ?? '30') ?? 30;
        if (lower.contains('hour') || lower.contains('hr')) {
          shiftMinutes = val * 60;
        } else {
          shiftMinutes = val;
        }
      }

      final isAfternoon =
          lower.contains('afternoon') || lower.contains('after lunch');
      final isMorning = lower.contains('morning');

      for (var e in events) {
        final localHour = e.startTime.toLocal().hour;
        bool shouldShift = false;
        if (isAfternoon) {
          shouldShift = localHour >= 12;
        } else if (isMorning) {
          shouldShift = localHour < 12;
        } else {
          shouldShift = true;
        }

        if (shouldShift) {
          e.startTime = e.startTime.add(Duration(minutes: shiftMinutes));
          e.endTime = e.endTime.add(Duration(minutes: shiftMinutes));
          actions.add('Shifted "${e.title}" by +${shiftMinutes}m');
        }
        modifiedEvents.add(e);
      }

      summary =
          'Claude adjusted your schedule: shifted ${actions.length} event(s) by $shiftMinutes minutes.';
    }
    // 2. Add an event (lunch, gym, coffee, focus break)
    else if (lower.contains('add') ||
        lower.contains('schedule') ||
        lower.contains('insert') ||
        lower.contains('lunch') ||
        lower.contains('coffee') ||
        lower.contains('gym') ||
        lower.contains('break')) {
      String newTitle = 'Focus Break';
      int durationMinutes = 30;
      DateTime start = DateTime.now().toLocal();

      if (lower.contains('lunch')) {
        newTitle = 'Lunch Break';
        durationMinutes = 45;
        start = DateTime(start.year, start.month, start.day, 12, 30);
      } else if (lower.contains('coffee')) {
        newTitle = 'Coffee Break';
        durationMinutes = 20;
        start = DateTime(start.year, start.month, start.day, 15, 0);
      } else if (lower.contains('gym')) {
        newTitle = 'Gym Session';
        durationMinutes = 60;
        start = DateTime(start.year, start.month, start.day, 17, 30);
      } else {
        newTitle = 'Focus Block';
        durationMinutes = 45;
        start = DateTime(start.year, start.month, start.day, 14, 0);
      }

      final newEvent = CalendarEvent(
        eventId: 'ai_new_${DateTime.now().millisecondsSinceEpoch}',
        title: newTitle,
        startTime: start.toUtc(),
        endTime: start.add(Duration(minutes: durationMinutes)).toUtc(),
        location: null,
        startLocation: null,
        transportMode: 'walking',
        isDeleted: false,
      );

      modifiedEvents.addAll(events);
      modifiedEvents.add(newEvent);
      actions.add(
        'Scheduled new "$newTitle" (${durationMinutes}m) at ${start.hour}:${start.minute.toString().padLeft(2, '0')}',
      );
      summary = 'Claude created a new "$newTitle" block in your schedule.';
    }
    // 3. Clear / cancel / delete events
    else if (lower.contains('clear') ||
        lower.contains('delete') ||
        lower.contains('cancel') ||
        lower.contains('remove')) {
      for (var e in events) {
        if (lower.contains('after 6') || lower.contains('evening')) {
          if (e.startTime.toLocal().hour >= 18) {
            e.isDeleted = true;
            actions.add('Marked "${e.title}" as cancelled');
          }
        } else if (lower.contains('after lunch')) {
          if (e.startTime.toLocal().hour >= 13) {
            e.isDeleted = true;
            actions.add('Marked "${e.title}" as cancelled');
          }
        } else {
          // Remove if title is mentioned
          if (lower.contains(e.title.toLowerCase())) {
            e.isDeleted = true;
            actions.add('Marked "${e.title}" as cancelled');
          }
        }
        modifiedEvents.add(e);
      }
      summary = 'Claude updated schedule: removed ${actions.length} event(s).';
    }
    // 4. Default general reorganization / buffer optimization
    else {
      // Add 15m buffer or tidy up
      for (var e in events) {
        modifiedEvents.add(e);
      }
      actions.add('Analyzed calendar with Claude instructions: "$prompt"');
      summary =
          'Claude reviewed your day. (Setup hint: Provide an ANTHROPIC_API_KEY in passwords.yaml or server environment to activate live Claude 3.5 Sonnet!)';
    }

    return AiScheduleResponse(
      success: true,
      summary: summary,
      suggestedEvents: modifiedEvents,
      actionsTaken: actions.isEmpty
          ? ['Prepared AI schedule scaffold for instruction: "$prompt"']
          : actions,
      apiKeyConfigured: false,
      error: null,
    );
  }
}
