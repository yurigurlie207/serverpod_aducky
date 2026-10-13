import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import 'google_auth_locator.dart';

void redirectToGoogleOAuth(String clientId, String redirectUri) {
  final random = Random.secure();
  final verifierBytes = List<int>.generate(32, (i) => random.nextInt(256));
  final codeVerifier = base64UrlEncode(verifierBytes).replaceAll('=', '');

  final challengeBytes = sha256.convert(utf8.encode(codeVerifier)).bytes;
  final codeChallenge = base64UrlEncode(challengeBytes).replaceAll('=', '');

  setCodeVerifier(codeVerifier);

  final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'response_type': 'code',
    'scope':
        'openid email profile https://www.googleapis.com/auth/calendar.readonly',
    'code_challenge': codeChallenge,
    'code_challenge_method': 'S256',
    'prompt': 'select_account',
    'access_type': 'offline',
  });

  assignUrl(url.toString());
}
