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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serverpod_aducky_client/serverpod_aducky_client.dart';
import '../client.dart';
import '../services/profile_preferences.dart';
import '../theme/app_theme.dart';

class InlineEventEditor extends StatefulWidget {
  final CalendarEvent? event;
  final String? defaultStartLocation;
  final ValueChanged<CalendarEvent> onSave;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;
  final bool allowAdjustTravelTime;
  final bool allowEditEndTime;

  const InlineEventEditor({
    super.key,
    this.event,
    this.defaultStartLocation,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
    this.allowAdjustTravelTime = true,
    this.allowEditEndTime = true,
  });

  @override
  State<InlineEventEditor> createState() => _InlineEventEditorState();
}

class _InlineEventEditorState extends State<InlineEventEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _startLocationController;
  late TextEditingController _locationController;
  late String _transportMode;
  late DateTime _startTime;
  late DateTime _endTime;

  String? _selectedPerson;
  List<String> _personOptions = [];

  int? _travelMinutes;
  bool _isCalculatingTravel = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    final initialStart =
        widget.event?.startLocation ?? widget.defaultStartLocation ?? '';
    _startLocationController = TextEditingController(text: initialStart);
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );
    _transportMode = widget.event?.transportMode ?? 'driving';

    final now = DateTime.now();
    _startTime =
        widget.event?.startTime.toLocal() ??
        DateTime(now.year, now.month, now.day, now.hour + 1);
    _endTime =
        widget.event?.endTime.toLocal() ??
        _startTime.add(const Duration(hours: 1));

    if (_startLocationController.text.isEmpty) {
      _loadDefaultHomeAddress();
    } else if (_locationController.text.isNotEmpty) {
      _calculateTravelTime();
    }
    _loadPersonOptions();
  }

  Future<void> _loadPersonOptions() async {
    final profileName = await ProfilePreferences.getUserName();
    final accountUserName =
        (profileName != null && profileName.trim().isNotEmpty)
        ? profileName.trim()
        : 'Account User';

    String? existingPerson;
    if (widget.event != null) {
      existingPerson = await ProfilePreferences.getEventPerson(
        widget.event!.eventId,
      );
    }

    if (mounted) {
      setState(() {
        final options = <String>[accountUserName];
        if (!options.contains('Family')) options.add('Family');
        if (!options.contains('Partner')) options.add('Partner');
        if (!options.contains('Child')) options.add('Child');
        if (existingPerson != null && !options.contains(existingPerson)) {
          options.add(existingPerson);
        }

        _personOptions = options;
        _selectedPerson = existingPerson ?? accountUserName;
      });
    }
  }

  Future<void> _loadDefaultHomeAddress() async {
    try {
      final profile = await client.profile.getProfile();
      if (profile != null && profile.homeAddress.isNotEmpty && mounted) {
        if (_startLocationController.text.isEmpty) {
          setState(() {
            _startLocationController.text = profile.homeAddress;
          });
        }
        if (_locationController.text.isNotEmpty && _travelMinutes == null) {
          _calculateTravelTime();
        }
      }
    } catch (_) {}
  }

  Future<void> _calculateTravelTime() async {
    final dest = _locationController.text.trim();
    if (dest.isEmpty) {
      setState(() {
        _travelMinutes = null;
      });
      return;
    }
    String origin = _startLocationController.text.trim();
    if (origin.isEmpty && widget.defaultStartLocation != null) {
      origin = widget.defaultStartLocation!.trim();
    }
    if (origin.isEmpty) {
      return;
    }

    setState(() => _isCalculatingTravel = true);
    try {
      final res = await client.travel.getTravelTime(
        origin: origin,
        destination: dest,
        mode: _transportMode,
      );
      if (mounted) {
        setState(() {
          _travelMinutes = res.durationMinutes;
        });
      }
    } catch (e) {
      debugPrint('Error calculating travel in editor: $e');
    } finally {
      if (mounted) {
        setState(() => _isCalculatingTravel = false);
      }
    }
  }

  Future<void> _showAdjustTravelDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: (_travelMinutes ?? 15).toString(),
    );
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            'Adjust Commute Time',
            style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter duration in minutes for this commute:',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Commute Minutes',
                  suffixText: 'mins',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [10, 15, 20, 30, 45, 60].map((mins) {
                  return ActionChip(
                    label: Text('${mins}m'),
                    onPressed: () {
                      controller.text = mins.toString();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await _calculateTravelTime();
              },
              child: const Text('Reset from Maps'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed != null && parsed >= 0) {
                  Navigator.pop(dialogCtx, parsed);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _travelMinutes = selected;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startLocationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final currentDateTime = isStart ? _startTime : _endTime;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
    );

    if (selectedTime == null) return;

    setState(() {
      final newDateTime = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      if (isStart) {
        _startTime = newDateTime;
        if (_startTime.isAfter(_endTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      } else {
        _endTime = newDateTime;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final loc = _locationController.text.trim();
    final startLoc = _startLocationController.text.trim();
    final savedEvent =
        widget.event?.copyWith(
          title: _titleController.text.trim(),
          location: loc.isNotEmpty ? loc : null,
          startLocation: startLoc.isNotEmpty ? startLoc : null,
          transportMode: _transportMode,
          startTime: _startTime.toUtc(),
          endTime: _endTime.toUtc(),
        ) ??
        CalendarEvent(
          eventId: 'local_${DateTime.now().millisecondsSinceEpoch}',
          title: _titleController.text.trim(),
          location: loc.isNotEmpty ? loc : null,
          startLocation: startLoc.isNotEmpty ? startLoc : null,
          transportMode: _transportMode,
          startTime: _startTime.toUtc(),
          endTime: _endTime.toUtc(),
        );

    if (_selectedPerson != null && _selectedPerson!.isNotEmpty) {
      ProfilePreferences.saveEventPerson(savedEvent.eventId, _selectedPerson!);
    }
    widget.onSave(savedEvent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.event != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Centered intuitive close button without box area
          Center(
            child: Tooltip(
              message: 'Close',
              child: InkResponse(
                onTap: widget.onCancel,
                radius: 22,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 28,
                    color: Colors.white.withValues(alpha: 0.90),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!isEditing) ...[
            Center(
              child: Text(
                'New Event',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Event',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Title is required'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(_selectedPerson),
            initialValue: _personOptions.contains(_selectedPerson)
                ? _selectedPerson
                : (_personOptions.isNotEmpty ? _personOptions.first : null),
            decoration: const InputDecoration(
              labelText: 'Person',
              isDense: true,
              prefixIcon: Icon(Icons.person_outline, size: 20),
              border: OutlineInputBorder(),
            ),
            icon: const Icon(Icons.arrow_drop_down),
            items: _personOptions.map((person) {
              return DropdownMenuItem<String>(
                value: person,
                child: Text(
                  person,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPerson = val;
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // Start and End Time Sliding Scale with start and end nodes to drag
          LayoutBuilder(
            builder: (context, constraints) {
              final startMins = (_startTime.hour * 60 + _startTime.minute)
                  .toDouble();
              final endMins = (_endTime.hour * 60 + _endTime.minute).toDouble();
              final validStart = startMins.clamp(0.0, 1425.0);
              final validEnd =
                  (endMins <= validStart ? validStart + 15.0 : endMins).clamp(
                    15.0,
                    1440.0,
                  );

              final totalWidth = constraints.maxWidth;
              // Track insets in SliderTheme: default thumb radius 9, horizontal inset ~16.0
              const trackInset = 16.0;
              final usableTrack = math.max(totalWidth - (trackInset * 2), 40.0);

              final tStart = (validStart / 1440.0).clamp(0.0, 1.0);
              final tEnd = (validEnd / 1440.0).clamp(0.0, 1.0);

              final xStart = trackInset + tStart * usableTrack;
              final xEnd = trackInset + tEnd * usableTrack;

              // Time labels above the dots (moving dynamically with the dots)
              const labelW = 64.0;
              var leftStartLabel = (xStart - labelW / 2).clamp(
                0.0,
                totalWidth - labelW,
              );
              var leftEndLabel = (xEnd - labelW / 2).clamp(
                0.0,
                totalWidth - labelW,
              );

              // Avoid time label collision if dots are close
              if (leftEndLabel - leftStartLabel < labelW) {
                final mid = (xStart + xEnd) / 2;
                leftStartLabel = (mid - labelW - 2).clamp(
                  0.0,
                  totalWidth - labelW * 2,
                );
                leftEndLabel = leftStartLabel + labelW + 2;
              }

              // Sub-labels ("start" and "end") below the dots
              const subW = 44.0;
              var leftStartSub = (xStart - subW / 2).clamp(
                0.0,
                totalWidth - subW,
              );
              var leftEndSub = (xEnd - subW / 2).clamp(0.0, totalWidth - subW);

              if (leftEndSub - leftStartSub < subW) {
                final mid = (xStart + xEnd) / 2;
                leftStartSub = (mid - subW - 2).clamp(
                  0.0,
                  totalWidth - subW * 2,
                );
                leftEndSub = leftStartSub + subW + 2;
              }

              final startTimeStr = DateFormat(
                'h:mm a',
              ).format(_startTime).toLowerCase();
              final endTimeStr = DateFormat(
                'h:mm a',
              ).format(_endTime).toLowerCase();

              if (!widget.allowEditEndTime) {
                // Current Event mode: Only start time is editable!
                return Container(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? AppTheme.deepForest.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.20)
                          : colorScheme.onSurface.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Moving start time label above the dot
                      SizedBox(
                        height: 20,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: leftStartLabel,
                              width: labelW,
                              child: GestureDetector(
                                onTap: () => _pickTime(true),
                                child: Text(
                                  startTimeStr,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Single Slider with start dot only
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.22,
                          ),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.18),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 9,
                            elevation: 2,
                          ),
                        ),
                        child: Slider(
                          value: validStart,
                          min: 0,
                          max: 1440,
                          divisions: 96,
                          onChanged: (double newValue) {
                            final snappedStart = (newValue / 15).round() * 15;
                            final sHour = (snappedStart ~/ 60).clamp(0, 23);
                            final sMin = (snappedStart % 60).clamp(0, 59);
                            final newStart = DateTime(
                              _startTime.year,
                              _startTime.month,
                              _startTime.day,
                              sHour,
                              sMin,
                            );
                            final duration = _endTime.difference(_startTime);
                            final effectiveDuration = duration > Duration.zero
                                ? duration
                                : const Duration(minutes: 30);
                            setState(() {
                              _startTime = newStart;
                              _endTime = _startTime.add(effectiveDuration);
                            });
                          },
                        ),
                      ),

                      // Moving "start" text below the dot
                      SizedBox(
                        height: 16,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: leftStartSub,
                              width: subW,
                              child: Text(
                                'start',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.70),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? AppTheme.deepForest.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.20)
                        : colorScheme.onSurface.withValues(alpha: 0.18),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Moving time labels above the dots
                    SizedBox(
                      height: 20,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: leftStartLabel,
                            width: labelW,
                            child: GestureDetector(
                              onTap: () => _pickTime(true),
                              child: Text(
                                startTimeStr,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: leftEndLabel,
                            width: labelW,
                            child: GestureDetector(
                              onTap: () => _pickTime(false),
                              child: Text(
                                endTimeStr,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RangeSlider with start and end dots
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withValues(
                          alpha: 0.22,
                        ),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withValues(alpha: 0.18),
                        trackHeight: 4,
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 9,
                          elevation: 2,
                        ),
                      ),
                      child: RangeSlider(
                        values: RangeValues(validStart, validEnd),
                        min: 0,
                        max: 1440,
                        divisions: 96,
                        onChanged: (RangeValues newValues) {
                          final snappedStart =
                              (newValues.start / 15).round() * 15;
                          var snappedEnd = (newValues.end / 15).round() * 15;
                          if (snappedEnd <= snappedStart) {
                            snappedEnd = math.min(snappedStart + 15, 1440);
                          }
                          final sHour = (snappedStart ~/ 60).clamp(0, 23);
                          final sMin = (snappedStart % 60).clamp(0, 59);
                          final eHour = (snappedEnd ~/ 60).clamp(0, 23);
                          final eMin = (snappedEnd % 60).clamp(0, 59);

                          setState(() {
                            _startTime = DateTime(
                              _startTime.year,
                              _startTime.month,
                              _startTime.day,
                              sHour,
                              sMin,
                            );
                            _endTime = DateTime(
                              _endTime.year,
                              _endTime.month,
                              _endTime.day,
                              eHour,
                              eMin,
                            );
                          });
                        },
                      ),
                    ),

                    // Moving "start" and "end" text below the dots
                    SizedBox(
                      height: 16,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: leftStartSub,
                            width: subW,
                            child: Text(
                              'start',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.70),
                              ),
                            ),
                          ),
                          Positioned(
                            left: leftEndSub,
                            width: subW,
                            child: Text(
                              'end',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.70),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Google Maps-style route origin and destination container
          Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppTheme.deepForest.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.20)
                    : colorScheme.onSurface.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Google Maps route icons (circle, connector dots, pin)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: const Color(0xFF4285F4),
                          width: 2.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    for (int i = 0; i < 3; i++) ...[
                      Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i < 2) const SizedBox(height: 2.5),
                    ],
                    const SizedBox(height: 3),
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFFEA4335),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                const SizedBox(width: 10),
                // Right: Start and Destination Autocompletes
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Starting point Autocomplete
                      Autocomplete<PlaceSuggestion>(
                        initialValue: TextEditingValue(
                          text: _startLocationController.text,
                        ),
                        displayStringForOption: (option) => option.description,
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<PlaceSuggestion>.empty();
                              }
                              try {
                                return await client.places.getSuggestions(
                                  textEditingValue.text,
                                );
                              } catch (_) {
                                return const Iterable<PlaceSuggestion>.empty();
                              }
                            },
                        onSelected: (PlaceSuggestion selection) {
                          _startLocationController.text = selection.description;
                          _calculateTravelTime();
                        },
                        fieldViewBuilder:
                            (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              if (textEditingController.text !=
                                      _startLocationController.text &&
                                  _startLocationController.text.isNotEmpty &&
                                  textEditingController.text.isEmpty) {
                                textEditingController.text =
                                    _startLocationController.text;
                              }
                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                ),
                                onChanged: (val) {
                                  _startLocationController.text = val;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Choose starting point',
                                  hintStyle: GoogleFonts.fredoka(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  border: InputBorder.none,
                                ),
                              );
                            },
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.onSurface.withValues(alpha: 0.12),
                      ),
                      // Destination Location Autocomplete
                      Autocomplete<PlaceSuggestion>(
                        initialValue: TextEditingValue(
                          text: widget.event?.location ?? '',
                        ),
                        displayStringForOption: (option) => option.description,
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<PlaceSuggestion>.empty();
                              }
                              try {
                                return await client.places.getSuggestions(
                                  textEditingValue.text,
                                );
                              } catch (_) {
                                return const Iterable<PlaceSuggestion>.empty();
                              }
                            },
                        onSelected: (PlaceSuggestion selection) {
                          _locationController.text = selection.description;
                          _calculateTravelTime();
                        },
                        fieldViewBuilder:
                            (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                ),
                                onChanged: (val) {
                                  _locationController.text = val;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Choose destination',
                                  hintStyle: GoogleFonts.fredoka(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  border: InputBorder.none,
                                ),
                              );
                            },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Unified One-Line Travel Mode & Estimated Travel Time with transparent overlay
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppTheme.deepForest.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.20)
                    : colorScheme.onSurface.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minimal Travel Mode Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(
                      alpha: isDark ? 0.35 : 0.45,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _transportMode,
                      isDense: true,
                      elevation: 1,
                      dropdownColor: isDark
                          ? AppTheme.forestGreen
                          : AppTheme.cream,
                      borderRadius: BorderRadius.circular(14),
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: colorScheme.primary.withValues(alpha: 0.8),
                        ),
                      ),
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'driving',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_car, size: 15),
                              SizedBox(width: 6),
                              Text('Drive'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'transit',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_transit, size: 15),
                              SizedBox(width: 6),
                              Text('Transit'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'walking',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_walk, size: 15),
                              SizedBox(width: 6),
                              Text('Walk'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'bicycling',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_bike, size: 15),
                              SizedBox(width: 6),
                              Text('Bike'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (String? newMode) {
                        if (newMode == null || newMode == _transportMode) {
                          return;
                        }
                        setState(() {
                          _transportMode = newMode;
                        });
                        _calculateTravelTime();
                      },
                    ),
                  ),
                ),

                // Estimated Travel Time
                if (_isCalculatingTravel)
                  Text(
                    'Calculating...',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  )
                else if (_travelMinutes != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 15,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_travelMinutes mins commute',
                        style: GoogleFonts.fredoka(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (widget.allowAdjustTravelTime) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: 'Adjust commute time',
                          child: InkWell(
                            onTap: () => _showAdjustTravelDialog(context),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 15,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Text(
                    _locationController.text.isEmpty
                        ? 'Enter destination'
                        : 'Set commute time',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.onDelete != null)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  onPressed: widget.onDelete,
                  child: const Text('Delete'),
                ),
              const Spacer(),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _submit,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
