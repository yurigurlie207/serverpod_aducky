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
import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../client.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/google_auth_helper.dart';
import '../services/google_auth_locator.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'single_event_screen.dart';

class SignInScreen extends StatefulWidget {
  final Widget child;
  const SignInScreen({super.key, required this.child});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignedIn = false;
  late final EmailAuthController _emailAuthController;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_updateSignedInState);
    _isSignedIn = client.auth.isAuthenticated;

    _emailAuthController = EmailAuthController(
      client: client,
      onAuthenticated: () {
        context.showSnackBar(
          message: 'Authenticated.',
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF00695C),
        );
      },
      onError: (error) {
        context.showSnackBar(
          message: 'Authentication failed: $error',
          backgroundColor: const Color(0xFFFF8A80),
          foregroundColor: const Color(0xFF490000),
        );
      },
    );

    if (kIsWeb) {
      final code = Uri.base.queryParameters['code'];
      if (code != null) {
        _handleOAuthCallback(code);
      }
    }
  }

  @override
  void dispose() {
    _emailAuthController.dispose();
    client.auth.authInfoListenable.removeListener(_updateSignedInState);
    super.dispose();
  }

  void _updateSignedInState() {
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
    });
  }

  Future<void> _handleOAuthCallback(String code) async {
    clearCodeInUrl();
    final verifier = getCodeVerifier();
    if (verifier != null) {
      try {
        final endpoint = client.googleIdp;
        final authSuccess = await endpoint.loginWithCode(
          code: code,
          codeVerifier: verifier,
          redirectUri: 'http://localhost:8082/auth/callback',
        );

        await client.auth.updateSignedInUser(authSuccess);
        if (mounted) {
          context.showSnackBar(
            message: 'User authenticated with Google.',
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          );
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(
            message: 'Error signing in: $e',
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _isSignedIn
        ? widget.child
        : Scaffold(
            appBar: AppBar(
              title: Tooltip(
                message: 'About a Ducky',
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/ducky_logo.png',
                          height: 38,
                          width: 38,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'a Ducky',
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
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
                          vertical: 32.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListenableBuilder(
                              listenable: _emailAuthController,
                              builder: (context, _) {
                                final screen =
                                    _emailAuthController.currentScreen;
                                if (screen ==
                                    EmailFlowScreen.startRegistration) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 6,
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.email_outlined,
                                              size: 20,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                controller: _emailAuthController
                                                    .emailController,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                style: GoogleFonts.fredoka(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'Enter your email',
                                                  hintStyle:
                                                      GoogleFonts.fredoka(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                        fontSize: 15,
                                                      ),
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                ),
                                                onSubmitted: (_) async {
                                                  if (_emailAuthController
                                                      .emailController
                                                      .text
                                                      .trim()
                                                      .isNotEmpty) {
                                                    await _emailAuthController
                                                        .startRegistration();
                                                  }
                                                },
                                              ),
                                            ),
                                            FilledButton(
                                              onPressed:
                                                  _emailAuthController.isLoading
                                                  ? null
                                                  : () async {
                                                      if (_emailAuthController
                                                          .emailController
                                                          .text
                                                          .trim()
                                                          .isNotEmpty) {
                                                        await _emailAuthController
                                                            .startRegistration();
                                                      }
                                                    },
                                              style: FilledButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF00695C,
                                                ),
                                                foregroundColor: Colors.white,
                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.4),
                                                  width: 1,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                textStyle: GoogleFonts.fredoka(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              child:
                                                  _emailAuthController.isLoading
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text('Continue'),
                                                        SizedBox(width: 4),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_rounded,
                                                          size: 16,
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account? ',
                                            style: GoogleFonts.fredoka(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                _emailAuthController.navigateTo(
                                                  EmailFlowScreen.login,
                                                ),
                                            child: Text(
                                              'Sign In',
                                              style: GoogleFonts.fredoka(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else if (screen == EmailFlowScreen.login) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextField(
                                        controller: _emailAuthController
                                            .emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: GoogleFonts.fredoka(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: GoogleFonts.fredoka(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            size: 20,
                                            color: Colors.white70,
                                          ),
                                          isDense: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.white.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(
                                        controller: _emailAuthController
                                            .passwordController,
                                        obscureText: true,
                                        style: GoogleFonts.fredoka(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          labelStyle: GoogleFonts.fredoka(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            size: 20,
                                            color: Colors.white70,
                                          ),
                                          isDense: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.white.withValues(
                                                alpha: 0.35,
                                              ),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () =>
                                              _emailAuthController.navigateTo(
                                                EmailFlowScreen
                                                    .requestPasswordReset,
                                              ),
                                          child: Text(
                                            'Forgot password?',
                                            style: GoogleFonts.fredoka(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      FilledButton(
                                        onPressed:
                                            _emailAuthController.isLoading
                                            ? null
                                            : () async {
                                                await _emailAuthController
                                                    .login();
                                              },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF00695C,
                                          ),
                                          foregroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.4,
                                            ),
                                            width: 1,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          textStyle: GoogleFonts.fredoka(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        child: _emailAuthController.isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Text('Sign In'),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Don't have an account? ",
                                            style: GoogleFonts.fredoka(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () =>
                                                _emailAuthController.navigateTo(
                                                  EmailFlowScreen
                                                      .startRegistration,
                                                ),
                                            child: Text(
                                              'Sign Up',
                                              style: GoogleFonts.fredoka(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return EmailSignInWidget(
                                    controller: _emailAuthController,
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'or',
                                    style: GoogleFonts.fredoka(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            FilledButton(
                              onPressed: () {
                                if (kIsWeb) {
                                  redirectToGoogleOAuth(
                                    '969323443665-vfivtsblpp7nbukjrjtl1if0o1khk49k.apps.googleusercontent.com',
                                    'http://localhost:8082/auth/callback',
                                  );
                                } else {
                                  context.showSnackBar(
                                    message:
                                        'Google login is only implemented for Web.',
                                    backgroundColor: colors.errorContainer,
                                    foregroundColor: colors.onErrorContainer,
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C),
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: GoogleFonts.fredoka(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              child: const Text('Sign in with Google'),
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SingleEventScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.flash_on_rounded,
                                color: AppTheme.goldenYellow,
                                size: 18,
                              ),
                              label: const Text(
                                'Use for a Single Event (No Account)',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: AppTheme.goldenYellow.withValues(
                                    alpha: 0.65,
                                  ),
                                  width: 1.2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: GoogleFonts.fredoka(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

extension on BuildContext {
  void showSnackBar({
    required String message,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: foregroundColor)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
