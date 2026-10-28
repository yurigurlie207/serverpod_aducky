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

class SingleEventScreen extends StatefulWidget {
  const SingleEventScreen({super.key});

  @override
  State<SingleEventScreen> createState() => _SingleEventScreenState();
}

class _SingleEventScreenState extends State<SingleEventScreen> {
  bool _isConfigured = true;
  bool _isEditing = false;

  final TextEditingController _titleController = TextEditingController(
    text: 'My Focus Event',
  );
  final TextEditingController _startLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  DateTime _startTime = DateTime.now().add(const Duration(minutes: 45));
  DateTime _endTime = DateTime.now().add(const Duration(minutes: 105));
  String _transportMode = 'driving';
  int _bufferMinutes = 10;
  int _travelMinutes = 15;

  late Timer _ticker;
  DateTime _now = DateTime.now();

  final PageController _timerPageController = PageController();
  int _currentTimerStyleIndex = 0;

  @override
  void initState() {
    super.initState();
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

  Future<void> _calculateTravel() async {
    final start = _startLocationController.text.trim();
    final dest = _destinationController.text.trim();
    if (start.isEmpty || dest.isEmpty) return;

    try {
      final result = await client.travel.getTravelTime(
        origin: start,
        destination: dest,
        mode: _transportMode,
      );
      if (mounted && result.durationMinutes > 0) {
        setState(() {
          _travelMinutes = result.durationMinutes;
        });
      }
    } catch (_) {}
  }

  void _switchTimerPage(int index) {
    _timerPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  IconData _getTransportIcon(String mode) {
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
    showDialog(
      context: context,
      builder: (_) => ShareCountdownDialog(
        title: _titleController.text.trim().isEmpty
            ? 'Single Focus Event'
            : _titleController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        location: _destinationController.text.trim().isNotEmpty
            ? _destinationController.text.trim()
            : null,
        startLocation: _startLocationController.text.trim().isNotEmpty
            ? _startLocationController.text.trim()
            : null,
        transportMode: _transportMode,
        travelMinutes: _travelMinutes,
        bufferMinutes: _bufferMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back to Sign In',
              )
            : null,
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
                Icons.flash_on_rounded,
                color: AppTheme.goldenYellow,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'a Ducky • Guest Event',
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          if (_isConfigured) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share countdown',
              onPressed: _openShareDialog,
            ),
            IconButton(
              icon: Icon(_isEditing ? Icons.visibility : Icons.edit_outlined),
              tooltip: _isEditing ? 'View timer' : 'Edit event',
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
          ],
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: !_isConfigured || _isEditing
              ? _buildCurrentEventEditor(colorScheme, isDark)
              : _buildLiveCountdown(colorScheme, isDark),
        ),
      ),
    );
  }

  Widget _buildCurrentEventEditor(ColorScheme colorScheme, bool isDark) {
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
                  eventId: 'guest_single_event',
                  title: _titleController.text.trim().isEmpty
                      ? 'My Focus Event'
                      : _titleController.text.trim(),
                  startTime: _startTime,
                  endTime: _endTime,
                  location: _destinationController.text.trim().isNotEmpty
                      ? _destinationController.text.trim()
                      : null,
                  startLocation: _startLocationController.text.trim().isNotEmpty
                      ? _startLocationController.text.trim()
                      : null,
                  transportMode: _transportMode,
                  bufferMinutes: _bufferMinutes,
                ),
                initialTravelMinutes: _travelMinutes,
                showPersonSelector: false,
                allowEditEndTime: true,
                allowAdjustTravelTime: true,
                onSaveWithTravel: (savedEvent, travelMins) {
                  setState(() {
                    _titleController.text = savedEvent.title;
                    _startTime = savedEvent.startTime.toLocal();
                    _endTime = savedEvent.endTime.toLocal();
                    _destinationController.text = savedEvent.location ?? '';
                    _startLocationController.text =
                        savedEvent.startLocation ?? '';
                    _transportMode = savedEvent.transportMode ?? 'driving';
                    _bufferMinutes = savedEvent.bufferMinutes ?? 10;
                    if (travelMins != null) {
                      _travelMinutes = travelMins;
                    }
                    _isEditing = false;
                    _isConfigured = true;
                  });
                  if (travelMins == null) {
                    _calculateTravel();
                  }
                },
                onSave: (_) {},
                onCancel: () {
                  setState(() {
                    _isEditing = false;
                    _isConfigured = true;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveCountdown(ColorScheme colorScheme, bool isDark) {
    final nowUtc = _now.toUtc();
    final startUtc = _startTime.toUtc();
    final endUtc = _endTime.toUtc();

    final isOngoing = !startUtc.isAfter(nowUtc) && endUtc.isAfter(nowUtc);
    final isPast = endUtc.isBefore(nowUtc);

    final totalPadMinutes = _travelMinutes + _bufferMinutes;
    final leaveByTimeUtc = startUtc.subtract(
      Duration(minutes: totalPadMinutes),
    );

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
        _startLocationController.text.trim().isNotEmpty &&
        _destinationController.text.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final blockWidth = (constraints.maxWidth * 0.92).clamp(280.0, 480.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Guest Mode Banner with Share button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flash_on_rounded,
                      color: AppTheme.goldenYellow,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Single Event Mode (No account)',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openShareDialog,
                      icon: const Icon(Icons.share_rounded, size: 14),
                      label: Text(
                        'Share Link',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.goldenYellow,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Visual Timer Box
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
                          // Analog Dial
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TimeTimerWidget(
                              remaining: isPast
                                  ? Duration.zero
                                  : (isLate
                                        ? Duration.zero
                                        : durationRemaining),
                              activeColor: isLate
                                  ? colorScheme.error
                                  : AppTheme.darkTeal,
                              innerCircleColor: const Color(0xFF90CDF4),
                              backgroundColor: Colors.transparent,
                              borderColor: isDark
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : AppTheme.darkTeal.withValues(alpha: 0.7),
                            ),
                          ),

                          // Digital Ring Timer
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PomodoroDigitalTimerWidget(
                              remaining: durationRemaining,
                              total: const Duration(minutes: 60),
                              isLate: isLate,
                              isOngoing: isOngoing,
                              textColor: isDark
                                  ? Colors.white
                                  : AppTheme.darkTeal,
                              progressColor: isLate
                                  ? colorScheme.error
                                  : AppTheme.darkTeal,
                              trackColor: isDark
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : AppTheme.darkTeal.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Carousel Dots Indicator
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
                              ? AppTheme.goldenYellow
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : colorScheme.outline.withValues(
                                        alpha: 0.35,
                                      )),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Event Card
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
                            // Event Title
                            Text(
                              _titleController.text.trim().isEmpty
                                  ? 'Focus Event'
                                  : _titleController.text.trim(),
                              style: GoogleFonts.fredoka(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 6),

                            // Start Time
                            Text(
                              'Starts ${DateFormat('h:mm a').format(_startTime).toLowerCase()}',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.85,
                                ),
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

                            // Commute row
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Tooltip(
                                  message: hasLocations
                                      ? 'Get Directions on Google Maps'
                                      : 'Set start & destination to open Google Maps',
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: hasLocations
                                        ? () async {
                                            await MapsLauncherService.openGoogleMapsDirections(
                                              origin: _startLocationController
                                                  .text
                                                  .trim(),
                                              destination:
                                                  _destinationController.text
                                                      .trim(),
                                              transportMode: _transportMode,
                                            );
                                          }
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: hasLocations
                                            ? AppTheme.darkTeal.withValues(
                                                alpha: 0.2,
                                              )
                                            : colorScheme.surface.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: hasLocations
                                              ? AppTheme.darkTeal.withValues(
                                                  alpha: 0.5,
                                                )
                                              : colorScheme.outline.withValues(
                                                  alpha: 0.2,
                                                ),
                                        ),
                                      ),
                                      child: Icon(
                                        _getTransportIcon(_transportMode),
                                        size: 18,
                                        color: hasLocations
                                            ? AppTheme.darkTeal
                                            : colorScheme.onSurface.withValues(
                                                alpha: 0.4,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$_travelMinutes mins commute',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    if (_bufferMinutes > 0) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '(+$_bufferMinutes min buffer)',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.burntOrange,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),

                            if (_destinationController.text
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 15,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _destinationController.text.trim(),
                                      style: GoogleFonts.fredoka(
                                        fontSize: 13,
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.75,
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

              // Action row
              Center(
                child: SizedBox(
                  width: blockWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text(
                            'Edit Event',
                            style: GoogleFonts.fredoka(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _openShareDialog,
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: Text(
                            'Share Countdown',
                            style: GoogleFonts.fredoka(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
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
