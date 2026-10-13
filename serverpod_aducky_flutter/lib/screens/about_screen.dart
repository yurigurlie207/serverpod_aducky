import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../client.dart';
import '../widgets/ducky_leaf_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _ContactDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About a Ducky',
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 36.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/ducky_logo.png',
                                height: 56,
                                width: 56,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Hi, and Welcome!',
                                style: GoogleFonts.fredoka(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'This app is built by a neurodivergent mom who wants to reduce the daily mental load of a busy and chaotic schedule of being a parent. a Ducky is currently integrated with Google Identity, Google Maps/Places, Google Calendar and Twilio SMS. AI Assist soon to be integrated using Claude.',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            height: 1.55,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Let a Ducky ease the mental gymnastics needed for getting to your next calendar event with minimal distractions, so you can just do the thing!',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            height: 1.55,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _showContactDialog(context),
                            icon: const Icon(Icons.mail_outline, size: 20),
                            label: Text(
                              'Contact Us',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  const _ContactDialog();

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _honeypotController = TextEditingController();
  final _challengeController = TextEditingController();

  late final DateTime _openedAt;
  late final int _challengeA;
  late final int _challengeB;
  late final int _expectedAnswer;

  bool _isSubmitting = false;
  String? _statusError;
  bool _isSent = false;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    final rnd = math.Random();
    _challengeA = rnd.nextInt(6) + 2; // 2..7
    _challengeB = rnd.nextInt(5) + 1; // 1..5
    _expectedAnswer = _challengeA + _challengeB;

    _prefillIfSignedIn();
  }

  Future<void> _prefillIfSignedIn() async {
    try {
      final profile = await client.profile.getProfile();
      if (profile != null && mounted) {
        if (_nameController.text.isEmpty && profile.homeAddress.isNotEmpty) {
          // Keep blank or prefill
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _honeypotController.dispose();
    _challengeController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    setState(() => _statusError = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();
    final honeypot = _honeypotController.text.trim();
    final answerText = _challengeController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      setState(() => _statusError = 'Please fill out all fields.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _statusError = 'Please enter a valid email address.');
      return;
    }

    // 1. Anti-spam: Honeypot check
    if (honeypot.isNotEmpty) {
      // Silently fail for bots
      setState(() => _isSent = true);
      return;
    }

    // 2. Anti-spam: Human verification challenge
    final parsedAnswer = int.tryParse(answerText);
    if (parsedAnswer == null || parsedAnswer != _expectedAnswer) {
      setState(
        () => _statusError =
            'Please answer the verification question ($_challengeA + $_challengeB).',
      );
      return;
    }

    // 3. Anti-spam: Submission time check
    final durationSeconds = DateTime.now().difference(_openedAt).inSeconds;
    if (durationSeconds < 2) {
      setState(() => _statusError = 'Please take a moment before submitting.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await client.contact.sendContactMessage(
        name: name,
        email: email,
        message: message,
        honeypot: honeypot,
        humanAnswer: parsedAnswer,
        expectedAnswer: _expectedAnswer,
        durationSeconds: durationSeconds,
      );

      if (success) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _isSent = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _statusError =
                'Unable to send message right now. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _statusError = 'Error sending message: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const DuckyLeafWidget(size: 20),
          const SizedBox(width: 8),
          Text(
            'Contact Us',
            style: GoogleFonts.fredoka(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: _isSent
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Icon(
                      Icons.check_circle_outline,
                      size: 52,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Thank You!',
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your message has been sent directly to the creator. We will get back to you soon!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        height: 1.4,
                        color: colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send a direct message to the creator.',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        height: 1.35,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Off-screen Honeypot field (Catches automated spam bots)
                    Offstage(
                      offstage: true,
                      child: TextField(
                        controller: _honeypotController,
                        decoration: const InputDecoration(labelText: 'Website'),
                      ),
                    ),

                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Your Email',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        alignLabelWithHint: true,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Anti-Spam Human Verification Challenge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.35,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Verify you are human:\n$_challengeA + $_challengeB = ?',
                              style: GoogleFonts.fredoka(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 68,
                            child: TextField(
                              controller: _challengeController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Answer',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_statusError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _statusError!,
                        style: GoogleFonts.fredoka(
                          color: colorScheme.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
      actions: [
        if (_isSent) ...[
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : _submitMessage,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send, size: 16),
            label: Text(
              _isSubmitting ? 'Sending...' : 'Send Message',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }
}
