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

import 'package:shared_preferences/shared_preferences.dart';

class ProfilePreferences {
  static const String _phoneNumberKey = 'user_profile_phone_number';
  static const String _userNameKey = 'user_profile_user_name';
  static const String _eventPersonPrefix = 'event_person_';

  static String? _cachedUserName;
  static final Map<String, String> _eventPersonCache = {};

  static Future<String?> getUserName() async {
    if (_cachedUserName != null && _cachedUserName!.isNotEmpty) {
      return _cachedUserName;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_userNameKey);
      if (name != null && name.trim().isNotEmpty) {
        _cachedUserName = name.trim();
        return _cachedUserName;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static String? getCachedUserName() => _cachedUserName;

  static Future<void> saveUserName(String name) async {
    _cachedUserName = name.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, name.trim());
    } catch (_) {
      // Ignore write errors
    }
  }

  static Future<String?> getEventPerson(String eventId) async {
    if (eventId.isEmpty) return null;
    if (_eventPersonCache.containsKey(eventId)) {
      return _eventPersonCache[eventId];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final person = prefs.getString('$_eventPersonPrefix$eventId');
      if (person != null && person.trim().isNotEmpty) {
        _eventPersonCache[eventId] = person.trim();
        return person.trim();
      }
    } catch (_) {}
    return null;
  }

  static String? getCachedEventPerson(String eventId) {
    if (eventId.isEmpty) return null;
    return _eventPersonCache[eventId];
  }

  static Future<void> saveEventPerson(String eventId, String person) async {
    if (eventId.isEmpty) return;
    _eventPersonCache[eventId] = person.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_eventPersonPrefix$eventId', person.trim());
    } catch (_) {}
  }

  static Future<void> loadEventPersons(List<String> eventIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final id in eventIds) {
        if (id.isEmpty) continue;
        final person = prefs.getString('$_eventPersonPrefix$id');
        if (person != null && person.trim().isNotEmpty) {
          _eventPersonCache[id] = person.trim();
        }
      }
    } catch (_) {}
  }

  static Future<String?> getPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_phoneNumberKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> savePhoneNumber(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneNumberKey, phoneNumber.trim());
    } catch (_) {
      // Ignore write errors
    }
  }
}
