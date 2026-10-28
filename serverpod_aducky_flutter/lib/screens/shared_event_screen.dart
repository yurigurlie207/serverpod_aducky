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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serverpod_aducky_client/serverpod_aducky_client.dart';

import '../client.dart';
import '../services/maps_launcher_service.dart';
import '../theme/app_theme.dart';
import '../widgets/inline_event_editor.dart';
import '../widgets/pomodoro_digital_timer_widget.dart';
import '../widgets/share_countdown_dialog.dart';
import '../widgets/time_timer_widget.dart';
import 'single_event_screen.dart';

class SharedEventScreen extends StatefulWidget {
  final String shareToken;

  const SharedEventScreen({super.key, required this.shareToken});

  @override
  State<SharedEventScreen> createState() => _SharedEventScreenState();
}

class _SharedEventScreenState extends State<SharedEventScreen> {
  SharedEvent? _event;
  bool _isLoading = true;
  String? _errorMessage;

  late Timer _ticker;
  DateTime _now = DateTime.now();

  final PageController _timerPageController = PageController();
  int _currentTimerStyleIndex = 0;

  // Editing state for anyone with the guest event shared link
  bool _isEditing = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSharedEvent();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _timerPageController.dispose();
    _titleController.dispose();
    _startLocationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _populateEditForm(SharedEvent event) {
    _titleController.text = event.title;
    _startLocationController.text = event.startLocation ?? '';
    _destinationController.text = event.location ?? '';
  }

