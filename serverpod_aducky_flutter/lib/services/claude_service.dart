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

import 'package:serverpod_aducky_client/serverpod_aducky_client.dart';
import '../client.dart';

/// Service responsible for communicating with Claude AI scheduling endpoint
/// in Serverpod to intelligently edit, shift, add, or reschedule calendar events.
class ClaudeService {
  static final ClaudeService _instance = ClaudeService._internal();
  factory ClaudeService() => _instance;
  ClaudeService._internal();

  /// Submits user's natural language scheduling instruction to Claude.
  Future<AiScheduleResponse> editScheduleWithClaude({
    required String prompt,
    required List<CalendarEvent> currentEvents,
  }) async {
    try {
      final response = await client.ai.editScheduleWithClaude(
        prompt: prompt,
        currentEvents: currentEvents,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to process AI instructions with Claude: $e');
    }
  }
}
