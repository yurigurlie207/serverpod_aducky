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

class CalendarService {
  // Singleton pattern so we don't initialize multiple times
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  Future<List<CalendarEvent>> getUpcomingEvents({
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      final events = await client.calendar.getUpcomingEvents(
        start: start,
        end: end,
      );
      return events;
    } catch (e) {
      throw Exception('Error fetching calendar events: $e');
    }
  }

  Future<bool> updateEvent(CalendarEvent event) async {
    try {
      return await client.calendar.updateEvent(event);
    } catch (e) {
      throw Exception('Error updating calendar event: $e');
    }
  }

  Future<bool> deleteEvent(CalendarEvent event) async {
    try {
      return await client.calendar.deleteEvent(event);
    } catch (e) {
      throw Exception('Error deleting calendar event: $e');
    }
  }
}
