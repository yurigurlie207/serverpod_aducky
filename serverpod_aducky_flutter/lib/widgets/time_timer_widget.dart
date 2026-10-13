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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeTimerWidget extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  final Color activeColor;
  final Color innerCircleColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? brandText;

  const TimeTimerWidget({
    super.key,
    required this.remaining,
    this.total = const Duration(minutes: 60),
    this.activeColor = const Color(
      0xFF164F40,
    ), // Darker Forest Green / Teal (Countdown)
    this.innerCircleColor = const Color(0xFF90CDF4), // Pale Blue (Inner Circle)
    this.backgroundColor,
    this.borderColor,
    this.brandText,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp the fraction between 0 and 1
    double fraction = remaining.inMicroseconds / total.inMicroseconds;
    if (fraction < 0) fraction = 0;
    if (fraction > 1) fraction = 1;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBg =
        backgroundColor ??
        (isDark ? const Color(0xFF103A30) : const Color(0xFFFAF5EC));
    final effectiveBorder =
        borderColor ??
        (isDark ? const Color(0xFFF3EAD7) : const Color(0xFF0A2923));

    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _TimeTimerPainter(
          fraction: fraction,
          activeColor: activeColor,
          innerCircleColor: innerCircleColor,
          backgroundColor: effectiveBg,
          borderColor: effectiveBorder,
        ),
      ),
    );
  }
}

class _TimeTimerPainter extends CustomPainter {
  final double fraction;
  final Color activeColor;
  final Color innerCircleColor;
  final Color backgroundColor;
  final Color borderColor;

  _TimeTimerPainter({
    required this.fraction,
    required this.activeColor,
    required this.innerCircleColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final dialRadius = w * 0.46;
    final wedgeRadius = dialRadius * 0.76;

    // 1. Dial Base (matches background, pale blue removed)
    final dialBgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, wedgeRadius, dialBgPaint);

    // 2. The Active Swept Wedge (Time Remaining - Teal)
    if (fraction > 0) {
      final diskRect = Rect.fromCircle(center: center, radius: wedgeRadius);
      final sweepAngle = fraction * 2 * pi;

      final diskPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      // Sweeps counter-clockwise from 12 o'clock (-pi / 2)
      canvas.drawArc(
        diskRect,
        -pi / 2, // Top (12 o'clock)
        -sweepAngle, // Counter-clockwise
        true,
        diskPaint,
      );
    }

    // 3. Delicate Radial Minute Ticks
    final tickInner = wedgeRadius;
    final tickMajorOuter = wedgeRadius + w * 0.026;
    final tickMinorOuter = wedgeRadius + w * 0.014;

    for (int m = 0; m < 60; m++) {
      final isMajor = m % 5 == 0;
      final angle = -pi / 2 - (m / 60.0) * 2 * pi;
      final outerRadius = isMajor ? tickMajorOuter : tickMinorOuter;

      final tickPaint = Paint()
        ..color = borderColor.withValues(alpha: isMajor ? 0.55 : 0.20)
        ..strokeWidth = isMajor ? 1.5 : 0.8
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      final p1 = Offset(
        center.dx + tickInner * cos(angle),
        center.dy + tickInner * sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 4. Clean Fredoka Numbers (0, 5, 10, ..., 55)
    final numRadius = dialRadius * 0.90;
    final numValues = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

    for (final num in numValues) {
      final angle = -pi / 2 - (num / 60.0) * 2 * pi;
      final text = '$num';

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: GoogleFonts.fredoka(
            color: borderColor.withValues(alpha: 0.72),
            fontSize: w * 0.060,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + numRadius * cos(angle) - textPainter.width / 2,
        center.dy + numRadius * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }

    // 5. Minimal Center Hub Pip
    final hubRadius = w * 0.038;
    final hubPaint = Paint()
      ..color = innerCircleColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, hubRadius, hubPaint);

    final hubBorderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;
    canvas.drawCircle(center, hubRadius, hubBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _TimeTimerPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.innerCircleColor != innerCircleColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor;
  }
}
