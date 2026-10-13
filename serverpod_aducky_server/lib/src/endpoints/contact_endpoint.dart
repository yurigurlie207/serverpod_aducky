import 'package:serverpod/serverpod.dart';

class ContactEndpoint extends Endpoint {
  static const String destinationEmail = 'adrienne.yao@gmail.com';

  Future<bool> sendContactMessage(
    Session session, {
    required String name,
    required String email,
    required String message,
    required String honeypot,
    required int humanAnswer,
    required int expectedAnswer,
    required int durationSeconds,
  }) async {
    // 1. Anti-spam: Honeypot check (hidden field filled only by bots)
    if (honeypot.trim().isNotEmpty) {
      session.log(
        'Spam blocked: honeypot field was populated',
        level: LogLevel.warning,
      );
      return false;
    }

    // 2. Anti-spam: Human verification challenge
    if (humanAnswer != expectedAnswer) {
      session.log(
        'Spam blocked: failed human challenge ($humanAnswer != $expectedAnswer)',
        level: LogLevel.warning,
      );
      return false;
    }

    // 3. Anti-spam: Form submission speed (bots submit in under 2 seconds)
    if (durationSeconds < 2) {
      session.log(
        'Spam blocked: submitted unnaturally fast (${durationSeconds}s)',
        level: LogLevel.warning,
      );
      return false;
    }

    // 4. Anti-spam: Basic rate limiting (max 3 messages per hour)
    final rateKey = 'contact_rate_${email.trim().toLowerCase()}';
    final existingCount = (await session.caches.local.get<int>(rateKey)) ?? 0;
    if (existingCount >= 3) {
      session.log(
        'Spam blocked: rate limit exceeded for $email',
        level: LogLevel.warning,
      );
      return false;
    }
    await session.caches.local.put(
      rateKey,
      existingCount + 1,
      lifetime: const Duration(hours: 1),
    );

    // 5. Anti-spam: Message content validation
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanMsg = message.trim();

    if (cleanName.isEmpty || cleanEmail.isEmpty || cleanMsg.isEmpty) {
      return false;
    }

    if (cleanMsg.length < 4 || cleanMsg.length > 3000) {
      return false;
    }

    // Reject messages with excessive URLs (typical spam bots)
    final urlCount = RegExp(r'https?:\/\/').allMatches(cleanMsg).length;
    if (urlCount > 2) {
      session.log(
        'Spam blocked: message contains excessive hyperlinks ($urlCount)',
        level: LogLevel.warning,
      );
      return false;
    }

    // 6. Record and route message to recipient
    session.log(
      'CONTACT MESSAGE RECEIVED FOR $destinationEmail:\n'
      'From: $cleanName <$cleanEmail>\n'
      'Time: ${DateTime.now().toUtc().toIso8601String()}\n'
      'Message: $cleanMsg',
      level: LogLevel.info,
    );

    return true;
  }
}
