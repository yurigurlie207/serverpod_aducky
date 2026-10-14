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
import 'package:serverpod_aducky_client/serverpod_aducky_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../client.dart';
import '../services/profile_preferences.dart';
import '../services/sms_notification_service.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bufferController = TextEditingController(
    text: '0',
  );
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSendingTestSms = false;
  double? _selectedLat;
  double? _selectedLng;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _bufferController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      // Assuming client.profile is generated
      final profile = await client.profile.getProfile();
      if (profile != null) {
        _addressController.text = profile.homeAddress;
        _bufferController.text = (profile.meetingBufferMinutes ?? 0).toString();
      }
      final savedName = await ProfilePreferences.getUserName();
      if (savedName != null && savedName.isNotEmpty) {
        _nameController.text = savedName;
      }
      final savedPhone = await ProfilePreferences.getPhoneNumber();
      if (savedPhone != null) {
        final digits = savedPhone.replaceAll(RegExp(r'\D'), '');
        if (digits.length == 10) {
          _phoneController.text =
              '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
        } else {
          _phoneController.text = savedPhone;
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (e.toString().contains('401')) {
        await client.auth.signOutDevice();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 5),
              content: Text('Session expired. Please sign in again.'),
            ),
          );
          Navigator.of(context).pop(); // Go back to dashboard/signin
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final phone = _phoneController.text.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.isNotEmpty && digits.length != 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              'Please enter a valid 10-digit phone number (e.g. 333-333-3333).',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await client.profile.saveProfile(
        homeAddress: _addressController.text,
        homeLat: _selectedLat ?? 40.7128, // Use selected or default
        homeLng: _selectedLng ?? -74.0060, // Use selected or default
        meetingBufferMinutes: int.tryParse(_bufferController.text.trim()) ?? 0,
      );
      await ProfilePreferences.saveUserName(_nameController.text.trim());
      await ProfilePreferences.savePhoneNumber(_phoneController.text);
      widget.onProfileUpdated?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text('Profile saved!'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text('Error saving profile. Are you logged in?'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendTestSms() async {
    final phone = _phoneController.text.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
              'Please enter a valid 10-digit phone number (e.g. 333-333-3333) before trying SMS.',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSendingTestSms = true;
    });

    try {
      await ProfilePreferences.savePhoneNumber(_phoneController.text);

      if (mounted) {
        await SmsNotificationService.sendTestSms(
          context: context,
          phoneNumber: phone,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingTestSms = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await client.auth.signOutDevice();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 5),
            content: Text('Failed to sign out.'),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                      fontSize: 22,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 0,
                    color: colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 32.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Name',
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Adrienne',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Home Address',
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Autocomplete<PlaceSuggestion>(
                            displayStringForOption: (option) =>
                                option.description,
                            optionsBuilder:
                                (TextEditingValue textEditingValue) async {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<
                                      PlaceSuggestion
                                    >.empty();
                                  }
                                  return await client.places.getSuggestions(
                                    textEditingValue.text,
                                  );
                                },
                            onSelected: (PlaceSuggestion selection) async {
                              _addressController.text = selection.description;
                              final details = await client.places
                                  .getPlaceDetails(
                                    selection.placeId,
                                  );
                              if (details != null && mounted) {
                                setState(() {
                                  _selectedLat = details.lat;
                                  _selectedLng = details.lng;
                                });
                              }
                            },
                            fieldViewBuilder:
                                (
                                  context,
                                  textEditingController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  if (textEditingController.text !=
                                      _addressController.text) {
                                    textEditingController.text =
                                        _addressController.text;
                                  }
                                  textEditingController.addListener(() {
                                    _addressController.text =
                                        textEditingController.text;
                                  });

                                  return TextField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      hintText: 'e.g. 123 Main St, Anytown',
                                    ),
                                  );
                                },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Buffer Time',
                            style: GoogleFonts.fredoka(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _bufferController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 5, 10, 15',
                              suffixText: 'mins',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Phone Number',
                            style: GoogleFonts.fredoka(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    PhoneNumberFormatter(),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: '333-333-3333',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: _isSendingTestSms
                                    ? null
                                    : _sendTestSms,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isSendingTestSms
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Try SMS'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _saveProfile,
                            child: const Text('Save Profile'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _signOut,
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.error,
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digitsOnly.length > 10
        ? digitsOnly.substring(0, 10)
        : digitsOnly;
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('-');
      }
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