  Future<void> _loadSharedEvent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final event = await client.share.getSharedEvent(widget.shareToken);
      if (mounted) {
        setState(() {
          _event = event;
          _isLoading = false;
          if (event == null) {
            _errorMessage = 'This countdown link was not found or has expired.';
          } else {
            _populateEditForm(event);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load event: $e';
        });
      }
    }
  }

  void _switchTimerPage(int index) {
    _timerPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  IconData _getTransportIcon(String? mode) {
    switch (mode) {
      case 'transit':
        return Icons.directions_transit;
      case 'walking':
        return Icons.directions_walk;
      case 'bicycling':
        return Icons.directions_bike;
      default:
        return Icons.directions_car;
    }
  }

  void _openShareDialog() {
    if (_event == null) return;
    showDialog(
      context: context,
      builder: (_) => ShareCountdownDialog(
        title: _event!.title,
        startTime: _event!.startTime,
        endTime: _event!.endTime,
        location: _event!.location,
        startLocation: _event!.startLocation,
        transportMode: _event!.transportMode,
        travelMinutes: _event!.travelMinutes,
        bufferMinutes: _event!.bufferMinutes,
        personName: _event!.personName,
        existingToken: _event!.shareToken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppTheme.goldenYellow.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_bottom_rounded,
                color: AppTheme.goldenYellow,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'a Ducky • Live Countdown',
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          if (_event != null) ...[
            IconButton(
              icon: Icon(
                _isEditing ? Icons.visibility_rounded : Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              tooltip: _isEditing
                  ? 'View live countdown'
                  : 'Edit event details',
              onPressed: () {
                setState(() => _isEditing = !_isEditing);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 20,
              ),
              tooltip: 'Share link',
              onPressed: _openShareDialog,
            ),
          ],
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.goldenYellow,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading live countdown...',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _event == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A80).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link_off_rounded,
                  color: Color(0xFFFF8A80),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Countdown Not Found',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'This countdown link is invalid or expired.',
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const SingleEventScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.flash_on_rounded, size: 18),
                label: Text(
                  'Create Your Own Event (Free)',
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.goldenYellow,
                  foregroundColor: AppTheme.deepBrown,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isEditing) {
      return _buildEditForm();
    }

    return _buildEventDetails(_event!);
  }

  Future<void> _saveSharedEvent(
    CalendarEvent savedEvent,
    int? travelMins,
  ) async {
    final title = savedEvent.title.trim();
    if (title.isEmpty) return;

    try {
      final updated = await client.share.updateSharedEvent(
        token: widget.shareToken,
        title: title,
        startTime: savedEvent.startTime.toUtc(),
        endTime: savedEvent.endTime.toUtc(),
        location: savedEvent.location?.trim().isNotEmpty == true
            ? savedEvent.location!.trim()
            : null,
        startLocation: savedEvent.startLocation?.trim().isNotEmpty == true
            ? savedEvent.startLocation!.trim()
            : null,
        transportMode: savedEvent.transportMode ?? 'driving',
        travelMinutes: travelMins ?? _event?.travelMinutes ?? 0,
        bufferMinutes: savedEvent.bufferMinutes ?? 0,
        personName: _event?.personName,
      );

      if (mounted) {
        if (updated != null) {
          setState(() {
            _event = updated;
            _populateEditForm(updated);
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 5),
              content: Text('Event updated successfully!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 5),
              content: Text('Failed to update event.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text('Error saving event: $e'),
          ),
        );
      }
    }
  }

  Widget _buildEditForm() {
    return Center(
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
                event: CalendarEvent(
                  eventId: _event!.shareToken,
                  title: _event!.title,
                  startTime: _event!.startTime,
                  endTime: _event!.endTime,
                  location: _event!.location,
                  startLocation: _event!.startLocation,
                  transportMode: _event!.transportMode ?? 'driving',
                  bufferMinutes: _event!.bufferMinutes ?? 0,
                ),
                initialTravelMinutes: _event!.travelMinutes,
                showPersonSelector: false,
                allowEditEndTime: true,
                allowAdjustTravelTime: true,
                onSaveWithTravel: (savedEvent, travelMins) async {
                  await _saveSharedEvent(savedEvent, travelMins);
                },
                onSave: (_) {},
                onCancel: () {
                  setState(() => _isEditing = false);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetails(SharedEvent event) {
    final nowUtc = _now.toUtc();
    final startUtc = event.startTime.toUtc();
    final endUtc = event.endTime.toUtc();

    final isOngoing = !startUtc.isAfter(nowUtc) && endUtc.isAfter(nowUtc);
    final isPast = endUtc.isBefore(nowUtc);

    final travelMins = event.travelMinutes ?? 0;
    final bufferMins = event.bufferMinutes ?? 0;
    final leaveByTimeUtc = event.leaveByTime.toUtc();

    final Duration durationRemaining = isOngoing
        ? endUtc.difference(nowUtc)
        : leaveByTimeUtc.difference(nowUtc);
    final bool isLate = !isOngoing && durationRemaining.isNegative;

    String countdownBadge;
    if (isOngoing) {
      countdownBadge = 'In progress';
    } else if (isLate) {
      final lateMins = durationRemaining.abs().inMinutes;
      countdownBadge = lateMins > 0 ? '$lateMins min late' : 'Time to leave!';
    } else {
      final mins = durationRemaining.inMinutes;
      if (mins >= 60) {
        final hrs = mins ~/ 60;
        final remMins = mins % 60;
        countdownBadge = remMins > 0 ? 'in ${hrs}h ${remMins}m' : 'in ${hrs}h';
      } else if (mins > 0) {
        countdownBadge = 'in ${mins}m';
      } else {
        countdownBadge = 'in <1m';
      }
    }

    final hasLocations =
        event.startLocation?.trim().isNotEmpty == true &&
        event.location?.trim().isNotEmpty == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final blockWidth = (constraints.maxWidth * 0.92).clamp(280.0, 480.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Dual-Timer Dial Box
              Center(
                child: SizedBox(
                  width: blockWidth,
                  height: blockWidth,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: PageView(
                        controller: _timerPageController,
                        physics: const ClampingScrollPhysics(),
                        onPageChanged: (index) {
                          if (_currentTimerStyleIndex != index) {
                            setState(() => _currentTimerStyleIndex = index);
                          }
                        },
                        children: [
                          // Analog Time Timer Dial
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TimeTimerWidget(
                              remaining: isLate
                                  ? Duration.zero
                                  : durationRemaining,
                              activeColor: isLate
                                  ? const Color(0xFFFF8A80)
                                  : AppTheme.darkTeal,
                              innerCircleColor: const Color(0xFF90CDF4),
                              backgroundColor: Colors.transparent,
                              borderColor: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),

                          // Pomodoro Digital Ring Timer
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PomodoroDigitalTimerWidget(
                              remaining: durationRemaining,
                              total: const Duration(minutes: 60),
                              isLate: isLate,
                              isOngoing: isOngoing,
                              textColor: Colors.white,
                              progressColor: isLate
                                  ? const Color(0xFFFF8A80)
                                  : AppTheme.darkTeal,
                              trackColor: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Timer Carousel Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0, 1].map((idx) {
                  final isSelected = _currentTimerStyleIndex == idx;
                  return GestureDetector(
                    onTap: () => _switchTimerPage(idx),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isSelected ? 22 : 7,
                        height: 7,
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

              // 2. Current Event Details Card (Clickable to Edit)
              Center(
                child: SizedBox(
                  width: blockWidth,
                  child: Card(
                    elevation: 0,
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _isEditing = true),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header with Title & Edit Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 28),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        event.title,
                                        style: GoogleFonts.fredoka(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (event.personName != null &&
                                          event.personName!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          event.personName!,
                                          style: GoogleFonts.fredoka(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFFFFD54F),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Tooltip(
                                  message: 'Edit Event Details',
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () =>
                                        setState(() => _isEditing = true),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        size: 19,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Start Time / Status
                            Text(
                              isPast
                                  ? 'Event ended'
                                  : (isOngoing
                                        ? 'In progress (Ends ${DateFormat('h:mm a').format(event.endTime.toLocal()).toLowerCase()})'
                                        : 'Starts ${DateFormat('h:mm a').format(event.startTime.toLocal()).toLowerCase()}'),
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            // Leave by Display
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isLate
                                      ? const Color(
                                          0xFFFF8A80,
                                        ).withValues(alpha: 0.25)
                                      : AppTheme.goldenYellow.withValues(
                                          alpha: 0.22,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isLate
                                        ? const Color(
                                            0xFFFF8A80,
                                          ).withValues(alpha: 0.6)
                                        : AppTheme.goldenYellow.withValues(
                                            alpha: 0.6,
                                          ),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.departure_board_rounded,
                                      size: 16,
                                      color: isLate
                                          ? const Color(0xFFFF8A80)
                                          : AppTheme.goldenYellow,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Leave by: ${DateFormat('h:mm a').format(leaveByTimeUtc.toLocal()).toLowerCase()} ($countdownBadge)',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isLate
                                            ? const Color(0xFFFF8A80)
                                            : AppTheme.goldenYellow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Commute & Transport row
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Google Maps Directions Button
                                Tooltip(
                                  message: hasLocations
                                      ? 'Get Directions on Google Maps'
                                      : 'Locations not provided',
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: hasLocations
                                        ? () async {
                                            await MapsLauncherService.openGoogleMapsDirections(
                                              origin: event.startLocation!,
                                              destination: event.location!,
                                              transportMode:
                                                  event.transportMode ??
                                                  'driving',
                                            );
                                          }
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: hasLocations
                                            ? Colors.white.withValues(
                                                alpha: 0.28,
                                              )
                                            : Colors.white.withValues(
                                                alpha: 0.15,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: hasLocations
                                            ? Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.45,
                                                ),
                                                width: 1.2,
                                              )
                                            : null,
                                      ),
                                      child: Icon(
                                        _getTransportIcon(event.transportMode),
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                // Commute and buffer text
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$travelMins mins commute',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (bufferMins > 0) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '(+$bufferMins min buffer)',
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

                            if (event.location != null &&
                                event.location!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 15,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      event.location!,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 13,
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons for Public Visitors
              Center(
                child: SizedBox(
                  width: blockWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(
                          'Edit This Event',
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _openShareDialog,
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          'Share Live Countdown Link',
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const SingleEventScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.flash_on_rounded, size: 18),
                        label: Text(
                          'Use a Ducky for Your Own Event (Free)',
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.goldenYellow,
                          foregroundColor: AppTheme.deepBrown,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
