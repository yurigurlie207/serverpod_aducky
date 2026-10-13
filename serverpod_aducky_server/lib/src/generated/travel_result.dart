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
import 'package:serverpod/serverpod.dart' as _is;

abstract class TravelResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TravelResult._({
    required this.durationMinutes,
    required this.distanceText,
    required this.weatherBufferMinutes,
    required this.totalMinutes,
  });

  factory TravelResult({
    required int durationMinutes,
    required String distanceText,
    required int weatherBufferMinutes,
    required int totalMinutes,
  }) = _TravelResultImpl;

  factory TravelResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return TravelResult(
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      distanceText: jsonSerialization['distanceText'] as String,
      weatherBufferMinutes: jsonSerialization['weatherBufferMinutes'] as int,
      totalMinutes: jsonSerialization['totalMinutes'] as int,
    );
  }

  int durationMinutes;

  String distanceText;

  int weatherBufferMinutes;

  int totalMinutes;

  /// Returns a shallow copy of this [TravelResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TravelResult copyWith({
    int? durationMinutes,
    String? distanceText,
    int? weatherBufferMinutes,
    int? totalMinutes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TravelResult',
      'durationMinutes': durationMinutes,
      'distanceText': distanceText,
      'weatherBufferMinutes': weatherBufferMinutes,
      'totalMinutes': totalMinutes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TravelResult',
      'durationMinutes': durationMinutes,
      'distanceText': distanceText,
      'weatherBufferMinutes': weatherBufferMinutes,
      'totalMinutes': totalMinutes,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TravelResultImpl extends TravelResult {
  _TravelResultImpl({
    required int durationMinutes,
    required String distanceText,
    required int weatherBufferMinutes,
    required int totalMinutes,
  }) : super._(
         durationMinutes: durationMinutes,
         distanceText: distanceText,
         weatherBufferMinutes: weatherBufferMinutes,
         totalMinutes: totalMinutes,
       );

  /// Returns a shallow copy of this [TravelResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TravelResult copyWith({
    int? durationMinutes,
    String? distanceText,
    int? weatherBufferMinutes,
    int? totalMinutes,
  }) {
    return TravelResult(
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceText: distanceText ?? this.distanceText,
      weatherBufferMinutes: weatherBufferMinutes ?? this.weatherBufferMinutes,
      totalMinutes: totalMinutes ?? this.totalMinutes,
    );
  }
}
