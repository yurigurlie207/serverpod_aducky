// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

void assignUrl(String url) {
  html.window.location.assign(url);
}

void setCodeVerifier(String verifier) {
  html.window.sessionStorage['google_code_verifier'] = verifier;
}

String? getCodeVerifier() {
  return html.window.sessionStorage['google_code_verifier'];
}

void clearCodeInUrl() {
  final currentUrl = html.window.location.href;
  final url = Uri.parse(currentUrl);
  if (url.queryParameters.containsKey('code')) {
    final queryParams = Map<String, String>.from(url.queryParameters);
    queryParams.remove('code');
    queryParams.remove('scope');
    queryParams.remove('authuser');
    queryParams.remove('prompt');

    final newUrl = url.replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    html.window.history.replaceState({}, '', newUrl.toString());
  }
}
