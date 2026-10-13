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

abstract class LocationDetails
    implements _is.SerializableModel, _is.ProtocolSerialization {
  LocationDetails._({
    required this.lat,
    required this.lng,
  });

  factory LocationDetails({
    required double lat,
    required double lng,
  }) = _LocationDetailsImpl;

  factory LocationDetails.fromJson(Map<String, dynamic> jsonSerialization) {
    return LocationDetails(
      lat: (jsonSerialization['lat'] as num).toDouble(),
      lng: (jsonSerialization['lng'] as num).toDouble(),
    );
  }

  double lat;

  double lng;

  /// Returns a shallow copy of this [LocationDetails]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LocationDetails copyWith({
    double? lat,
    double? lng,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LocationDetails',
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LocationDetails',
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _LocationDetailsImpl extends LocationDetails {
  _LocationDetailsImpl({
    required double lat,
    required double lng,
  }) : super._(
         lat: lat,
         lng: lng,
       );

  /// Returns a shallow copy of this [LocationDetails]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LocationDetails copyWith({
    double? lat,
    double? lng,
  }) {
    return LocationDetails(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
