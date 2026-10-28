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

import 'client.dart';
import 'screens/dashboard_screen.dart';
import 'screens/shared_event_screen.dart';
import 'screens/sign_in_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const MyApp());
}

String? _getShareTokenFromUri() {
  try {
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('share')) {
      final token = uri.queryParameters['share'];
      if (token != null && token.trim().isNotEmpty) {
        return token.trim();
      }
    }
    if (uri.hasFragment && uri.fragment.contains('share=')) {
      final frag = uri.fragment;
      final qIndex = frag.indexOf('share=');
      if (qIndex != -1) {
        final sub = frag.substring(qIndex + 'share='.length);
        final ampIndex = sub.indexOf('&');
        final token = ampIndex != -1 ? sub.substring(0, ampIndex) : sub;
        if (token.trim().isNotEmpty) {
          return token.trim();
        }
      }
    }
  } catch (_) {}
  return null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'a Ducky — Smart Calendar & Focus Companion',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        final theme = brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
        return ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: const MyHomePage(title: 'a Ducky'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final shareToken = _getShareTokenFromUri();
    if (shareToken != null) {
      return SharedEventScreen(shareToken: shareToken);
    }

    return const SignInScreen(
      child: DashboardScreen(),
    );
  }
}
