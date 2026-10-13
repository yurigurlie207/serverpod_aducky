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
import 'package:serverpod_aducky_client/src/protocol/protocol.dart'
    as _ill7ex3t;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'calendar_event.dart' as _ix2r355r;

abstract class AiScheduleResponse
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AiScheduleResponse._({
    required this.success,
    required this.summary,
    required this.suggestedEvents,
    required this.actionsTaken,
    required this.apiKeyConfigured,
    this.error,
  });

  factory AiScheduleResponse({
    required bool success,
    required String summary,
    required List<_ix2r355r.CalendarEvent> suggestedEvents,
    required List<String> actionsTaken,
    required bool apiKeyConfigured,
    String? error,
  }) = _AiScheduleResponseImpl;

  factory AiScheduleResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiScheduleResponse(
      success: _isc.BoolJsonExtension.fromJson(jsonSerialization['success']),
      summary: jsonSerialization['summary'] as String,
      suggestedEvents: _ill7ex3t.Protocol()
          .deserialize<List<_ix2r355r.CalendarEvent>>(
            jsonSerialization['suggestedEvents'],
          ),
      actionsTaken: _ill7ex3t.Protocol().deserialize<List<String>>(
        jsonSerialization['actionsTaken'],
      ),
      apiKeyConfigured: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['apiKeyConfigured'],
      ),
      error: jsonSerialization['error'] as String?,
    );
  }

  bool success;

  String summary;

  List<_ix2r355r.CalendarEvent> suggestedEvents;

  List<String> actionsTaken;

  bool apiKeyConfigured;

  String? error;

  /// Returns a shallow copy of this [AiScheduleResponse]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AiScheduleResponse copyWith({
    bool? success,
    String? summary,
    List<_ix2r355r.CalendarEvent>? suggestedEvents,
    List<String>? actionsTaken,
    bool? apiKeyConfigured,
    String? error,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiScheduleResponse',
      'success': success,
      'summary': summary,
      'suggestedEvents': suggestedEvents.toJson(valueToJson: (v) => v.toJson()),
      'actionsTaken': actionsTaken.toJson(),
      'apiKeyConfigured': apiKeyConfigured,
      if (error != null) 'error': error,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AiScheduleResponse',
      'success': success,
      'summary': summary,
      'suggestedEvents': suggestedEvents.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'actionsTaken': actionsTaken.toJson(),
      'apiKeyConfigured': apiKeyConfigured,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiScheduleResponseImpl extends AiScheduleResponse {
  _AiScheduleResponseImpl({
    required bool success,
    required String summary,
    required List<_ix2r355r.CalendarEvent> suggestedEvents,
    required List<String> actionsTaken,
    required bool apiKeyConfigured,
    String? error,
  }) : super._(
         success: success,
         summary: summary,
         suggestedEvents: suggestedEvents,
         actionsTaken: actionsTaken,
         apiKeyConfigured: apiKeyConfigured,
         error: error,
       );

  /// Returns a shallow copy of this [AiScheduleResponse]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AiScheduleResponse copyWith({
    bool? success,
    String? summary,
    List<_ix2r355r.CalendarEvent>? suggestedEvents,
    List<String>? actionsTaken,
    bool? apiKeyConfigured,
    Object? error = _Undefined,
  }) {
    return AiScheduleResponse(
      success: success ?? this.success,
      summary: summary ?? this.summary,
      suggestedEvents:
          suggestedEvents ??
          this.suggestedEvents.map((e0) => e0.copyWith()).toList(),
      actionsTaken: actionsTaken ?? this.actionsTaken.map((e0) => e0).toList(),
      apiKeyConfigured: apiKeyConfigured ?? this.apiKeyConfigured,
      error: error is String? ? error : this.error,
    );
  }
}
