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

class SingleEventScreen extends StatefulWidget {
  const SingleEventScreen({super.key});

  @override
  State<SingleEventScreen> createState() => _SingleEventScreenState();
}

class _SingleEventScreenState extends State<SingleEventScreen> {
  bool _isConfigured = false;
  bool _isEditing = false;
  bool _isCalculatingTravel = false;

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

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        final newDate = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
        if (isStart) {
          _startTime = newDate;
          if (_startTime.isAfter(_endTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          _endTime = newDate;
        }
      });
    }
  }

  Future<void> _calculateTravel() async {
    final start = _startLocationController.text.trim();
    final dest = _destinationController.text.trim();
    if (start.isEmpty || dest.isEmpty) return;

    setState(() => _isCalculatingTravel = true);
    try {
      final result = await client.travel.getTravelTime(
        origin: start,
        destination: dest,
        mode: _transportMode,
      );
      if (mounted && result.durationMinutes > 0) {
        setState(() {
          _travelMinutes = result.durationMinutes;
          _isCalculatingTravel = false;
        });
      } else {
        setState(() => _isCalculatingTravel = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isCalculatingTravel = false);
    }
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
          constraints: const BoxConstraints(maxWidth: 540),
          child: !_isConfigured || _isEditing
              ? _buildConfigForm(colorScheme, isDark)
              : _buildLiveCountdown(colorScheme, isDark),
        ),
      ),
    );
  }

  Widget _buildConfigForm(ColorScheme colorScheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.goldenYellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.goldenYellow.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.burntOrange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No account needed! Set up your current event to get a real-time countdown dial with travel & buffer time.',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      color: isDark ? Colors.white : AppTheme.deepBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Title
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Event Name',
              hintText: 'e.g. Doctor appointment, Flight, Coffee with Sarah',
              prefixIcon: const Icon(Icons.event_note_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: GoogleFonts.fredoka(fontSize: 15),
          ),

          const SizedBox(height: 16),

          // Time Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickTime(true),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.35),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Start',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'h:mm a',
                              ).format(_startTime).toLowerCase(),
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _pickTime(false),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.35),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event End',
                          style: GoogleFonts.fredoka(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.done_all_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'h:mm a',
                              ).format(_endTime).toLowerCase(),
                              style: GoogleFonts.fredoka(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Destination
          Autocomplete<PlaceSuggestion>(
            initialValue: TextEditingValue(text: _destinationController.text),
            displayStringForOption: (o) => o.description,
            optionsBuilder: (textVal) async {
              if (textVal.text.trim().isEmpty) return const [];
              try {
                return await client.places.getSuggestions(textVal.text);
              } catch (_) {
                return const [];
              }
            },
            onSelected: (sel) {
              _destinationController.text = sel.description;
              _calculateTravel();
            },
            fieldViewBuilder: (ctx, ctrl, fn, onSubmitted) {
              if (ctrl.text != _destinationController.text &&
                  _destinationController.text.isNotEmpty &&
                  ctrl.text.isEmpty) {
                ctrl.text = _destinationController.text;
              }
              return TextField(
                controller: ctrl,
                focusNode: fn,
                onChanged: (val) => _destinationController.text = val,
                decoration: InputDecoration(
                  labelText: 'Destination Location',
                  hintText: 'e.g. 123 Main St, New York',
                  prefixIcon: const Icon(Icons.place_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.fredoka(fontSize: 14),
              );
            },
          ),

          const SizedBox(height: 16),

          // Starting Location
          Autocomplete<PlaceSuggestion>(
            initialValue: TextEditingValue(text: _startLocationController.text),
            displayStringForOption: (o) => o.description,
            optionsBuilder: (textVal) async {
              if (textVal.text.trim().isEmpty) return const [];
              try {
                return await client.places.getSuggestions(textVal.text);
              } catch (_) {
                return const [];
              }
            },
            onSelected: (sel) {
              _startLocationController.text = sel.description;
              _calculateTravel();
            },
            fieldViewBuilder: (ctx, ctrl, fn, onSubmitted) {
              if (ctrl.text != _startLocationController.text &&
                  _startLocationController.text.isNotEmpty &&
                  ctrl.text.isEmpty) {
                ctrl.text = _startLocationController.text;
              }
              return TextField(
                controller: ctrl,
                focusNode: fn,
                onChanged: (val) => _startLocationController.text = val,
                decoration: InputDecoration(
                  labelText: 'Starting Location (Optional)',
                  hintText: 'e.g. Home, Office, or Current Location',
                  prefixIcon: const Icon(Icons.my_location_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.fredoka(fontSize: 14),
              );
            },
          ),

          const SizedBox(height: 16),

          // Travel Mode
          Text(
            'Travel Mode',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'driving',
                icon: Icon(Icons.directions_car, size: 16),
                label: Text('Drive'),
              ),
              ButtonSegment(
                value: 'transit',
                icon: Icon(Icons.directions_transit, size: 16),
                label: Text('Transit'),
              ),
              ButtonSegment(
                value: 'walking',
                icon: Icon(Icons.directions_walk, size: 16),
                label: Text('Walk'),
              ),
              ButtonSegment(
                value: 'bicycling',
                icon: Icon(Icons.directions_bike, size: 16),
                label: Text('Bike'),
              ),
            ],
            selected: {_transportMode},
            onSelectionChanged: (newSel) {
              setState(() => _transportMode = newSel.first);
              _calculateTravel();
            },
          ),

          const SizedBox(height: 16),

          // Commute & Buffer Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commute Time: ${_isCalculatingTravel ? '...' : '$_travelMinutes min'}',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [10, 15, 20, 30, 45].map((m) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text('${m}m'),
                            backgroundColor: _travelMinutes == m
                                ? AppTheme.darkTeal.withValues(alpha: 0.25)
                                : null,
                            onPressed: () => setState(() => _travelMinutes = m),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Buffer Time Quick Chips
          Text(
            'Meeting Buffer Time: $_bufferMinutes min',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [0, 5, 10, 15, 20, 30].map((m) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ActionChip(
                  label: Text('${m}m'),
                  backgroundColor: _bufferMinutes == m
                      ? AppTheme.goldenYellow.withValues(alpha: 0.35)
                      : null,
                  onPressed: () => setState(() => _bufferMinutes = m),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Start Countdown Button
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _isConfigured = true;
                _isEditing = false;
              });
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              _isConfigured ? 'Update Countdown' : 'Start Live Countdown',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.darkTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
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
