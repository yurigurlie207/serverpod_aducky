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

abstract class SharedEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
    _is.UuidValue? createdById,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) = _SharedEventImpl;

  factory SharedEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return SharedEvent(
      id: jsonSerialization['id'] as int?,
      shareToken: jsonSerialization['shareToken'] as String,
      title: jsonSerialization['title'] as String,
      startTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: _is.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      location: jsonSerialization['location'] as String?,
      startLocation: jsonSerialization['startLocation'] as String?,
      transportMode: jsonSerialization['transportMode'] as String?,
      travelMinutes: jsonSerialization['travelMinutes'] as int?,
      bufferMinutes: jsonSerialization['bufferMinutes'] as int?,
      leaveByTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['leaveByTime'],
      ),
      personName: jsonSerialization['personName'] as String?,
      createdById: jsonSerialization['createdById'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdById'],
            ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
    );
  }

  static final t = SharedEventTable();

  static const db = SharedEventRepository._();

  @override
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

  _is.UuidValue? createdById;

  DateTime createdAt;

  DateTime? expiresAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SharedEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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
    _is.UuidValue? createdById,
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

  static SharedEventInclude include() {
    return SharedEventInclude._();
  }

  static SharedEventIncludeList includeList({
    _is.WhereExpressionBuilder<SharedEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SharedEventTable>? orderBy,
    _is.OrderByListBuilder<SharedEventTable>? orderByList,
    SharedEventInclude? include,
  }) {
    return SharedEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SharedEvent.t),
      orderByList: orderByList?.call(SharedEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
    _is.UuidValue? createdById,
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
  @_is.useResult
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
      createdById: createdById is _is.UuidValue?
          ? createdById
          : this.createdById,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
    );
  }
}

class SharedEventUpdateTable extends _is.UpdateTable<SharedEventTable> {
  SharedEventUpdateTable(super.table);

