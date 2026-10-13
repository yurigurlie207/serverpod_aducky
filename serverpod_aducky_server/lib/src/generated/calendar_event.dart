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

abstract class CalendarEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
    _is.UuidValue? userId,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      eventId: jsonSerialization['eventId'] as String,
      title: jsonSerialization['title'] as String,
      startTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: _is.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      location: jsonSerialization['location'] as String?,
      startLocation: jsonSerialization['startLocation'] as String?,
      transportMode: jsonSerialization['transportMode'] as String?,
      isDeleted: jsonSerialization['isDeleted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isDeleted']),
    );
  }

  static final t = CalendarEventTable();

  static const db = CalendarEventRepository._();

  @override
  int? id;

  _is.UuidValue? userId;

  String eventId;

  String title;

  DateTime startTime;

  DateTime endTime;

  String? location;

  String? startLocation;

  String? transportMode;

  bool isDeleted;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEvent copyWith({
    int? id,
    _is.UuidValue? userId,
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

  static CalendarEventInclude include() {
    return CalendarEventInclude._();
  }

  static CalendarEventIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventTable>? orderByList,
    CalendarEventInclude? include,
  }) {
    return CalendarEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventImpl extends CalendarEvent {
  _CalendarEventImpl({
    int? id,
    _is.UuidValue? userId,
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
  @_is.useResult
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
      userId: userId is _is.UuidValue? ? userId : this.userId,
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

class CalendarEventUpdateTable extends _is.UpdateTable<CalendarEventTable> {
  CalendarEventUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<String, String> eventId(String value) => _is.ColumnValue(
    table.eventId,
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

  _is.ColumnValue<bool, bool> isDeleted(bool value) => _is.ColumnValue(
    table.isDeleted,
    value,
  );
}

class CalendarEventTable extends _is.Table<int?> {
  CalendarEventTable({super.tableRelation})
    : super(tableName: 'calendar_event') {
    updateTable = CalendarEventUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    eventId = _is.ColumnString(
      'eventId',
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
    isDeleted = _is.ColumnBool(
      'isDeleted',
      this,
      hasDefault: true,
    );
  }

  late final CalendarEventUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnString eventId;

  late final _is.ColumnString title;

  late final _is.ColumnDateTime startTime;

  late final _is.ColumnDateTime endTime;

  late final _is.ColumnString location;

  late final _is.ColumnString startLocation;

  late final _is.ColumnString transportMode;

  late final _is.ColumnBool isDeleted;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    eventId,
    title,
    startTime,
    endTime,
    location,
    startLocation,
    transportMode,
    isDeleted,
  ];
}

class CalendarEventInclude extends _is.IncludeObject {
  CalendarEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarEvent.t;
}

class CalendarEventIncludeList extends _is.IncludeList {
  CalendarEventIncludeList._({
    _is.WhereExpressionBuilder<CalendarEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarEvent.t;
}

class CalendarEventRepository {
  const CalendarEventRepository._();

  /// Returns a list of [CalendarEvent]s matching the given query parameters.
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
  Future<List<CalendarEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarEvent>(
      where: where?.call(CalendarEvent.t),
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarEvent] matching the given query parameters.
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
  Future<CalendarEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarEventTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarEvent>(
      where: where?.call(CalendarEvent.t),
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarEvent] by its [id] or null if no such row exists.
  Future<CalendarEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarEvent]s will have their `id` fields set.
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
  Future<List<CalendarEvent>> insert(
    _is.DatabaseSession session,
    List<CalendarEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarEvent] and returns the inserted row.
  ///
  /// The returned [CalendarEvent] will have its `id` field set.
  Future<CalendarEvent> insertRow(
    _is.DatabaseSession session,
    CalendarEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarEvent]s in the list and returns the resulting rows.
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
  /// The returned [CalendarEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEvent>> upsert(
    _is.DatabaseSession session,
    List<CalendarEvent> rows, {
    required _is.ColumnSelections<CalendarEventTable> conflictColumns,
    _is.ColumnSelections<CalendarEventTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarEvent>(
      rows,
      conflictColumns: conflictColumns(CalendarEvent.t),
      updateColumns: updateColumns?.call(CalendarEvent.t),
      updateWhere: updateWhere?.call(CalendarEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarEvent] and returns the resulting row.
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
  /// The returned [CalendarEvent] will have its `id` field set.
  Future<CalendarEvent?> upsertRow(
    _is.DatabaseSession session,
    CalendarEvent row, {
    required _is.ColumnSelections<CalendarEventTable> conflictColumns,
    _is.ColumnSelections<CalendarEventTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarEvent>(
      row,
      conflictColumns: conflictColumns(CalendarEvent.t),
      updateColumns: updateColumns?.call(CalendarEvent.t),
      updateWhere: updateWhere?.call(CalendarEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEvent>> update(
    _is.DatabaseSession session,
    List<CalendarEvent> rows, {
    _is.ColumnSelections<CalendarEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarEvent>(
      rows,
      columns: columns?.call(CalendarEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarEvent> updateRow(
    _is.DatabaseSession session,
    CalendarEvent row, {
    _is.ColumnSelections<CalendarEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarEvent>(
      row,
      columns: columns?.call(CalendarEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarEvent>(
      id,
      columnValues: columnValues(CalendarEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CalendarEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarEvent>(
      columnValues: columnValues(CalendarEvent.t.updateTable),
      where: where(CalendarEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarEvent]s in the list and returns the deleted rows.
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
  Future<List<CalendarEvent>> delete(
    _is.DatabaseSession session,
    List<CalendarEvent> rows, {
    _is.OrderByBuilder<CalendarEventTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarEvent>(
      rows,
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarEvent].
  Future<CalendarEvent> deleteRow(
    _is.DatabaseSession session,
    CalendarEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarEvent>(
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
  Future<List<CalendarEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarEventTable> where,
    _is.OrderByBuilder<CalendarEventTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarEvent>(
      where: where(CalendarEvent.t),
      orderBy: orderBy?.call(CalendarEvent.t),
      orderByList: orderByList?.call(CalendarEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarEvent>(
      where: where?.call(CalendarEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarEvent>(
      where: where(CalendarEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
