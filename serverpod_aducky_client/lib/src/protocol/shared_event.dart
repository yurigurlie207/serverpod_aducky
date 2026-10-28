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

abstract class SharedEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SharedEvent._({
    this.id,
    required this.shareToken,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.startLocation,
    String? transportMode,
    int? travelMinutes,
    int? bufferMinutes,
    required this.leaveByTime,
    this.personName,
    this.createdById,
    required this.createdAt,
    this.expiresAt,
  }) : transportMode = transportMode ?? 'driving',
       travelMinutes = travelMinutes ?? 0,
       bufferMinutes = bufferMinutes ?? 0;

  factory SharedEvent({
    int? id,
    required String shareToken,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? startLocation,
    String? transportMode,
    int? travelMinutes,
    int? bufferMinutes,
    required DateTime leaveByTime,
    String? personName,
    _isc.UuidValue? createdById,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) = _SharedEventImpl;

  factory SharedEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return SharedEvent(
      id: jsonSerialization['id'] as int?,
      shareToken: jsonSerialization['shareToken'] as String,
      title: jsonSerialization['title'] as String,
      startTime: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['endTime'],
      ),
      location: jsonSerialization['location'] as String?,
      startLocation: jsonSerialization['startLocation'] as String?,
      transportMode: jsonSerialization['transportMode'] as String?,
      travelMinutes: jsonSerialization['travelMinutes'] as int?,
      bufferMinutes: jsonSerialization['bufferMinutes'] as int?,
      leaveByTime: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['leaveByTime'],
      ),
      personName: jsonSerialization['personName'] as String?,
      createdById: jsonSerialization['createdById'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdById'],
            ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String shareToken;

  String title;

  DateTime startTime;

  DateTime endTime;

  String? location;

  String? startLocation;

  String? transportMode;

  int? travelMinutes;

  int? bufferMinutes;

  DateTime leaveByTime;

  String? personName;

  _isc.UuidValue? createdById;

  DateTime createdAt;

  DateTime? expiresAt;

  /// Returns a shallow copy of this [SharedEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SharedEvent copyWith({
    int? id,
    String? shareToken,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? startLocation,
    String? transportMode,
    int? travelMinutes,
    int? bufferMinutes,
    DateTime? leaveByTime,
    String? personName,
    _isc.UuidValue? createdById,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SharedEvent',
      if (id != null) 'id': id,
      'shareToken': shareToken,
      'title': title,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      if (location != null) 'location': location,
      if (startLocation != null) 'startLocation': startLocation,
      if (transportMode != null) 'transportMode': transportMode,
      if (travelMinutes != null) 'travelMinutes': travelMinutes,
      if (bufferMinutes != null) 'bufferMinutes': bufferMinutes,
      'leaveByTime': leaveByTime.toJson(),
      if (personName != null) 'personName': personName,
      if (createdById != null) 'createdById': createdById?.toJson(),
      'createdAt': createdAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SharedEvent',
      if (id != null) 'id': id,
      'shareToken': shareToken,
      'title': title,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      if (location != null) 'location': location,
      if (startLocation != null) 'startLocation': startLocation,
      if (transportMode != null) 'transportMode': transportMode,
      if (travelMinutes != null) 'travelMinutes': travelMinutes,
      if (bufferMinutes != null) 'bufferMinutes': bufferMinutes,
      'leaveByTime': leaveByTime.toJson(),
      if (personName != null) 'personName': personName,
      if (createdById != null) 'createdById': createdById?.toJson(),
      'createdAt': createdAt.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SharedEventImpl extends SharedEvent {
  _SharedEventImpl({
    int? id,
    required String shareToken,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? startLocation,
    String? transportMode,
    int? travelMinutes,
    int? bufferMinutes,
    required DateTime leaveByTime,
    String? personName,
    _isc.UuidValue? createdById,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) : super._(
         id: id,
         shareToken: shareToken,
         title: title,
         startTime: startTime,
         endTime: endTime,
         location: location,
         startLocation: startLocation,
         transportMode: transportMode,
         travelMinutes: travelMinutes,
         bufferMinutes: bufferMinutes,
         leaveByTime: leaveByTime,
         personName: personName,
         createdById: createdById,
         createdAt: createdAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [SharedEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SharedEvent copyWith({
    Object? id = _Undefined,
    String? shareToken,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    Object? location = _Undefined,
    Object? startLocation = _Undefined,
    Object? transportMode = _Undefined,
    Object? travelMinutes = _Undefined,
    Object? bufferMinutes = _Undefined,
    DateTime? leaveByTime,
    Object? personName = _Undefined,
    Object? createdById = _Undefined,
    DateTime? createdAt,
    Object? expiresAt = _Undefined,
  }) {
    return SharedEvent(
      id: id is int? ? id : this.id,
      shareToken: shareToken ?? this.shareToken,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location is String? ? location : this.location,
      startLocation: startLocation is String?
          ? startLocation
          : this.startLocation,
      transportMode: transportMode is String?
          ? transportMode
          : this.transportMode,
      travelMinutes: travelMinutes is int? ? travelMinutes : this.travelMinutes,
      bufferMinutes: bufferMinutes is int? ? bufferMinutes : this.bufferMinutes,
      leaveByTime: leaveByTime ?? this.leaveByTime,
      personName: personName is String? ? personName : this.personName,
      createdById: createdById is _isc.UuidValue?
          ? createdById
          : this.createdById,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
    );
  }
}
