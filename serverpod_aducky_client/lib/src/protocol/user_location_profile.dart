/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class UserLocationProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserLocationProfile._({
    this.id,
    required this.authUserId,
    required this.homeAddress,
    required this.homeLat,
    required this.homeLng,
    int? meetingBufferMinutes,
    this.googleAccessToken,
  }) : meetingBufferMinutes = meetingBufferMinutes ?? 0;

  factory UserLocationProfile({
    int? id,
    required _isc.UuidValue authUserId,
    required String homeAddress,
    required double homeLat,
    required double homeLng,
    int? meetingBufferMinutes,
    String? googleAccessToken,
  }) = _UserLocationProfileImpl;

  factory UserLocationProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserLocationProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      homeAddress: jsonSerialization['homeAddress'] as String,
      homeLat: (jsonSerialization['homeLat'] as num).toDouble(),
      homeLng: (jsonSerialization['homeLng'] as num).toDouble(),
      meetingBufferMinutes: jsonSerialization['meetingBufferMinutes'] as int?,
      googleAccessToken: jsonSerialization['googleAccessToken'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue authUserId;

  String homeAddress;

  double homeLat;

  double homeLng;

  int? meetingBufferMinutes;

  String? googleAccessToken;

  /// Returns a shallow copy of this [UserLocationProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserLocationProfile copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    String? homeAddress,
    double? homeLat,
    double? homeLng,
    int? meetingBufferMinutes,
    String? googleAccessToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserLocationProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'homeAddress': homeAddress,
      'homeLat': homeLat,
      'homeLng': homeLng,
      if (meetingBufferMinutes != null)
        'meetingBufferMinutes': meetingBufferMinutes,
      if (googleAccessToken != null) 'googleAccessToken': googleAccessToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserLocationProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'homeAddress': homeAddress,
      'homeLat': homeLat,
      'homeLng': homeLng,
      if (meetingBufferMinutes != null)
        'meetingBufferMinutes': meetingBufferMinutes,
      if (googleAccessToken != null) 'googleAccessToken': googleAccessToken,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserLocationProfileImpl extends UserLocationProfile {
  _UserLocationProfileImpl({
    int? id,
    required _isc.UuidValue authUserId,
    required String homeAddress,
    required double homeLat,
    required double homeLng,
    int? meetingBufferMinutes,
    String? googleAccessToken,
  }) : super._(
         id: id,
         authUserId: authUserId,
         homeAddress: homeAddress,
         homeLat: homeLat,
         homeLng: homeLng,
         meetingBufferMinutes: meetingBufferMinutes,
         googleAccessToken: googleAccessToken,
       );

  /// Returns a shallow copy of this [UserLocationProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserLocationProfile copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    String? homeAddress,
    double? homeLat,
    double? homeLng,
    Object? meetingBufferMinutes = _Undefined,
    Object? googleAccessToken = _Undefined,
  }) {
    return UserLocationProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      homeAddress: homeAddress ?? this.homeAddress,
      homeLat: homeLat ?? this.homeLat,
      homeLng: homeLng ?? this.homeLng,
      meetingBufferMinutes: meetingBufferMinutes is int?
          ? meetingBufferMinutes
          : this.meetingBufferMinutes,
      googleAccessToken: googleAccessToken is String?
          ? googleAccessToken
          : this.googleAccessToken,
    );
  }
}
