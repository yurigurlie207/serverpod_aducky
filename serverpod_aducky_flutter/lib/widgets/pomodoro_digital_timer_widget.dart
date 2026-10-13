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

class PomodoroDigitalTimerWidget extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  final String? headerText;
  final String? subtitleText;
  final bool isLate;
  final bool isOngoing;
  final Color? trackColor;
  final Color? progressColor;
  final Color? textColor;

  const PomodoroDigitalTimerWidget({
    super.key,
    required this.remaining,
    this.total = const Duration(minutes: 60),
    this.headerText,
    this.subtitleText,
    this.isLate = false,
    this.isOngoing = false,
    this.trackColor,
    this.progressColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveTrack =
        trackColor ??
        (isDark ? const Color(0xFF1E3831) : const Color(0xFFE2EBE6));
    final effectiveProgress =
        progressColor ??
        (isLate
            ? theme.colorScheme.error
            : (isDark ? const Color(0xFF2E8B6E) : const Color(0xFF164F40)));
    final effectiveText =
        textColor ??
        (isLate
            ? theme.colorScheme.error
            : (isDark ? const Color(0xFFF3EAD7) : const Color(0xFF0E382F)));

    double fraction = 0.0;
    if (total.inMicroseconds > 0) {
      fraction = (remaining.inMicroseconds / total.inMicroseconds).clamp(
        0.0,
        1.0,
      );
    }
    if (isLate) fraction = 0.0;

    // Digital time format: hours and minutes (e.g. 4:15 or 0:25)
    final int hours = remaining.inHours;
    final int minutes = (remaining.inMinutes % 60).abs();

    String timeDisplay;
    if (isLate) {
      final lateHours = remaining.abs().inHours;
      final lateMins = (remaining.abs().inMinutes % 60);
      if (lateHours > 0) {
        timeDisplay = '+$lateHours:${lateMins.toString().padLeft(2, '0')}';
      } else {
        timeDisplay = '+0:${lateMins.toString().padLeft(2, '0')}';
      }
    } else if (hours > 0) {
      timeDisplay = '$hours:${minutes.toString().padLeft(2, '0')}';
    } else {
      timeDisplay = '0:${minutes.toString().padLeft(2, '0')}';
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          final strokeWidth = size * 0.038;

          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Circular Progress Track & Progress Arc
              CustomPaint(
                size: Size(size, size),
                painter: _PomodoroRingPainter(
                  fraction: fraction,
                  trackColor: effectiveTrack,
                  progressColor: effectiveProgress,
                  strokeWidth: strokeWidth,
                ),
              ),

              // 2. Centered Minimalist Typography Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size * 0.12),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timeDisplay,
                      style: GoogleFonts.fredoka(
                        fontSize: size * 0.25,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -1.0,
                        color: effectiveText,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PomodoroRingPainter extends CustomPainter {
  final double fraction;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _PomodoroRingPainter({
    required this.fraction,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) * 0.44;

    // Background Inactive Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    // Active Sweeping Arc (Clockwise from top)
    if (fraction > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      final startAngle = -math.pi / 2;
      final sweepAngle = fraction * 2 * math.pi;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PomodoroRingPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
