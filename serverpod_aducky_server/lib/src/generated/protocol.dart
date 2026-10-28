/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_aducky_server/src/generated/calendar_event.dart'
    as _iv795s94;
import 'package:serverpod_aducky_server/src/generated/place_suggestion.dart'
    as _i5xrih7u;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'ai_schedule_response.dart' as _ir97sr2u;
import 'calendar_event.dart' as _ix2r355r;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'location_details.dart' as _imw3eshy;
import 'place_suggestion.dart' as _icek8ivy;
import 'shared_event.dart' as _i9kh3b93;
import 'travel_result.dart' as _i4us4l0r;
import 'user_location_profile.dart' as _imb99of0;
export 'ai_schedule_response.dart';
export 'calendar_event.dart';
export 'greetings/greeting.dart';
export 'location_details.dart';
export 'place_suggestion.dart';
export 'shared_event.dart';
export 'travel_result.dart';
export 'user_location_profile.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'calendar_event',
      dartName: 'CalendarEvent',
      schema: 'public',
      module: 'serverpod_aducky',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'eventId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'startTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'endTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'location',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'startLocation',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'transportMode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
          columnDefault: '\'driving\'',
        ),
        _isp.ColumnDefinition(
          name: 'bufferMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'isDeleted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'shared_event',
      dartName: 'SharedEvent',
      schema: 'public',
      module: 'serverpod_aducky',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'shareToken',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'startTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'endTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'location',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'startLocation',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'transportMode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
          columnDefault: '\'driving\'',
        ),
        _isp.ColumnDefinition(
          name: 'travelMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'bufferMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'leaveByTime',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'personName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdById',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'shared_event_token_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'shareToken',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user_location_profile',
      dartName: 'UserLocationProfile',
      schema: 'public',
      module: 'serverpod_aducky',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'homeAddress',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'homeLat',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'homeLng',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'meetingBufferMinutes',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'googleAccessToken',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_location_profile_auth_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ir97sr2u.AiScheduleResponse) {
      return _ir97sr2u.AiScheduleResponse.fromJson(data) as T;
    }
    if (t == _ix2r355r.CalendarEvent) {
      return _ix2r355r.CalendarEvent.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _imw3eshy.LocationDetails) {
      return _imw3eshy.LocationDetails.fromJson(data) as T;
    }
    if (t == _icek8ivy.PlaceSuggestion) {
      return _icek8ivy.PlaceSuggestion.fromJson(data) as T;
    }
    if (t == _i9kh3b93.SharedEvent) {
      return _i9kh3b93.SharedEvent.fromJson(data) as T;
    }
    if (t == _i4us4l0r.TravelResult) {
      return _i4us4l0r.TravelResult.fromJson(data) as T;
    }
    if (t == _imb99of0.UserLocationProfile) {
      return _imb99of0.UserLocationProfile.fromJson(data) as T;
    }
    if (t == _is.getType<_ir97sr2u.AiScheduleResponse?>()) {
      return (data != null ? _ir97sr2u.AiScheduleResponse.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ix2r355r.CalendarEvent?>()) {
      return (data != null ? _ix2r355r.CalendarEvent.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_imw3eshy.LocationDetails?>()) {
      return (data != null ? _imw3eshy.LocationDetails.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icek8ivy.PlaceSuggestion?>()) {
      return (data != null ? _icek8ivy.PlaceSuggestion.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9kh3b93.SharedEvent?>()) {
      return (data != null ? _i9kh3b93.SharedEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4us4l0r.TravelResult?>()) {
      return (data != null ? _i4us4l0r.TravelResult.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_imb99of0.UserLocationProfile?>()) {
      return (data != null
              ? _imb99of0.UserLocationProfile.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_ix2r355r.CalendarEvent>) {
      return (data as List)
              .map((e) => deserialize<_ix2r355r.CalendarEvent>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_iv795s94.CalendarEvent>) {
      return (data as List)
              .map((e) => deserialize<_iv795s94.CalendarEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_i5xrih7u.PlaceSuggestion>) {
      return (data as List)
              .map((e) => deserialize<_i5xrih7u.PlaceSuggestion>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ir97sr2u.AiScheduleResponse => 'AiScheduleResponse',
      _ix2r355r.CalendarEvent => 'CalendarEvent',
      _izw8z7ou.Greeting => 'Greeting',
      _imw3eshy.LocationDetails => 'LocationDetails',
      _icek8ivy.PlaceSuggestion => 'PlaceSuggestion',
      _i9kh3b93.SharedEvent => 'SharedEvent',
      _i4us4l0r.TravelResult => 'TravelResult',
      _imb99of0.UserLocationProfile => 'UserLocationProfile',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'serverpod_aducky.',
        '',
      );
    }

    switch (data) {
      case _ir97sr2u.AiScheduleResponse():
        return 'AiScheduleResponse';
      case _ix2r355r.CalendarEvent():
        return 'CalendarEvent';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _imw3eshy.LocationDetails():
        return 'LocationDetails';
      case _icek8ivy.PlaceSuggestion():
        return 'PlaceSuggestion';
      case _i9kh3b93.SharedEvent():
        return 'SharedEvent';
      case _i4us4l0r.TravelResult():
        return 'TravelResult';
      case _imb99of0.UserLocationProfile():
        return 'UserLocationProfile';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AiScheduleResponse') {
      return deserialize<_ir97sr2u.AiScheduleResponse>(data['data']);
    }
    if (dataClassName == 'CalendarEvent') {
      return deserialize<_ix2r355r.CalendarEvent>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'LocationDetails') {
      return deserialize<_imw3eshy.LocationDetails>(data['data']);
    }
    if (dataClassName == 'PlaceSuggestion') {
      return deserialize<_icek8ivy.PlaceSuggestion>(data['data']);
    }
    if (dataClassName == 'SharedEvent') {
      return deserialize<_i9kh3b93.SharedEvent>(data['data']);
    }
    if (dataClassName == 'TravelResult') {
      return deserialize<_i4us4l0r.TravelResult>(data['data']);
    }
    if (dataClassName == 'UserLocationProfile') {
      return deserialize<_imb99of0.UserLocationProfile>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('serverpod_aducky', this);
    _iacs.Protocol().registerHostProtocol('serverpod_aducky', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ix2r355r.CalendarEvent:
        return _ix2r355r.CalendarEvent.t;
      case _i9kh3b93.SharedEvent:
        return _i9kh3b93.SharedEvent.t;
      case _imb99of0.UserLocationProfile:
        return _imb99of0.UserLocationProfile.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'serverpod_aducky';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
