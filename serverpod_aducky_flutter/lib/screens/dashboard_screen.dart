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

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_aducky_client/serverpod_aducky_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../services/calendar_service.dart';
import '../services/location_service.dart';
import '../services/claude_service.dart';
import '../client.dart';
import 'profile_screen.dart';
import 'about_screen.dart';
import '../widgets/time_timer_widget.dart';
import '../widgets/pomodoro_digital_timer_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/inline_event_editor.dart';
import '../theme/app_theme.dart';
import '../services/profile_preferences.dart';
import '../services/sms_notification_service.dart';
import '../services/maps_launcher_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CalendarService _calendarService = CalendarService();
  final LocationService _locationService = LocationService();
  final ClaudeService _claudeService = ClaudeService();

  List<CalendarEvent> _events = [];
  bool _isLoading = false;
  String _transportMode = 'driving';
  String? _homeAddress;
  String _accountUserName = '';
  Timer? _timer;
  DateTime _now = DateTime.now();
  bool _showCurrentEventOnly = true;

  // Visual Timer Carousel Selection (0: Analog Time Timer, 1: Digital Pomodoro)
  int _currentTimerStyleIndex = 0;
  late final PageController _timerPageController;

  // Inline Accordion Editing State
  String? _editingEventId;
  bool _isAddingEvent = false;
  // Track sent countdown departure alerts (30m, 20m, 10m)
  final Set<String> _sentDepartureAlertKeys = {};

  // Travel & meeting buffer data for the next event
  int? _travelMinutes;
  int _meetingBufferMinutes = 0;
  bool _isCalculatingTravel = false;

  // Claude AI Schedule Assistant State
  final TextEditingController _aiPromptController = TextEditingController();
  bool _isAiProcessing = false;
  AiScheduleResponse? _lastAiResponse;
  List<CalendarEvent>? _previousEventsBeforeAi;
  List<CalendarEvent> _aiCreatedEvents = [];

  bool _isAllDay(CalendarEvent e) {
    final dur = e.endTime.difference(e.startTime);
    return dur.inHours >= 23;
  }

  CalendarEvent? _getNextEvent() {
    if (_events.isEmpty) return null;
    final nowUtc = _now.toUtc();

    // 1. Look for timed (non-all-day) events first
    // a. Active ongoing timed event
    for (final e in _events) {
      if (_isAllDay(e)) continue;
      final startUtc = e.startTime.toUtc();
      final endUtc = e.endTime.toUtc();
      if (!startUtc.isAfter(nowUtc) && endUtc.isAfter(nowUtc)) {
        return e;
      }
    }
    // b. Next upcoming timed event in chronological order
    for (final e in _events) {
      if (_isAllDay(e)) continue;
      final startUtc = e.startTime.toUtc();
      if (startUtc.isAfter(nowUtc)) {
        return e;
      }
    }

    // 2. Fallback to all-day events if no upcoming/ongoing timed events remain today
    for (final e in _events) {
      final startUtc = e.startTime.toUtc();
      final endUtc = e.endTime.toUtc();
      if (!startUtc.isAfter(nowUtc) && endUtc.isAfter(nowUtc)) {
        return e;
      }
    }
    for (final e in _events) {
      final startUtc = e.startTime.toUtc();
      if (startUtc.isAfter(nowUtc)) {
        return e;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _timerPageController = PageController(initialPage: _currentTimerStyleIndex);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
        _checkDepartureSmsAlerts();
      }
    });
    _loadEvents();
    _loadAccountUserName();
  }

  Future<void> _loadAccountUserName() async {
    final name = await ProfilePreferences.getUserName();
    if (mounted) {
      setState(() {
        _accountUserName = (name != null && name.trim().isNotEmpty)
            ? name.trim()
            : '';
      });
    }
  }

  String _getPersonForEvent(CalendarEvent event) {
    final customPerson = ProfilePreferences.getCachedEventPerson(event.eventId);
    if (customPerson != null && customPerson.trim().isNotEmpty) {
      return customPerson.trim();
    }
    if (_accountUserName.trim().isNotEmpty) {
      return _accountUserName.trim();
    }
    return '';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerPageController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  void _switchTimerPage(int targetIndex) {
    if (targetIndex < 0 || targetIndex > 1) return;
    setState(() {
      _currentTimerStyleIndex = targetIndex;
    });
    if (_timerPageController.hasClients) {
      _timerPageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      // Load user profile to cache home address & meeting buffer
      try {
        final profile = await client.profile.getProfile();
        if (profile != null) {
          _homeAddress = profile.homeAddress.trim();
          _meetingBufferMinutes = profile.meetingBufferMinutes ?? 0;
        }
      } catch (_) {}

      // Fetch real events from Google Calendar & local DB
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final events = await _calendarService.getUpcomingEvents(
        start: startOfDay,
        end: endOfDay,
      );
      await ProfilePreferences.loadEventPersons(
        events.map((e) => e.eventId).toList(),
      );
      await _loadAccountUserName();
      if (mounted) {
        setState(() {
          _events = events;
          _events.sort((a, b) => a.startTime.compareTo(b.startTime));
          _editingEventId = null;
          _isAddingEvent = false;
          if (_homeAddress != null && _homeAddress!.isNotEmpty) {
            for (var ev in _events) {
              if (ev.startLocation == null ||
                  ev.startLocation!.trim().isEmpty) {
                ev.startLocation = _homeAddress;
              }
            }
          }
          for (var ev in _events) {
            ev.bufferMinutes ??= _meetingBufferMinutes;
          }
        });

        final nextEvent = _getNextEvent();
        if (nextEvent != null) {
          if (nextEvent.transportMode != null &&
              nextEvent.transportMode!.isNotEmpty) {
            _transportMode = nextEvent.transportMode!;
          }
          await _calculateTravelForNextEvent(nextEvent);
        } else {
          setState(() {
            _travelMinutes = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _calculateTravelForNextEvent(CalendarEvent event) async {
    if (event.location == null || event.location!.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _travelMinutes = 0;
          _isCalculatingTravel = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isCalculatingTravel = true);
    }

    try {
      // Determine Origin:
      // 1. Try starting location specified on event
      String origin = '';
      if (event.startLocation != null &&
          event.startLocation!.trim().isNotEmpty) {
        origin = event.startLocation!.trim();
      } else {
        // 2. Try to get Home Address from Profile
        if (_homeAddress != null && _homeAddress!.isNotEmpty) {
          origin = _homeAddress!;
        } else {
          final profile = await client.profile.getProfile();
          if (profile != null && profile.homeAddress.isNotEmpty) {
            _homeAddress = profile.homeAddress;
            origin = profile.homeAddress;
          }
        }
      }

      // 3. Fallback to Current Location if home is not set
      if (origin.isEmpty) {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          origin = '${position.latitude},${position.longitude}';
        }
      }

      if (origin.isEmpty) {
        debugPrint('No origin available');
        if (mounted) {
          setState(() {
            _travelMinutes ??= 0;
          });
        }
        return;
      }

      final modeToUse = event.transportMode ?? _transportMode;

      // Call Backend to keep API keys secure
      final result = await client.travel.getTravelTime(
        origin: origin,
        destination: event.location!,
        mode: modeToUse,
      );

      if (mounted) {
        setState(() {
          _travelMinutes = result.durationMinutes;
        });
      }
    } catch (e) {
      debugPrint('Error calculating travel: $e');
      if (mounted) {
        setState(() {
          _travelMinutes ??= 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCalculatingTravel = false);
      }
    }
  }

  IconData _getTransportIcon(String? mode) {
    switch (mode?.toLowerCase()) {
      case 'transit':
        return Icons.directions_transit;
      case 'walking':
        return Icons.directions_walk;
      case 'bicycling':
        return Icons.directions_bike;
      case 'driving':
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildCurrentEventCard(
    CalendarEvent event, {
    required int travelMins,
    required bool isLate,
    required String effectiveTransportMode,
    required ColorScheme colorScheme,
    required bool isDark,
    required DateTime leaveByTimeUtc,
  }) {
    final eventStart = event.startLocation?.trim() ?? '';
    final origin = eventStart.isNotEmpty
        ? eventStart
        : (_homeAddress?.trim() ?? '');
    final destination = event.location?.trim() ?? '';
    final hasStartAndEnd = origin.isNotEmpty && destination.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: Tooltip(
        message: 'Edit',
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: isLate
              ? const Color(0xFFD32F2F).withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isLate
                  ? const Color(0xFFFF8A80).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.28),
              width: 1.2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openEventEditor(event: event),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 22.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Builder(
                    builder: (context) {
                      final personName = _getPersonForEvent(event);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text.rich(
                          TextSpan(
                            text: event.title,
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            children: [
                              if (personName.isNotEmpty)
                                TextSpan(
                                  text: '  $personName',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFFFD54F),
                                  ),
                                ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 6),
                  Text(
                    _isAllDay(event)
                        ? 'All day'
                        : DateFormat(
                            'h:mm a',
                          ).format(event.startTime.toLocal()).toLowerCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Commute Info: Only Car/Transport Icon and Commute Duration when not in edit mode
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Car / Transport Icon (Clickable: Opens Google Maps if start and destination exist)
                      Tooltip(
                        message: hasStartAndEnd
                            ? 'Open in Google Maps'
                            : 'Set start & destination to open in Google Maps',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              if (hasStartAndEnd) {
                                final launched =
                                    await MapsLauncherService.openGoogleMapsDirections(
                                      origin: origin,
                                      destination: destination,
                                      transportMode: effectiveTransportMode,
                                    );
                                if (!launched && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 5),
                                      content: Text(
                                        'Could not open Google Maps.',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 5),
                                    content: Text(
                                      'Add a start and end location to get Google Maps directions.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: hasStartAndEnd
                                    ? Colors.white.withValues(alpha: 0.28)
                                    : Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: hasStartAndEnd
                                    ? Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.45,
                                        ),
                                        width: 1.2,
                                      )
                                    : null,
                              ),
                              child: Icon(
                                _getTransportIcon(effectiveTransportMode),
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Travel Time & Buffer info
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isCalculatingTravel) ...[
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            '$travelMins mins commute',
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if ((event.bufferMinutes ?? _meetingBufferMinutes) >
                              0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(+${event.bufferMinutes ?? _meetingBufferMinutes} min buffer)',
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentEventView() {
    final nextEvent = _getNextEvent();
    if (nextEvent == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'All clear for today',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No upcoming events on your schedule.',
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final nowUtc = _now.toUtc();
    final startUtc = nextEvent.startTime.toUtc();
    final endUtc = nextEvent.endTime.toUtc();
    final isAllDay = _isAllDay(nextEvent);
    final isOngoing =
        !isAllDay && !startUtc.isAfter(nowUtc) && endUtc.isAfter(nowUtc);

    final travelMins = _travelMinutes ?? 0;
    final bufferMins = nextEvent.bufferMinutes ?? _meetingBufferMinutes;
    final totalBufferMinutes = travelMins + bufferMins;
    final leaveByTimeUtc = startUtc.subtract(
      Duration(minutes: totalBufferMinutes),
    );

    // Duration remaining until departure (or until event ends if ongoing)
    final Duration durationRemaining = isOngoing
        ? endUtc.difference(nowUtc)
        : leaveByTimeUtc.difference(nowUtc);
    final bool isLate = !isOngoing && durationRemaining.isNegative;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTransportMode = nextEvent.transportMode ?? _transportMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final blockWidth = (constraints.maxWidth * 0.92).clamp(280.0, 480.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Visual Timer Box matching exact blockWidth of the event card below
                Center(
                  child: SizedBox(
                    width: blockWidth,
                    height: blockWidth,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(44),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.28,
                          ),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: PageView(
                          key: const PageStorageKey(
                            'timer_carousel_page_view',
                          ),
                          controller: _timerPageController,
                          physics: const ClampingScrollPhysics(),
                          onPageChanged: (index) {
                            if (_currentTimerStyleIndex != index) {
                              setState(() {
                                _currentTimerStyleIndex = index;
                              });
                            }
                          },
                          children: [
                            // Style 0: Classic Analog Time Timer (transparent dial background, darker teal)
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: TimeTimerWidget(
                                remaining: isLate
                                    ? Duration.zero
                                    : durationRemaining,
                                activeColor: isLate
                                    ? colorScheme.error
                                    : AppTheme.darkTeal, // Darker teal in theme
                                innerCircleColor: const Color(0xFF90CDF4),
                                backgroundColor: Colors.transparent,
                                borderColor: Colors.white.withValues(
                                  alpha: 0.90,
                                ),
                              ),
                            ),

                            // Style 1: Pomodoro Minimalist Digital Ring Timer (darker teal)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PomodoroDigitalTimerWidget(
                                remaining: durationRemaining,
                                total: const Duration(
                                  minutes: 60,
                                ),
                                isLate: isLate,
                                isOngoing: isOngoing,
                                textColor: Colors.white,
                                progressColor: isLate
                                    ? colorScheme.error
                                    : AppTheme.darkTeal, // Darker teal in theme
                                trackColor: Colors.white.withValues(
                                  alpha: 0.22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Carousel Options / Dots Indicator allowing user to navigate between timers
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [0, 1].map((idx) {
                    final isSelected = _currentTimerStyleIndex == idx;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _switchTimerPage(idx),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 10,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: isSelected ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // 2. Event card below the timer with matching blockWidth
                Center(
                  child: SizedBox(
                    width: blockWidth,
                    child: _buildCurrentEventCard(
                      nextEvent,
                      travelMins: travelMins,
                      isLate: isLate,
                      effectiveTransportMode: effectiveTransportMode,
                      colorScheme: colorScheme,
                      isDark: isDark,
                      leaveByTimeUtc: leaveByTimeUtc,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(CalendarEvent event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to remove this event from your app?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _events.removeWhere((e) => e.eventId == event.eventId);
        if (_editingEventId == event.eventId) {
          _editingEventId = null;
        }
      });
      try {
        await _calendarService.deleteEvent(event);
      } catch (e) {
        debugPrint('Error deleting event on server: $e');
      }
      final nextEvent = _getNextEvent();
      if (nextEvent != null) {
        await _calculateTravelForNextEvent(nextEvent);
      }
      return true;
    }
    return false;
  }

  Widget _buildAddEventCard() {
    return Center(
      child: Tooltip(
        message: 'Add new event',
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openEventEditor(event: null),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Event',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAiPrompt([String? explicitPrompt]) async {
    final promptText = (explicitPrompt ?? _aiPromptController.text).trim();
    if (promptText.isEmpty) return;

    setState(() {
      _isAiProcessing = true;
    });

    // Save previous snapshot for undo
    _previousEventsBeforeAi = _events
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
            isDeleted: e.isDeleted,
          ),
        )
        .toList();

    try {
      final response = await _claudeService.editScheduleWithClaude(
        prompt: promptText,
        currentEvents: _events,
      );

      final updatedEvents = response.suggestedEvents
          .where((e) => !e.isDeleted)
          .toList();
      updatedEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
      if (_homeAddress != null && _homeAddress!.isNotEmpty) {
        for (var ev in updatedEvents) {
          if (ev.startLocation == null || ev.startLocation!.trim().isEmpty) {
            ev.startLocation = _homeAddress;
          }
        }
      }

      setState(() {
        _events = updatedEvents;
        _lastAiResponse = response;
        _isAiProcessing = false;
        _aiPromptController.clear();
      });

      // Synchronize changes to server / Google Calendar
      for (final event in response.suggestedEvents) {
        if (event.isDeleted) {
          _calendarService.deleteEvent(event).catchError((_) => false);
        } else {
          _calendarService.updateEvent(event).catchError((_) => false);
        }
      }

      final nextEvent = _getNextEvent();
      if (nextEvent != null) {
        _calculateTravelForNextEvent(nextEvent);
      }
    } catch (e) {
      setState(() {
        _isAiProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(
              'Claude Error: $e',
              style: GoogleFonts.fredoka(),
            ),
            backgroundColor: AppTheme.burntOrange,
          ),
        );
      }
    }
  }

  void _undoAiChanges() {
    _undoAiSmartTransform();
  }

  void _undoAiSmartTransform() {
    if (_previousEventsBeforeAi == null) return;
    final reverted = List<CalendarEvent>.from(_previousEventsBeforeAi!);
    final created = List<CalendarEvent>.from(_aiCreatedEvents);
    setState(() {
      _events = reverted;
      _previousEventsBeforeAi = null;
      _aiCreatedEvents.clear();
      _lastAiResponse = null;
    });
    for (final event in reverted) {
      _calendarService.updateEvent(event).catchError((_) => false);
    }
    for (final event in created) {
      _calendarService.deleteEvent(event).catchError((_) => false);
    }
    final nextEvent = _getNextEvent();
    if (nextEvent != null) {
      _calculateTravelForNextEvent(nextEvent);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: Text(
            'Reverted AI Assist changes.',
            style: GoogleFonts.fredoka(),
          ),
          backgroundColor: AppTheme.darkTeal,
        ),
      );
    }
  }

  Widget _buildAllEventsView() {
    final nextEvent = _getNextEvent();
    final validEvents = _events.where((e) => !e.isDeleted).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Find if and where passed events end
    int firstUpcomingIndex = -1;
    for (int i = 0; i < validEvents.length; i++) {
      final localEnd = validEvents[i].endTime.toLocal();
      if (!localEnd.isBefore(_now)) {
        firstUpcomingIndex = i;
        break;
      }
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_previousEventsBeforeAi != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.goldenYellow.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppTheme.goldenYellow,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI Assist changes applied',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _undoAiSmartTransform,
                        icon: const Icon(Icons.undo_rounded, size: 14),
                        label: Text(
                          'Undo',
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.goldenYellow,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (validEvents.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      'No events scheduled for today.',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.70),
                      ),
                    ),
                  ),
                )
              else ...[
                for (int i = 0; i < validEvents.length; i++) ...[
                  _buildSequentialEventCard(
                    event: validEvents[i],
                    isNext: validEvents[i].eventId == nextEvent?.eventId,
                  ),
                  if (firstUpcomingIndex != -1 && i == firstUpcomingIndex - 1)
                    _buildPassedTimeIndicatorLine(),
                ],
                if (firstUpcomingIndex == -1 && validEvents.isNotEmpty)
                  _buildPassedTimeIndicatorLine(),
                const SizedBox(height: 8),
              ],
              // Add Event Card under events
              _buildAddEventCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassedTimeIndicatorLine() {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 4,
            right: 0,
            child: Container(
              height: 1.0,
              color: AppTheme.goldenYellow,
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.goldenYellow,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequentialEventCard({
    required CalendarEvent event,
    required bool isNext,
  }) {
    final title = event.title;
    final localStart = event.startTime.toLocal();
    final localEnd = event.endTime.toLocal();
    final duration = localEnd.difference(localStart);
    final totalMinutes = duration.inMinutes;
    final int hours = totalMinutes ~/ 60;
    final int mins = totalMinutes % 60;
    final String durationStr;
    if (duration.inHours >= 24) {
      durationStr = 'All day';
    } else if (hours == 0) {
      durationStr = '${mins}m';
    } else if (mins == 0) {
      durationStr = '${hours}h';
    } else {
      durationStr = '${hours}h ${mins}m';
    }
    final isPast = localEnd.isBefore(_now);
    final effectiveIsNext = isNext && !isPast;
    final startTimeStr = DateFormat('h:mm a').format(localStart).toLowerCase();
    final seqEventStart = event.startLocation?.trim() ?? '';
    final seqOrigin = seqEventStart.isNotEmpty
        ? seqEventStart
        : (_homeAddress?.trim() ?? '');
    final seqDestination = event.location?.trim() ?? '';
    final seqHasRoute = seqOrigin.isNotEmpty && seqDestination.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: isPast
                ? Colors.white.withValues(alpha: 0.10)
                : effectiveIsNext
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isPast
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openEventEditor(event: event),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Event details: Title on top, Start time + Duration + Transport under title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Builder(
                            builder: (context) {
                              final seqPersonName = _getPersonForEvent(event);
                              return Text.rich(
                                TextSpan(
                                  text: title,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    fontWeight: effectiveIsNext
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    decoration: isPast
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: isPast
                                        ? AppTheme.goldenYellow
                                        : null,
                                    decorationThickness: isPast ? 2.0 : null,
                                    color: isPast
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : Colors.white,
                                  ),
                                  children: [
                                    if (seqPersonName.isNotEmpty)
                                      TextSpan(
                                        text: '  $seqPersonName',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: isPast
                                              ? Colors.white.withValues(
                                                  alpha: 0.30,
                                                )
                                              : (effectiveIsNext
                                                    ? const Color(
                                                        0xFFFFD54F,
                                                      ).withValues(alpha: 0.90)
                                                    : Colors.white.withValues(
                                                        alpha: 0.70,
                                                      )),
                                        ),
                                      ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),

                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Start Time
                              Text(
                                startTimeStr,
                                style: GoogleFonts.fredoka(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isPast
                                      ? Colors.white.withValues(alpha: 0.40)
                                      : Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              Container(
                                width: 3,
                                height: 3,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(
                                    alpha: isPast ? 0.25 : 0.45,
                                  ),
                                ),
                              ),
                              // Duration Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: isPast ? 0.08 : 0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: isPast ? 0.12 : 0.22,
                                    ),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  durationStr,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isPast
                                        ? Colors.white.withValues(alpha: 0.40)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final seqBuffer =
                                      event.bufferMinutes ??
                                      _meetingBufferMinutes;
                                  if (seqBuffer <= 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 3,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(
                                            alpha: isPast ? 0.25 : 0.45,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD54F)
                                              .withValues(
                                                alpha: isPast ? 0.08 : 0.16,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFFFD54F)
                                                .withValues(
                                                  alpha: isPast ? 0.14 : 0.30,
                                                ),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          '+${seqBuffer}m buffer',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isPast
                                                ? Colors.white.withValues(
                                                    alpha: 0.40,
                                                  )
                                                : const Color(0xFFFFD54F),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              Container(
                                width: 3,
                                height: 3,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(
                                    alpha: isPast ? 0.25 : 0.45,
                                  ),
                                ),
                              ),
                              // Transport Icon (Clickable: Opens Google Maps if start and destination exist)
                              Tooltip(
                                message: seqHasRoute
                                    ? 'Open in Google Maps'
                                    : 'Set start & destination to open in Google Maps',
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () async {
                                      if (seqHasRoute) {
                                        final launched =
                                            await MapsLauncherService.openGoogleMapsDirections(
                                              origin: seqOrigin,
                                              destination: seqDestination,
                                              transportMode:
                                                  event.transportMode,
                                            );
                                        if (!launched && mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 5),
                                              content: Text(
                                                'Could not open Google Maps.',
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            duration: Duration(seconds: 5),
                                            content: Text(
                                              'Add a start and end location to get Google Maps directions.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: isPast
                                              ? 0.10
                                              : (seqHasRoute ? 0.28 : 0.18),
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: seqHasRoute
                                            ? Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: isPast ? 0.20 : 0.40,
                                                ),
                                                width: 0.8,
                                              )
                                            : null,
                                      ),
                                      child: Icon(
                                        _getTransportIcon(event.transportMode),
                                        size: 13,
                                        color: isPast
                                            ? Colors.white.withValues(
                                                alpha: 0.40,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.90,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Delete button on the right
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(event),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // a Ducky Logo catching the top right corner symmetrically (offset 3px top and right)
          Positioned(
            top: -9,
            right: -9,
            child: IgnorePointer(
              child: Opacity(
                opacity: isPast ? 0.45 : 1.0,
                child: Image.asset(
                  'assets/images/ducky_logo.png',
                  height: 28,
                  width: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEventEditor({CalendarEvent? event}) {
    setState(() {
      _editingEventId = event?.eventId;
      _isAddingEvent = (event == null);
    });
  }

  void _closeEventEditor() {
    setState(() {
      _editingEventId = null;
      _isAddingEvent = false;
    });
  }

  Widget _buildEditorContent(CalendarEvent? event, {Key? key}) {
    final isCurrentEventPage = _showCurrentEventOnly;
    return Center(
      key: key,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Colors.white.withValues(alpha: 0.16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: InlineEventEditor(
                event: event,
                defaultStartLocation: _homeAddress,
                defaultBufferMinutes: _meetingBufferMinutes,
                allowEditEndTime: !isCurrentEventPage,
                onSave: (savedEvent) async {
                  _closeEventEditor();
                  if (event == null) {
                    setState(() {
                      _events.add(savedEvent);
                      _events.sort(
                        (a, b) => a.startTime.compareTo(b.startTime),
                      );
                    });
                    try {
                      await _calendarService.updateEvent(savedEvent);
                    } catch (e) {
                      debugPrint('Error saving new event to server: $e');
                    }
                  } else {
                    final idx = _events.indexWhere(
                      (e) => e.eventId == savedEvent.eventId,
                    );
                    if (idx != -1) {
                      setState(() {
                        _events[idx] = savedEvent;
                        _events.sort(
                          (a, b) => a.startTime.compareTo(b.startTime),
                        );
                      });
                      try {
                        await _calendarService.updateEvent(savedEvent);
                      } catch (e) {
                        debugPrint('Error updating event on server: $e');
                      }
                    }
                  }
                  final next = _getNextEvent();
                  if (next != null) {
                    if (next.eventId == savedEvent.eventId) {
                      setState(() {
                        _transportMode =
                            savedEvent.transportMode ?? _transportMode;
                      });
                    }
                    await _calculateTravelForNextEvent(next);
                  }
                },
                onCancel: _closeEventEditor,
                onDelete: (isCurrentEventPage || event == null)
                    ? null
                    : () async {
                        final deleted = await _confirmDelete(event);
                        if (deleted && mounted) {
                          _closeEventEditor();
                        }
                      },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await client.auth.signOutDevice();
    }
  }

  @override
  Widget build(BuildContext context) {
    CalendarEvent? editingEvent;
    if (_editingEventId != null) {
      for (final e in _events) {
        if (e.eventId == _editingEventId) {
          editingEvent = e;
          break;
        }
      }
    }
    final isEditingFormOpen = _editingEventId != null || _isAddingEvent;

    return PopScope(
      canPop: !isEditingFormOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isEditingFormOpen) {
          _closeEventEditor();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Tooltip(
            message: 'About a Ducky',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/ducky_logo.png',
                      height: 38,
                      width: 38,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'a Ducky',
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person_outline,
                size: 22,
                color: Colors.white,
              ),
              tooltip: 'Profile',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      onProfileUpdated: () {
                        _loadEvents();
                      },
                    ),
                  ),
                );
                await _loadAccountUserName();
                await _loadEvents();
              },
            ),
            Center(
              child: Text(
                DateFormat('h:mm a').format(_now).toLowerCase(),
                style: GoogleFonts.fredoka(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 18, color: Colors.white),
              tooltip: 'Sign Out',
              onPressed: _signOut,
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: (_events.isEmpty && _isLoading)
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
                    child: Text(
                      DateFormat('EEEE, MMMM d').format(_now),
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: _buildPillToggle(),
                          ),
                          if (!_showCurrentEventOnly && !isEditingFormOpen)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_previousEventsBeforeAi != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.undo_rounded,
                                        size: 20,
                                        color: AppTheme.goldenYellow,
                                      ),
                                      tooltip: 'Undo AI Assist',
                                      onPressed: _undoAiSmartTransform,
                                    ),
                                  GestureDetector(
                                    onLongPress: () =>
                                        _showAiAssistantDialog(context),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.auto_awesome,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      tooltip: 'AI Assistant',
                                      onPressed: _executeAiSmartTransform,
                                    ),
                                  ),
                                  IconButton(
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.refresh,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                    tooltip: 'Refresh Events',
                                    onPressed: _isLoading ? null : _loadEvents,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.05),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                      child: isEditingFormOpen
                          ? _buildEditorContent(
                              editingEvent,
                              key: ValueKey(
                                'editor_${_editingEventId ?? "add"}',
                              ),
                            )
                          : KeyedSubtree(
                              key: ValueKey('view_$_showCurrentEventOnly'),
                              child: _showCurrentEventOnly
                                  ? _buildCurrentEventView()
                                  : _buildAllEventsView(),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPillToggle() {
    const double tabWidth = 72.0;
    const double tabHeight = 34.0;
    const double trackPadding = 3.0;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity;
        if (velocity != null) {
          if (velocity > 0 && _showCurrentEventOnly) {
            // Swiped right -> All
            setState(() {
              _showCurrentEventOnly = false;
              _editingEventId = null;
              _isAddingEvent = false;
            });
          } else if (velocity < 0 && !_showCurrentEventOnly) {
            // Swiped left -> Now
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            setState(() {
              _showCurrentEventOnly = true;
              _editingEventId = null;
              _isAddingEvent = false;
            });
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(trackPadding),
        child: SizedBox(
          width: tabWidth * 2,
          height: tabHeight,
          child: Stack(
            children: [
              // Sliding thumb indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeInOutCubic,
                alignment: _showCurrentEventOnly
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: tabWidth,
                  height: tabHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.40),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Segment labels
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!_showCurrentEventOnly) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            setState(() {
                              _showCurrentEventOnly = true;
                              _editingEventId = null;
                              _isAddingEvent = false;
                            });
                          }
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              fontWeight: _showCurrentEventOnly
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _showCurrentEventOnly
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.70),
                            ),
                            child: const Text('Now'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (_showCurrentEventOnly) {
                            setState(() {
                              _showCurrentEventOnly = false;
                              _editingEventId = null;
                              _isAddingEvent = false;
                            });
                          }
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              fontWeight: !_showCurrentEventOnly
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: !_showCurrentEventOnly
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.70),
                            ),
                            child: const Text('All'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAiAssistantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF0F382E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppTheme.goldenYellow.withValues(
                                alpha: 0.22,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 20,
                              color: AppTheme.goldenYellow,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Claude AI Assistant',
                                  style: GoogleFonts.fredoka(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  'Natural language event editing & rescheduling',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _isAiProcessing
                                  ? AppTheme.burntOrange.withValues(alpha: 0.35)
                                  : const Color(0xFF164F40).withValues(
                                      alpha: 0.8,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isAiProcessing
                                        ? AppTheme.goldenYellow
                                        : const Color(0xFF68D391),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _isAiProcessing
                                      ? 'Thinking...'
                                      : 'Claude 3.5',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.white70,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Type your instructions to edit, shift, or reschedule events:',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.warmLinen,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Input Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _aiPromptController,
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'e.g. "Push afternoon by 30 mins", "Add coffee at 3pm"...',
                                  hintStyle: GoogleFonts.fredoka(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.45),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                enabled: !_isAiProcessing,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (val) async {
                                  await _handleAiPrompt(val);
                                  setDialogState(() {});
                                },
                              ),
                            ),
                            if (_aiPromptController.text.isNotEmpty &&
                                !_isAiProcessing)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                color: Colors.white54,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    _aiPromptController.clear();
                                  });
                                },
                              ),
                            const SizedBox(width: 4),
                            _isAiProcessing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.goldenYellow,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 18,
                                      color: AppTheme.goldenYellow,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.16,
                                      ),
                                      shape: const CircleBorder(),
                                    ),
                                    tooltip: 'Send to Claude',
                                    onPressed: () async {
                                      await _handleAiPrompt(
                                        _aiPromptController.text,
                                      );
                                      setDialogState(() {});
                                    },
                                  ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Quick Suggestion Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildDialogChip(
                              '⏩ Push afternoon 30m',
                              'Push all afternoon events back by 30 minutes',
                              setDialogState,
                            ),
                            const SizedBox(width: 6),
                            _buildDialogChip(
                              '☕ Add 30m coffee at 3pm',
                              'Schedule a 30m coffee break at 3:00pm',
                              setDialogState,
                            ),
                            const SizedBox(width: 6),
                            _buildDialogChip(
                              '🍽️ Add 45m lunch at 12:30pm',
                              'Schedule a 45m lunch break at 12:30pm',
                              setDialogState,
                            ),
                            const SizedBox(width: 6),
                            _buildDialogChip(
                              '🧹 Clear evening events',
                              'Cancel all events after 6pm',
                              setDialogState,
                            ),
                          ],
                        ),
                      ),

                      // Live Claude Feedback Banner
                      if (_lastAiResponse != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF164F40).withValues(
                              alpha: 0.60,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.goldenYellow.withValues(
                                alpha: 0.40,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                    color: AppTheme.goldenYellow,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _lastAiResponse!.summary,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (_previousEventsBeforeAi != null)
                                    TextButton.icon(
                                      onPressed: () {
                                        _undoAiChanges();
                                        setDialogState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.undo_rounded,
                                        size: 14,
                                      ),
                                      label: Text(
                                        'Undo',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.warmLinen,
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (_lastAiResponse!.actionsTaken.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                for (final action
                                    in _lastAiResponse!.actionsTaken)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2.0,
                                      left: 4.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 12,
                                            color: AppTheme.goldenYellow,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            action,
                                            style: GoogleFonts.fredoka(
                                              fontSize: 12,
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Schedule summary & tip
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFFFD54F),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'AI Schedule changes update both your calendar and real-time travel buffer countdowns.',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.80),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dialog Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_showCurrentEventOnly)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showCurrentEventOnly = false;
                                });
                                Navigator.pop(dialogContext);
                              },
                              child: Text(
                                'View in All Events',
                                style: GoogleFonts.fredoka(
                                  color: AppTheme.warmLinen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.forestGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              'Done',
                              style: GoogleFonts.fredoka(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogChip(
    String label,
    String prompt,
    StateSetter setDialogState,
  ) {
    return InkWell(
      onTap: _isAiProcessing
          ? null
          : () async {
              _aiPromptController.text = prompt;
              await _handleAiPrompt(prompt);
              setDialogState(() {});
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }

  void _checkDepartureSmsAlerts() async {
    final nextEvent = _getNextEvent();
    if (nextEvent == null) return;

    final nowUtc = _now.toUtc();
    final startUtc = nextEvent.startTime.toUtc();
    final endUtc = nextEvent.endTime.toUtc();
    final isAllDay = _isAllDay(nextEvent);
    final isOngoing =
        !isAllDay && !startUtc.isAfter(nowUtc) && endUtc.isAfter(nowUtc);

    // Skip departure alerts for all-day or currently ongoing events
    if (isAllDay || isOngoing) return;

    final travelMins = _travelMinutes ?? 0;
    final bufferMins = nextEvent.bufferMinutes ?? _meetingBufferMinutes;
    final totalBufferMins = travelMins + bufferMins;
    final leaveByTimeUtc = startUtc.subtract(
      Duration(minutes: totalBufferMins),
    );

    // Duration remaining until user must leave the house
    final durationRemaining = leaveByTimeUtc.difference(nowUtc);
    final remainingSeconds = durationRemaining.inSeconds;

    if (remainingSeconds <= 0) return; // Leave time has passed

    final eventKey = nextEvent.eventId.isNotEmpty
        ? nextEvent.eventId
        : '${nextEvent.id ?? nextEvent.title}_${startUtc.millisecondsSinceEpoch}';

    // Milestones: 30 minutes, 20 minutes, 10 minutes before departure
    int? milestone;
    if (remainingSeconds <= 30 * 60 && remainingSeconds > 20 * 60) {
      milestone = 30;
    } else if (remainingSeconds <= 20 * 60 && remainingSeconds > 10 * 60) {
      milestone = 20;
    } else if (remainingSeconds <= 10 * 60 && remainingSeconds > 0) {
      milestone = 10;
    }

    if (milestone == null) return;

    final alertKey = '${eventKey}_$milestone';
    if (_sentDepartureAlertKeys.contains(alertKey)) return;

    _sentDepartureAlertKeys.add(alertKey);

    final phone = await ProfilePreferences.getPhoneNumber();
    if (phone != null && phone.trim().isNotEmpty && mounted) {
      SmsNotificationService.sendDepartureNotification(
        context: context,
        phoneNumber: phone.trim(),
        event: nextEvent,
        milestoneMinutes: milestone,
        leaveByTime: leaveByTimeUtc.toLocal(),
        eventStartTime: startUtc.toLocal(),
      );
    }
  }

  Future<void> _executeAiSmartTransform() async {
    setState(() {
      _isLoading = true;
    });

    final originalEvents = List<CalendarEvent>.from(_events);
    final allDayEventsToDelete = <CalendarEvent>[];
    final commuteEventsToSplit = <CalendarEvent>[];
    final unchangedEvents = <CalendarEvent>[];

    for (final event in _events) {
      if (event.isDeleted) continue;

      final duration = event.endTime.difference(event.startTime);
      final titleLower = event.title.toLowerCase();
      final isAllDay =
          duration.inHours >= 24 ||
          _isAllDay(event) ||
          titleLower.contains('all day');

      if (isAllDay) {
        allDayEventsToDelete.add(event);
      } else {
        final hasTransportation =
            event.transportMode != null &&
            event.transportMode!.isNotEmpty &&
            event.transportMode != 'none';
        final hasDistinctTimes = !event.startTime.isAtSameMomentAs(
          event.endTime,
        );

        if (hasTransportation && hasDistinctTimes) {
          commuteEventsToSplit.add(event);
        } else {
          unchangedEvents.add(event);
        }
      }
    }

    if (allDayEventsToDelete.isEmpty && commuteEventsToSplit.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(
              'AI Assist: No "all day" or commute events found to reorganize.',
              style: GoogleFonts.fredoka(),
            ),
            backgroundColor: AppTheme.darkTeal,
          ),
        );
      }
      return;
    }

    final newEventsToAdd = <CalendarEvent>[];
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    int counter = 0;

    for (final event in commuteEventsToSplit) {
      counter++;
      // Drop-off: use start time for both start and end, original location and destination
      final dropOffEvent = CalendarEvent(
        eventId: 'evt_dropoff_${event.eventId}_${nowMs}_$counter',
        title: '${event.title} - Drop-off',
        startTime: event.startTime,
        endTime: event.startTime,
        location: event.location,
        startLocation:
            (event.startLocation != null &&
                event.startLocation!.trim().isNotEmpty)
            ? event.startLocation
            : _homeAddress,
        transportMode: event.transportMode,
        bufferMinutes: event.bufferMinutes ?? _meetingBufferMinutes,
        isDeleted: false,
      );

      counter++;
      // Pick-up: use end time for both start and end, original location and destination
      final pickUpEvent = CalendarEvent(
        eventId: 'evt_pickup_${event.eventId}_${nowMs}_$counter',
        title: '${event.title} - Pick-up',
        startTime: event.endTime,
        endTime: event.endTime,
        location: event.location,
        startLocation:
            (event.startLocation != null &&
                event.startLocation!.trim().isNotEmpty)
            ? event.startLocation
            : _homeAddress,
        transportMode: event.transportMode,
        bufferMinutes: event.bufferMinutes ?? _meetingBufferMinutes,
        isDeleted: false,
      );

      newEventsToAdd.add(dropOffEvent);
      newEventsToAdd.add(pickUpEvent);
    }

    final updatedList = <CalendarEvent>[...unchangedEvents, ...newEventsToAdd];
    updatedList.sort((a, b) => a.startTime.compareTo(b.startTime));

    setState(() {
      _previousEventsBeforeAi = originalEvents;
      _aiCreatedEvents = List<CalendarEvent>.from(newEventsToAdd);
      _events = updatedList;
      _isLoading = false;
    });

    for (final e in allDayEventsToDelete) {
      _calendarService.deleteEvent(e).catchError((_) => false);
    }
    for (final e in commuteEventsToSplit) {
      _calendarService.deleteEvent(e).catchError((_) => false);
    }
    for (final e in newEventsToAdd) {
      _calendarService.updateEvent(e).catchError((_) => false);
    }

    final nextEvent = _getNextEvent();
    if (nextEvent != null) {
      _calculateTravelForNextEvent(nextEvent);
    }

    if (mounted) {
      final delCount = allDayEventsToDelete.length;
      final splitCount = commuteEventsToSplit.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.darkTeal,
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: AppTheme.goldenYellow.withValues(alpha: 0.5),
            ),
          ),
          content: Text(
            'AI Assist: Deleted $delCount all-day event(s), created ${splitCount * 2} drop-off & pick-up events.',
            style: GoogleFonts.fredoka(),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppTheme.goldenYellow,
            onPressed: _undoAiSmartTransform,
          ),
        ),
      );
    }
  }
}
