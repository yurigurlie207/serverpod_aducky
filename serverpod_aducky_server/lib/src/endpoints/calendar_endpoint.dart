import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';
import 'package:serverpod_auth_idp_server/core.dart';

class CalendarEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<CalendarEvent>> getUpcomingEvents(
    Session session, {
    DateTime? start,
    DateTime? end,
  }) async {
    final userId = session.authenticated?.authUserId;
    if (userId == null) {
      return [];
    }

    try {
      final now = DateTime.now().toUtc();
      final timeMin =
          start?.toUtc() ?? DateTime.utc(now.year, now.month, now.day);
      final timeMax = end?.toUtc() ?? timeMin.add(const Duration(hours: 24));

      // Get authenticated user's profile to extract email
      String? email;
      try {
        final userProfile = await session.authenticated?.userProfile(session);
        email = userProfile?.email?.trim();
      } catch (_) {}

      // Check user location profile for home address and stored token
      var userLocProfile = await UserLocationProfile.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(userId),
      );
      final homeAddress = userLocProfile?.homeAddress.trim();

      // Retrieve Google access token from memory cache or persisted DB profile
      String? accessToken;
      if (email != null && email.isNotEmpty) {
        accessToken = await session.caches.local.get<String>(
          'google_token_$email',
        );
        accessToken ??= await session.caches.local.get<String>(
          'google_token_${email.toLowerCase()}',
        );
      }
      accessToken ??= await session.caches.local.get<String>(
        'google_token_${userId.toString()}',
      );
      accessToken ??= userLocProfile?.googleAccessToken;

      // If token was in memory, ensure it is persisted in PostgreSQL
      if (accessToken != null && accessToken.isNotEmpty) {
        if (userLocProfile != null) {
          if (userLocProfile.googleAccessToken != accessToken) {
            userLocProfile.googleAccessToken = accessToken;
            await UserLocationProfile.db.updateRow(session, userLocProfile);
          }
        } else {
          userLocProfile = await UserLocationProfile.db.insertRow(
            session,
            UserLocationProfile(
              authUserId: userId,
              homeAddress: '',
              homeLat: 0.0,
              homeLng: 0.0,
              meetingBufferMinutes: 0,
              googleAccessToken: accessToken,
            ),
          );
        }
      }

      List<CalendarEvent>? freshGoogleEvents;

      // 1. Pull directly from Google Calendar API
      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          final url = Uri.https(
            'www.googleapis.com',
            '/calendar/v3/calendars/primary/events',
            {
              'timeMin': timeMin.toIso8601String(),
              'timeMax': timeMax.toIso8601String(),
              'singleEvents': 'true',
              'orderBy': 'startTime',
            },
          );

          final response = await http.get(
            url,
            headers: {'Authorization': 'Bearer $accessToken'},
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final items = data['items'] as List<dynamic>? ?? [];

            final parsed = <CalendarEvent>[];
            for (var item in items) {
              final summary = item['summary'] as String? ?? 'No Title';
              final location = item['location'] as String?;
              final startMap = item['start'] as Map<String, dynamic>?;
              final endMap = item['end'] as Map<String, dynamic>?;
              if (startMap != null) {
                final dateTimeStr = startMap['dateTime'] ?? startMap['date'];
                if (dateTimeStr != null) {
                  final startTime = DateTime.parse(dateTimeStr).toUtc();
                  DateTime endTime = startTime.add(const Duration(hours: 1));
                  if (endMap != null) {
                    final endDateTimeStr = endMap['dateTime'] ?? endMap['date'];
                    if (endDateTimeStr != null) {
                      endTime = DateTime.parse(endDateTimeStr).toUtc();
                    }
                  }

                  final eventId = item['id'] as String? ?? '';
                  parsed.add(
                    CalendarEvent(
                      userId: userId,
                      eventId: eventId,
                      title: summary,
                      startTime: startTime,
                      endTime: endTime,
                      location: location,
                      startLocation:
                          homeAddress != null && homeAddress.isNotEmpty
                          ? homeAddress
                          : null,
                      transportMode: 'driving',
                      bufferMinutes: userLocProfile?.meetingBufferMinutes ?? 0,
                      isDeleted: false,
                    ),
                  );
                }
              }
            }

            freshGoogleEvents = parsed;

            // Cache in memory
            await session.caches.local.put(
              'cached_google_events_${userId.toString()}',
              parsed,
              lifetime: const Duration(hours: 24),
            );
            if (email != null) {
              await session.caches.local.put(
                'cached_google_events_$email',
                parsed,
                lifetime: const Duration(hours: 24),
              );
              await session.caches.local.put(
                'cached_google_events_${email.toLowerCase()}',
                parsed,
                lifetime: const Duration(hours: 24),
              );
            }

            // Sync with local DB, treating Google Calendar as source of truth
            final localEvents = await CalendarEvent.db.find(
              session,
              where: (t) => t.userId.equals(userId),
            );
            final localMap = {for (var e in localEvents) e.eventId: e};

            final freshEventIds = {for (var e in parsed) e.eventId};

            // Mark deleted any DB Google events that are no longer on Google Calendar
            for (var local in localEvents) {
              if (!local.eventId.startsWith('local_') &&
                  !freshEventIds.contains(local.eventId)) {
                if (local.isDeleted != true) {
                  local.isDeleted = true;
                  await CalendarEvent.db.updateRow(session, local);
                }
              }
            }

            // Upsert fresh Google events
            for (var ev in parsed) {
              final local = localMap[ev.eventId];
              if (local != null) {
                ev.id = local.id;
                final localStart = local.startLocation?.trim();
                if (localStart != null && localStart.isNotEmpty) {
                  ev.startLocation = localStart;
                } else if (homeAddress != null && homeAddress.isNotEmpty) {
                  ev.startLocation = homeAddress;
                } else {
                  ev.startLocation = null;
                }
                ev.transportMode = local.transportMode ?? 'driving';
                ev.bufferMinutes =
                    local.bufferMinutes ??
                    userLocProfile?.meetingBufferMinutes ??
                    0;
                ev.isDeleted = false;
                await CalendarEvent.db.updateRow(session, ev);
              } else {
                if (ev.startLocation == null ||
                    ev.startLocation!.trim().isEmpty) {
                  if (homeAddress != null && homeAddress.isNotEmpty) {
                    ev.startLocation = homeAddress;
                  }
                }
                ev.bufferMinutes ??= userLocProfile?.meetingBufferMinutes ?? 0;
                final inserted = await CalendarEvent.db.insertRow(session, ev);
                ev.id = inserted.id;
              }
            }
          } else {
            session.log(
              'Google Calendar returned ${response.statusCode}: ${response.body}',
              level: LogLevel.warning,
            );
          }
        } catch (apiError) {
          session.log(
            'Failed to fetch from Google Calendar API: $apiError',
            level: LogLevel.warning,
          );
        }
      }

      // 2. If Google Calendar API fetch did not succeed, fall back to server memory cache
      if (freshGoogleEvents == null) {
        freshGoogleEvents = await session.caches.local.get<List<CalendarEvent>>(
          'cached_google_events_${userId.toString()}',
        );
        if (freshGoogleEvents == null && email != null) {
          freshGoogleEvents = await session.caches.local
              .get<List<CalendarEvent>>('cached_google_events_$email');
          freshGoogleEvents ??= await session.caches.local
              .get<List<CalendarEvent>>(
                'cached_google_events_${email.toLowerCase()}',
              );
        }
      }

      // 3. If memory cache miss, load from DB
      List<CalendarEvent> allEvents = [];
      if (freshGoogleEvents != null) {
        allEvents = List<CalendarEvent>.from(freshGoogleEvents);
      } else {
        final dbEvents = await CalendarEvent.db.find(
          session,
          where: (t) => t.userId.equals(userId) & (t.isDeleted.equals(false)),
          orderBy: (t) => t.startTime,
        );
        allEvents = dbEvents;
      }

      final profileBufferMinutes = userLocProfile?.meetingBufferMinutes ?? 0;
      for (var ev in allEvents) {
        if (homeAddress != null && homeAddress.isNotEmpty) {
          if (ev.startLocation == null || ev.startLocation!.trim().isEmpty) {
            ev.startLocation = homeAddress;
          }
        }
        ev.bufferMinutes ??= profileBufferMinutes;
      }

      // Filter by requested time window
      final filtered = allEvents.where((ev) {
        if (ev.isDeleted == true) return false;
        if (start != null && ev.endTime.isBefore(start)) return false;
        if (end != null && ev.startTime.isAfter(end)) return false;
        return true;
      }).toList();

      filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
      return filtered;
    } catch (e) {
      session.log('Error in getUpcomingEvents: $e', level: LogLevel.error);
      return [];
    }
  }

  Future<bool> updateEvent(Session session, CalendarEvent event) async {
    try {
      final userId = session.authenticated?.authUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // If this is a Google event, attempt to patch on Google Calendar
      if (!event.eventId.startsWith('local_')) {
        try {
          final userProfile = await session.authenticated?.userProfile(session);
          final email = userProfile?.email;
          if (email != null) {
            final accessToken = await session.caches.local.get<String>(
              'google_token_$email',
            );
            if (accessToken != null) {
              final url = Uri.parse(
                'https://www.googleapis.com/calendar/v3/calendars/primary/events/${event.eventId}',
              );
              final body = jsonEncode({
                'summary': event.title,
                if (event.location != null) 'location': event.location,
                'start': {
                  'dateTime': event.startTime.toUtc().toIso8601String(),
                },
                'end': {'dateTime': event.endTime.toUtc().toIso8601String()},
              });
              await http.patch(
                url,
                headers: {
                  'Authorization': 'Bearer $accessToken',
                  'Content-Type': 'application/json',
                },
                body: body,
              );
            }
          }
        } catch (err) {
          session.log(
            'Notice: Could not patch Google Calendar ($err)',
            level: LogLevel.info,
          );
        }
      }

      // Always update local DB
      event.userId = userId;
      final userLocProfile = await UserLocationProfile.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(userId),
      );
      if (event.startLocation == null || event.startLocation!.trim().isEmpty) {
        final homeAddress = userLocProfile?.homeAddress.trim();
        if (homeAddress != null && homeAddress.isNotEmpty) {
          event.startLocation = homeAddress;
        }
      }
      event.bufferMinutes ??= userLocProfile?.meetingBufferMinutes ?? 0;
      final existingEvent = await CalendarEvent.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(event.eventId) & t.userId.equals(userId),
      );
      if (existingEvent != null) {
        event.id = existingEvent.id;
        await CalendarEvent.db.updateRow(session, event);
      } else {
        await CalendarEvent.db.insertRow(session, event);
      }
      return true;
    } catch (e) {
      session.log(
        'Error updating calendar event on Google: $e',
        level: LogLevel.error,
      );
      return false;
    }
  }

  Future<bool> deleteEvent(Session session, CalendarEvent event) async {
    try {
      final userId = session.authenticated?.authUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      event.userId = userId;
      event.isDeleted = true;

      final existingEvent = await CalendarEvent.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(event.eventId) & t.userId.equals(userId),
      );

      if (existingEvent != null) {
        event.id = existingEvent.id;
        await CalendarEvent.db.updateRow(session, event);
      } else {
        await CalendarEvent.db.insertRow(session, event);
      }
      return true;
    } catch (e) {
      session.log(
        'Error deleting calendar event locally: $e',
        level: LogLevel.error,
      );
      return false;
    }
  }
}
