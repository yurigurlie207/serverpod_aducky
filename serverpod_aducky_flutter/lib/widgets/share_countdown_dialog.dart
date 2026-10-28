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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../client.dart';
import '../theme/app_theme.dart';

class ShareCountdownDialog extends StatefulWidget {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String? startLocation;
  final String? transportMode;
  final int? travelMinutes;
  final int? bufferMinutes;
  final String? personName;
  final String? existingToken;

  const ShareCountdownDialog({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.startLocation,
    this.transportMode,
    this.travelMinutes,
    this.bufferMinutes,
    this.personName,
    this.existingToken,
  });

  @override
  State<ShareCountdownDialog> createState() => _ShareCountdownDialogState();
}

class _ShareCountdownDialogState extends State<ShareCountdownDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isGenerating = true;
  String? _shareToken;
  String? _shareUrl;
  String? _errorMessage;

  bool _isSendingSms = false;
  bool _smsSent = false;
  String? _smsStatusMessage;

  bool _isSendingEmail = false;
  bool _emailSent = false;
  String? _emailStatusMessage;

  bool _linkCopied = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingToken != null && widget.existingToken!.isNotEmpty) {
      _shareToken = widget.existingToken;
      _shareUrl = _buildShareUrl(_shareToken!);
      _isGenerating = false;
    } else {
      _createLink();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _buildShareUrl(String token) {
    try {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty &&
          !origin.startsWith('file:') &&
          !origin.startsWith('about:')) {
        return '$origin/?share=$token';
      }
    } catch (_) {}
    return 'http://localhost:8082/?share=$token';
  }

  Future<void> _createLink() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final sharedEvent = await client.share.createShareLink(
        title: widget.title,
        startTime: widget.startTime.toUtc(),
        endTime: widget.endTime.toUtc(),
        location: widget.location,
        startLocation: widget.startLocation,
        transportMode: widget.transportMode,
        travelMinutes: widget.travelMinutes,
        bufferMinutes: widget.bufferMinutes,
        personName: widget.personName,
      );

      if (mounted) {
        setState(() {
          _shareToken = sharedEvent.shareToken;
          _shareUrl = _buildShareUrl(sharedEvent.shareToken);
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not generate share link: $e';
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_shareUrl == null) return;
    await Clipboard.setData(ClipboardData(text: _shareUrl!));
    if (mounted) {
      setState(() => _linkCopied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Countdown link copied to clipboard!'),
          duration: Duration(seconds: 5),
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _linkCopied = false);
      });
    }
  }

  Future<void> _sendSms() async {
    final phone = _phoneController.text.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number.'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    if (_shareToken == null || _shareUrl == null) return;

    setState(() {
      _isSendingSms = true;
      _smsStatusMessage = null;
    });

    try {
      final success = await client.share.sendShareLink(
        token: _shareToken!,
        phoneNumber: phone,
        shareUrl: _shareUrl!,
      );

      if (mounted) {
        setState(() {
          _isSendingSms = false;
          _smsSent = true;
          _smsStatusMessage = success
              ? 'SMS invitation sent successfully!'
              : 'Message logged. (Configure Twilio in passwords.yaml for carrier delivery)';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_smsStatusMessage!),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingSms = false;
          _smsStatusMessage = 'Error sending SMS: $e';
        });
      }
    }
  }

  Future<void> _sendEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    if (_shareToken == null || _shareUrl == null) return;

    setState(() {
      _isSendingEmail = true;
      _emailStatusMessage = null;
    });

    try {
      final success = await client.share.sendShareLink(
        token: _shareToken!,
        email: email,
        shareUrl: _shareUrl!,
      );

      if (mounted) {
        setState(() {
          _isSendingEmail = false;
          _emailSent = true;
          _emailStatusMessage = success
              ? 'Share notification routed to $email'
              : 'Could not send email';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_emailStatusMessage!),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSendingEmail = false;
          _emailStatusMessage = 'Error sending email: $e';
        });
      }
    }
  }

  Future<void> _openEmailApp() async {
    if (_shareUrl == null) return;
    final subject = Uri.encodeComponent('Live Countdown: ${widget.title}');
    final body = Uri.encodeComponent(
      'Hey,\n\nHere is the live countdown and event details for "${widget.title}":\n$_shareUrl\n\nYou can track the departure timer in real-time without needing an account!',
    );
    final email = _emailController.text.trim();
    final to = email.isNotEmpty ? email : '';
    final mailtoUri = Uri.parse('mailto:$to?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      } else {
        await _copyToClipboard();
      }
    } catch (_) {
      await _copyToClipboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final travel = widget.travelMinutes ?? 0;
    final buffer = widget.bufferMinutes ?? 0;
    final leaveByLocal = widget.startTime.subtract(
      Duration(minutes: travel + buffer),
    );
    final startStr = DateFormat(
      'h:mm a',
    ).format(widget.startTime.toLocal()).toLowerCase();
    final leaveByStr = DateFormat(
      'h:mm a',
    ).format(leaveByLocal.toLocal()).toLowerCase();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.deepForest : AppTheme.warmLinen,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : colorScheme.outline.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.goldenYellow.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: AppTheme.goldenYellow,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share Live Countdown',
                              style: GoogleFonts.fredoka(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Anyone with the link gets live timer & event details',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Event Preview Summary Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.forestGreen.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.goldenYellow.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.goldenYellow.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Starts $startStr',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.burntOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.departure_board_rounded,
                              size: 14,
                              color: AppTheme.goldenYellow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Leave by: $leaveByStr',
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.goldenYellow,
                              ),
                            ),
                            if (travel > 0 || buffer > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '($travel min travel + $buffer min buffer)',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.65,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.location != null &&
                            widget.location!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 13,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.location!,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
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

                  const SizedBox(height: 18),

                  if (_isGenerating)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            color: AppTheme.goldenYellow,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Generating live countdown link...',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.fredoka(color: colorScheme.error),
                      ),
                    )
                  else ...[
                    // Option 1: Direct Link Copy Box
                    Text(
                      'Live Countdown Link',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _shareUrl ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _copyToClipboard,
                            style: FilledButton.styleFrom(
                              backgroundColor: _linkCopied
                                  ? Colors.green
                                  : AppTheme.darkTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(
                              _linkCopied ? Icons.check : Icons.copy_rounded,
                              size: 15,
                            ),
                            label: Text(
                              _linkCopied ? 'Copied' : 'Copy',
                              style: GoogleFonts.fredoka(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),

                    // Option 2: Send via SMS / Phone Number
                    Text(
                      'Send via Text Message (SMS)',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: '(555) 000-0000',
                              hintStyle: GoogleFonts.fredoka(
                                fontSize: 13,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.phone_iphone_rounded,
                                size: 18,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _isSendingSms ? null : _sendSms,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.goldenYellow,
                            foregroundColor: AppTheme.deepBrown,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSendingSms
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.deepBrown,
                                  ),
                                )
                              : Text(
                                  _smsSent ? 'Sent ✓' : 'Send Text',
                                  style: GoogleFonts.fredoka(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Option 3: Send via Email
                    Text(
                      'Send via Email',
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'colleague@example.com',
                              hintStyle: GoogleFonts.fredoka(
                                fontSize: 13,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 18,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _isSendingEmail ? null : _sendEmail,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.darkTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSendingEmail
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _emailSent ? 'Sent ✓' : 'Send Email',
                                  style: GoogleFonts.fredoka(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _openEmailApp,
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: Text(
                          'Open in your email app instead',
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
