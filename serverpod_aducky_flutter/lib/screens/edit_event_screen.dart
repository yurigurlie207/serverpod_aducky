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
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_aducky_client/serverpod_aducky_client.dart';
import '../client.dart';
import '../services/profile_preferences.dart';
import 'about_screen.dart';

class EditEventScreen extends StatefulWidget {
  final CalendarEvent? event;
  final String? defaultStartLocation;
  final int? defaultBufferMinutes;

  const EditEventScreen({
    super.key,
    this.event,
    this.defaultStartLocation,
    this.defaultBufferMinutes,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _startLocationController;
  late TextEditingController _locationController;
  late TextEditingController _bufferController;
  late String _transportMode;
  late DateTime _startTime;
  late DateTime _endTime;
  bool _isSaving = false;

  String? _selectedPerson;
  List<String> _personOptions = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    final eventStart = widget.event?.startLocation?.trim();
    final defaultStart = widget.defaultStartLocation?.trim();
    final initialStart = (eventStart != null && eventStart.isNotEmpty)
        ? eventStart
        : (defaultStart != null && defaultStart.isNotEmpty)
        ? defaultStart
        : '';
    _startLocationController = TextEditingController(text: initialStart);
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );
    final initialBuffer =
        widget.event?.bufferMinutes ?? widget.defaultBufferMinutes ?? 0;
    _bufferController = TextEditingController(text: initialBuffer.toString());
    _transportMode = widget.event?.transportMode ?? 'driving';
    final now = DateTime.now();
    _startTime =
        widget.event?.startTime.toLocal() ??
        DateTime(now.year, now.month, now.day, now.hour + 1);
    _endTime =
        widget.event?.endTime.toLocal() ??
        _startTime.add(const Duration(hours: 1));

    if (_startLocationController.text.trim().isEmpty) {
      _loadDefaultHomeAddress();
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
      if (profile != null && profile.homeAddress.trim().isNotEmpty && mounted) {
        if (_startLocationController.text.trim().isEmpty) {
          setState(() {
            _startLocationController.text = profile.homeAddress.trim();
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startLocationController.dispose();
    _locationController.dispose();
    _bufferController.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final loc = _locationController.text.trim();
      var startLoc = _startLocationController.text.trim();
      if (startLoc.isEmpty &&
          widget.defaultStartLocation != null &&
          widget.defaultStartLocation!.trim().isNotEmpty) {
        startLoc = widget.defaultStartLocation!.trim();
      }
      final bufferMins =
          int.tryParse(_bufferController.text.trim()) ??
          widget.defaultBufferMinutes ??
          0;
      final savedEvent =
          widget.event?.copyWith(
            title: _titleController.text.trim(),
            location: loc.isNotEmpty ? loc : null,
            startLocation: startLoc.isNotEmpty ? startLoc : null,
            transportMode: _transportMode,
            bufferMinutes: bufferMins,
            startTime: _startTime.toUtc(),
            endTime: _endTime.toUtc(),
          ) ??
          CalendarEvent(
            eventId: 'local_${DateTime.now().millisecondsSinceEpoch}',
            title: _titleController.text.trim(),
            location: loc.isNotEmpty ? loc : null,
            startLocation: startLoc.isNotEmpty ? startLoc : null,
            transportMode: _transportMode,
            bufferMinutes: bufferMins,
            startTime: _startTime.toUtc(),
            endTime: _endTime.toUtc(),
          );

      if (_selectedPerson != null && _selectedPerson!.isNotEmpty) {
        await ProfilePreferences.saveEventPerson(
          savedEvent.eventId,
          _selectedPerson!,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(savedEvent);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewEvent = widget.event == null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewEvent ? 'New Event' : 'Edit Event',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!isNewEvent)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
              ),
              tooltip: 'Delete Event',
              onPressed: () async {
                final navigator = Navigator.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(
                      'Delete Event',
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
                    ),
                    content: const Text(
                      'Are you sure you want to remove this event from your app?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (!mounted) return;
                if (confirm == true) {
                  navigator.pop('delete');
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 22),
            tooltip: 'About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                'Save',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Event',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          key: ValueKey(_selectedPerson),
                          initialValue: _personOptions.contains(_selectedPerson)
                              ? _selectedPerson
                              : (_personOptions.isNotEmpty
                                    ? _personOptions.first
                                    : null),
                          decoration: const InputDecoration(
                            labelText: 'Person',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: _personOptions.map((person) {
                            return DropdownMenuItem<String>(
                              value: person,
                              child: Text(
                                person,
                                style: GoogleFonts.fredoka(
                                  fontSize: 15,
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
                        const SizedBox(height: 16),

                        // Start and End Time Sliding Scale
                        Builder(
                          builder: (context) {
                            final startMins =
                                (_startTime.hour * 60 + _startTime.minute)
                                    .toDouble();
                            final endMins =
                                (_endTime.hour * 60 + _endTime.minute)
                                    .toDouble();
                            final validStart = startMins.clamp(0.0, 1425.0);
                            final validEnd =
                                (endMins <= validStart
                                        ? validStart + 15.0
                                        : endMins)
                                    .clamp(15.0, 1440.0);
                            final duration = _endTime.difference(_startTime);
                            final totalMins = duration.inMinutes;
                            final durH = totalMins ~/ 60;
                            final durM = totalMins % 60;
                            final durStr = totalMins <= 0
                                ? '0m'
                                : durH == 0
                                ? '${durM}m'
                                : durM == 0
                                ? '${durH}h'
                                : '${durH}h ${durM}m';

                            return Container(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                10,
                                14,
                                10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.20,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => _pickTime(true),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: Colors.white.withValues(
                                                  alpha: 0.85,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                'Start ${DateFormat('h:mm a').format(_startTime).toLowerCase()}',
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.16,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          durStr,
                                          style: GoogleFonts.fredoka(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _pickTime(false),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'End ${DateFormat('h:mm a').format(_endTime).toLowerCase()}',
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: Colors.white.withValues(
                                                  alpha: 0.85,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white
                                          .withValues(alpha: 0.22),
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      trackHeight: 4,
                                      rangeThumbShape:
                                          const RoundRangeSliderThumbShape(
                                            enabledThumbRadius: 8,
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
                                        var snappedEnd =
                                            (newValues.end / 15).round() * 15;
                                        if (snappedEnd <= snappedStart) {
                                          snappedEnd = math.min(
                                            snappedStart + 15,
                                            1440,
                                          );
                                        }
                                        final sHour = (snappedStart ~/ 60)
                                            .clamp(0, 23);
                                        final sMin = (snappedStart % 60).clamp(
                                          0,
                                          59,
                                        );
                                        final eHour = (snappedEnd ~/ 60).clamp(
                                          0,
                                          23,
                                        );
                                        final eMin = (snappedEnd % 60).clamp(
                                          0,
                                          59,
                                        );

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
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Autocomplete<PlaceSuggestion>(
                          initialValue: TextEditingValue(
                            text: _startLocationController.text,
                          ),
                          displayStringForOption: (option) =>
                              option.description,
                          optionsBuilder:
                              (TextEditingValue textEditingValue) async {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<
                                    PlaceSuggestion
                                  >.empty();
                                }
                                try {
                                  return await client.places.getSuggestions(
                                    textEditingValue.text,
                                  );
                                } catch (e) {
                                  return const Iterable<
                                    PlaceSuggestion
                                  >.empty();
                                }
                              },
                          onSelected: (PlaceSuggestion selection) {
                            _startLocationController.text =
                                selection.description;
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
                                  onChanged: (val) {
                                    _startLocationController.text = val;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Starting Location',
                                    border: OutlineInputBorder(),
                                  ),
                                );
                              },
                        ),
                        const SizedBox(height: 16),
                        Autocomplete<PlaceSuggestion>(
                          initialValue: TextEditingValue(
                            text: widget.event?.location ?? '',
                          ),
                          displayStringForOption: (option) =>
                              option.description,
                          optionsBuilder:
                              (TextEditingValue textEditingValue) async {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<
                                    PlaceSuggestion
                                  >.empty();
                                }
                                try {
                                  return await client.places.getSuggestions(
                                    textEditingValue.text,
                                  );
                                } catch (e) {
                                  return const Iterable<
                                    PlaceSuggestion
                                  >.empty();
                                }
                              },
                          onSelected: (PlaceSuggestion selection) {
                            _locationController.text = selection.description;
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
                                  onChanged: (val) {
                                    _locationController.text = val;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Destination Location',
                                    border: OutlineInputBorder(),
                                  ),
                                );
                              },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                ButtonSegment<String>(
                                  value: 'driving',
                                  icon: Icon(Icons.directions_car, size: 16),
                                  label: Text('Drive'),
                                ),
                                ButtonSegment<String>(
                                  value: 'transit',
                                  icon: Icon(
                                    Icons.directions_transit,
                                    size: 16,
                                  ),
                                  label: Text('Transit'),
                                ),
                                ButtonSegment<String>(
                                  value: 'walking',
                                  icon: Icon(Icons.directions_walk, size: 16),
                                  label: Text('Walk'),
                                ),
                                ButtonSegment<String>(
                                  value: 'bicycling',
                                  icon: Icon(Icons.directions_bike, size: 16),
                                  label: Text('Bike'),
                                ),
                              ],
                              selected: {_transportMode},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _transportMode = newSelection.first;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buffer Time',
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _bufferController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Buffer Minutes',
                                hintText: 'Extra padding before meeting',
                                prefixIcon: const Icon(
                                  Icons.hourglass_empty_rounded,
                                  size: 20,
                                ),
                                suffixText: 'mins',
                                border: const OutlineInputBorder(),
                                helperText:
                                    'Extra time added before arrival for peace of mind',
                                helperStyle: GoogleFonts.fredoka(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [0, 5, 10, 15, 20, 30].map((mins) {
                                return ActionChip(
                                  label: Text('${mins}m'),
                                  onPressed: () {
                                    setState(() {
                                      _bufferController.text = mins.toString();
                                    });
                                  },
                                );
                              }).toList(),
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
}