  _is.ColumnValue<String, String> shareToken(String value) => _is.ColumnValue(
    table.shareToken,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> startTime(DateTime value) =>
      _is.ColumnValue(
        table.startTime,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> endTime(DateTime value) =>
      _is.ColumnValue(
        table.endTime,
        value,
      );

  _is.ColumnValue<String, String> location(String? value) => _is.ColumnValue(
    table.location,
    value,
  );

  _is.ColumnValue<String, String> startLocation(String? value) =>
      _is.ColumnValue(
        table.startLocation,
        value,
      );

  _is.ColumnValue<String, String> transportMode(String? value) =>
      _is.ColumnValue(
        table.transportMode,
        value,
      );

  _is.ColumnValue<int, int> travelMinutes(int? value) => _is.ColumnValue(
    table.travelMinutes,
    value,
  );

  _is.ColumnValue<int, int> bufferMinutes(int? value) => _is.ColumnValue(
    table.bufferMinutes,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leaveByTime(DateTime value) =>
      _is.ColumnValue(
        table.leaveByTime,
        value,
      );

  _is.ColumnValue<String, String> personName(String? value) => _is.ColumnValue(
    table.personName,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> createdById(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.createdById,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime? value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class SharedEventTable extends _is.Table<int?> {
  SharedEventTable({super.tableRelation}) : super(tableName: 'shared_event') {
    updateTable = SharedEventUpdateTable(this);
    shareToken = _is.ColumnString(
      'shareToken',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    startTime = _is.ColumnDateTime(
      'startTime',
      this,
    );
    endTime = _is.ColumnDateTime(
      'endTime',
      this,
    );
    location = _is.ColumnString(
      'location',
      this,
    );
    startLocation = _is.ColumnString(
      'startLocation',
      this,
    );
    transportMode = _is.ColumnString(
      'transportMode',
      this,
      hasDefault: true,
    );
    travelMinutes = _is.ColumnInt(
      'travelMinutes',
      this,
      hasDefault: true,
    );
    bufferMinutes = _is.ColumnInt(
      'bufferMinutes',
      this,
      hasDefault: true,
    );
    leaveByTime = _is.ColumnDateTime(
      'leaveByTime',
      this,
    );
    personName = _is.ColumnString(
      'personName',
      this,
    );
    createdById = _is.ColumnUuid(
      'createdById',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final SharedEventUpdateTable updateTable;

  late final _is.ColumnString shareToken;

  late final _is.ColumnString title;

  late final _is.ColumnDateTime startTime;

  late final _is.ColumnDateTime endTime;

  late final _is.ColumnString location;

  late final _is.ColumnString startLocation;

  late final _is.ColumnString transportMode;

  late final _is.ColumnInt travelMinutes;

  late final _is.ColumnInt bufferMinutes;

  late final _is.ColumnDateTime leaveByTime;

  late final _is.ColumnString personName;

  late final _is.ColumnUuid createdById;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    shareToken,
    title,
    startTime,
    endTime,
    location,
    startLocation,
    transportMode,
    travelMinutes,
    bufferMinutes,
    leaveByTime,
    personName,
    createdById,
    createdAt,
    expiresAt,
  ];
}

class SharedEventInclude extends _is.IncludeObject {
  SharedEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SharedEvent.t;
}

class SharedEventIncludeList extends _is.IncludeList {
  SharedEventIncludeList._({
    _is.WhereExpressionBuilder<SharedEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SharedEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SharedEvent.t;
}

class SharedEventRepository {
  const SharedEventRepository._();

  /// Returns a list of [SharedEvent]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<SharedEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SharedEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SharedEventTable>? orderBy,
    _is.OrderByListBuilder<SharedEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SharedEvent>(
      where: where?.call(SharedEvent.t),
      orderBy: orderBy?.call(SharedEvent.t),
      orderByList: orderByList?.call(SharedEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SharedEvent] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<SharedEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SharedEventTable>? where,
    int? offset,
    _is.OrderByBuilder<SharedEventTable>? orderBy,
    _is.OrderByListBuilder<SharedEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SharedEvent>(
      where: where?.call(SharedEvent.t),
      orderBy: orderBy?.call(SharedEvent.t),
      orderByList: orderByList?.call(SharedEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SharedEvent] by its [id] or null if no such row exists.
  Future<SharedEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SharedEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SharedEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [SharedEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedEvent>> insert(
    _is.DatabaseSession session,
    List<SharedEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SharedEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SharedEvent] and returns the inserted row.
  ///
  /// The returned [SharedEvent] will have its `id` field set.
  Future<SharedEvent> insertRow(
    _is.DatabaseSession session,
    SharedEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SharedEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SharedEvent]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [SharedEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedEvent>> upsert(
    _is.DatabaseSession session,
    List<SharedEvent> rows, {
    required _is.ColumnSelections<SharedEventTable> conflictColumns,
    _is.ColumnSelections<SharedEventTable>? updateColumns,
    _is.WhereExpressionBuilder<SharedEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SharedEvent>(
      rows,
      conflictColumns: conflictColumns(SharedEvent.t),
      updateColumns: updateColumns?.call(SharedEvent.t),
      updateWhere: updateWhere?.call(SharedEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SharedEvent] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [SharedEvent] will have its `id` field set.
  Future<SharedEvent?> upsertRow(
    _is.DatabaseSession session,
    SharedEvent row, {
    required _is.ColumnSelections<SharedEventTable> conflictColumns,
    _is.ColumnSelections<SharedEventTable>? updateColumns,
    _is.WhereExpressionBuilder<SharedEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SharedEvent>(
      row,
      conflictColumns: conflictColumns(SharedEvent.t),
      updateColumns: updateColumns?.call(SharedEvent.t),
      updateWhere: updateWhere?.call(SharedEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [SharedEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedEvent>> update(
    _is.DatabaseSession session,
    List<SharedEvent> rows, {
    _is.ColumnSelections<SharedEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SharedEvent>(
      rows,
      columns: columns?.call(SharedEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SharedEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SharedEvent> updateRow(
    _is.DatabaseSession session,
    SharedEvent row, {
    _is.ColumnSelections<SharedEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SharedEvent>(
      row,
      columns: columns?.call(SharedEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SharedEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SharedEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SharedEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SharedEvent>(
      id,
      columnValues: columnValues(SharedEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SharedEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SharedEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SharedEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SharedEventTable>? orderBy,
    _is.OrderByListBuilder<SharedEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SharedEvent>(
      columnValues: columnValues(SharedEvent.t.updateTable),
      where: where(SharedEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SharedEvent.t),
      orderByList: orderByList?.call(SharedEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SharedEvent]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedEvent>> delete(
    _is.DatabaseSession session,
    List<SharedEvent> rows, {
    _is.OrderByBuilder<SharedEventTable>? orderBy,
    _is.OrderByListBuilder<SharedEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SharedEvent>(
      rows,
      orderBy: orderBy?.call(SharedEvent.t),
      orderByList: orderByList?.call(SharedEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SharedEvent].
  Future<SharedEvent> deleteRow(
    _is.DatabaseSession session,
    SharedEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SharedEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SharedEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SharedEventTable> where,
    _is.OrderByBuilder<SharedEventTable>? orderBy,
    _is.OrderByListBuilder<SharedEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SharedEvent>(
      where: where(SharedEvent.t),
      orderBy: orderBy?.call(SharedEvent.t),
      orderByList: orderByList?.call(SharedEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SharedEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SharedEvent>(
      where: where?.call(SharedEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SharedEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SharedEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SharedEvent>(
      where: where(SharedEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
