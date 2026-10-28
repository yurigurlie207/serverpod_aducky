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
    super.dispose();
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.deepForest : AppTheme.warmLinen,
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
              ),
            ),
          ],
        ),
        actions: [
          if (_event != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share link',
              onPressed: _openShareDialog,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: _buildBody(colorScheme, isDark),
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.goldenYellow),
            const SizedBox(height: 16),
            Text(
              'Loading countdown...',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null || _event == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.link_off_rounded,
                size: 48,
                color: AppTheme.burntOrange,
              ),
              const SizedBox(height: 14),
              Text(
                'Countdown Not Found',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'This link may have expired.',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
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
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.darkTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(
                  'Create Your Own Event',
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final event = _event!;
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

    final hasLocations =
        event.startLocation?.trim().isNotEmpty == true &&
        event.location?.trim().isNotEmpty == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final blockWidth = (constraints.maxWidth * 0.92).clamp(280.0, 480.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Guest view badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.goldenYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.goldenYellow.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.public_rounded,
                        size: 13,
                        color: AppTheme.burntOrange,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Live Shared Focus View',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.burntOrange,
                        ),
                      ),
                    ],
                  ),
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
                      color: isDark
                          ? AppTheme.forestGreen.withValues(alpha: 0.4)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : colorScheme.outline.withValues(alpha: 0.2),
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

              // Current Event Details Card
              Center(
                child: SizedBox(
                  width: blockWidth,
                  child: Card(
                    elevation: 0,
                    color: isDark
                        ? AppTheme.forestGreen.withValues(alpha: 0.45)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isLate
                            ? const Color(0xFFFF8A80).withValues(alpha: 0.5)
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : colorScheme.outline.withValues(
                                      alpha: 0.25,
                                    )),
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title + Person
                          Text(
                            event.title,
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
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
                                color: AppTheme.burntOrange,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          const SizedBox(height: 6),

                          // Start Time
                          Text(
                            'Starts ${DateFormat('h:mm a').format(event.startTime.toLocal()).toLowerCase()}',
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
                                        : AppTheme.burntOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Leave by: ${DateFormat('h:mm a').format(leaveByTimeUtc.toLocal()).toLowerCase()}',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isLate
                                          ? const Color(0xFFFF8A80)
                                          : AppTheme.burntOrange,
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
                                      _getTransportIcon(event.transportMode),
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

                              // Commute and buffer text
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$travelMins mins commute',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  if (bufferMins > 0) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '(+$bufferMins min buffer)',
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

                          if (event.location != null &&
                              event.location!.isNotEmpty) ...[
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
                                    event.location!,
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

              const SizedBox(height: 24),

              // Action Buttons for Public Visitors
              Center(
                child: SizedBox(
                  width: blockWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _openShareDialog,
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          'Share This Live Countdown',
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.4),
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
                          backgroundColor: AppTheme.darkTeal,
                          foregroundColor: Colors.white,
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
