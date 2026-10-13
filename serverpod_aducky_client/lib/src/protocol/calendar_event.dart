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

abstract class CalendarEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarEvent._({
    this.id,
    this.userId,
    required this.eventId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.startLocation,
    String? transportMode,
    bool? isDeleted,
  }) : transportMode = transportMode ?? 'driving',
       isDeleted = isDeleted ?? false;

  factory CalendarEvent({
    int? id,
    _isc.UuidValue? userId,
    required String eventId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? startLocation,
    String? transportMode,
    bool? isDeleted,
  }) = _CalendarEventImpl;

  factory CalendarEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEvent(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      eventId: jsonSerialization['eventId'] as String,
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
      isDeleted: jsonSerialization['isDeleted'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isDeleted']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue? userId;

  String eventId;

  String title;

  DateTime startTime;

  DateTime endTime;

  String? location;

  String? startLocation;

  String? transportMode;

  bool isDeleted;

  /// Returns a shallow copy of this [CalendarEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEvent copyWith({
    int? id,
    _isc.UuidValue? userId,
    String? eventId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? startLocation,
    String? transportMode,
    bool? isDeleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CalendarEvent',
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId?.toJson(),
      'eventId': eventId,
      'title': title,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      if (location != null) 'location': location,
      if (startLocation != null) 'startLocation': startLocation,
      if (transportMode != null) 'transportMode': transportMode,
      'isDeleted': isDeleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CalendarEvent',
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId?.toJson(),
      'eventId': eventId,
      'title': title,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      if (location != null) 'location': location,
      if (startLocation != null) 'startLocation': startLocation,
      if (transportMode != null) 'transportMode': transportMode,
      'isDeleted': isDeleted,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventImpl extends CalendarEvent {
  _CalendarEventImpl({
    int? id,
    _isc.UuidValue? userId,
    required String eventId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? startLocation,
    String? transportMode,
    bool? isDeleted,
  }) : super._(
         id: id,
         userId: userId,
         eventId: eventId,
         title: title,
         startTime: startTime,
         endTime: endTime,
         location: location,
         startLocation: startLocation,
         transportMode: transportMode,
         isDeleted: isDeleted,
       );

  /// Returns a shallow copy of this [CalendarEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEvent copyWith({
    Object? id = _Undefined,
    Object? userId = _Undefined,
    String? eventId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    Object? location = _Undefined,
    Object? startLocation = _Undefined,
    Object? transportMode = _Undefined,
    bool? isDeleted,
  }) {
    return CalendarEvent(
      id: id is int? ? id : this.id,
      userId: userId is _isc.UuidValue? ? userId : this.userId,
      eventId: eventId ?? this.eventId,
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
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
