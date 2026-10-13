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

abstract class UserLocationProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
    required _is.UuidValue authUserId,
    required String homeAddress,
    required double homeLat,
    required double homeLng,
    int? meetingBufferMinutes,
    String? googleAccessToken,
  }) = _UserLocationProfileImpl;

  factory UserLocationProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserLocationProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      homeAddress: jsonSerialization['homeAddress'] as String,
      homeLat: (jsonSerialization['homeLat'] as num).toDouble(),
      homeLng: (jsonSerialization['homeLng'] as num).toDouble(),
      meetingBufferMinutes: jsonSerialization['meetingBufferMinutes'] as int?,
      googleAccessToken: jsonSerialization['googleAccessToken'] as String?,
    );
  }

  static final t = UserLocationProfileTable();

  static const db = UserLocationProfileRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  String homeAddress;

  double homeLat;

  double homeLng;

  int? meetingBufferMinutes;

  String? googleAccessToken;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserLocationProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UserLocationProfile copyWith({
    int? id,
    _is.UuidValue? authUserId,
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

  static UserLocationProfileInclude include() {
    return UserLocationProfileInclude._();
  }

  static UserLocationProfileIncludeList includeList({
    _is.WhereExpressionBuilder<UserLocationProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserLocationProfileTable>? orderBy,
    _is.OrderByListBuilder<UserLocationProfileTable>? orderByList,
    UserLocationProfileInclude? include,
  }) {
    return UserLocationProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserLocationProfile.t),
      orderByList: orderByList?.call(UserLocationProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserLocationProfileImpl extends UserLocationProfile {
  _UserLocationProfileImpl({
    int? id,
    required _is.UuidValue authUserId,
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
  @_is.useResult
  @override
  UserLocationProfile copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
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

class UserLocationProfileUpdateTable
    extends _is.UpdateTable<UserLocationProfileTable> {
  UserLocationProfileUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> homeAddress(String value) => _is.ColumnValue(
    table.homeAddress,
    value,
  );

  _is.ColumnValue<double, double> homeLat(double value) => _is.ColumnValue(
    table.homeLat,
    value,
  );

  _is.ColumnValue<double, double> homeLng(double value) => _is.ColumnValue(
    table.homeLng,
    value,
  );

  _is.ColumnValue<int, int> meetingBufferMinutes(int? value) => _is.ColumnValue(
    table.meetingBufferMinutes,
    value,
  );

  _is.ColumnValue<String, String> googleAccessToken(String? value) =>
      _is.ColumnValue(
        table.googleAccessToken,
        value,
      );
}

class UserLocationProfileTable extends _is.Table<int?> {
  UserLocationProfileTable({super.tableRelation})
    : super(tableName: 'user_location_profile') {
    updateTable = UserLocationProfileUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    homeAddress = _is.ColumnString(
      'homeAddress',
      this,
    );
    homeLat = _is.ColumnDouble(
      'homeLat',
      this,
    );
    homeLng = _is.ColumnDouble(
      'homeLng',
      this,
    );
    meetingBufferMinutes = _is.ColumnInt(
      'meetingBufferMinutes',
      this,
      hasDefault: true,
    );
    googleAccessToken = _is.ColumnString(
      'googleAccessToken',
      this,
    );
  }

  late final UserLocationProfileUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString homeAddress;

  late final _is.ColumnDouble homeLat;

  late final _is.ColumnDouble homeLng;

  late final _is.ColumnInt meetingBufferMinutes;

  late final _is.ColumnString googleAccessToken;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    homeAddress,
    homeLat,
    homeLng,
    meetingBufferMinutes,
    googleAccessToken,
  ];
}

class UserLocationProfileInclude extends _is.IncludeObject {
  UserLocationProfileInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => UserLocationProfile.t;
}

class UserLocationProfileIncludeList extends _is.IncludeList {
  UserLocationProfileIncludeList._({
    _is.WhereExpressionBuilder<UserLocationProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserLocationProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => UserLocationProfile.t;
}

class UserLocationProfileRepository {
  const UserLocationProfileRepository._();

  /// Returns a list of [UserLocationProfile]s matching the given query parameters.
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
  Future<List<UserLocationProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserLocationProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserLocationProfileTable>? orderBy,
    _is.OrderByListBuilder<UserLocationProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserLocationProfile>(
      where: where?.call(UserLocationProfile.t),
      orderBy: orderBy?.call(UserLocationProfile.t),
      orderByList: orderByList?.call(UserLocationProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserLocationProfile] matching the given query parameters.
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
  Future<UserLocationProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserLocationProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<UserLocationProfileTable>? orderBy,
    _is.OrderByListBuilder<UserLocationProfileTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserLocationProfile>(
      where: where?.call(UserLocationProfile.t),
      orderBy: orderBy?.call(UserLocationProfile.t),
      orderByList: orderByList?.call(UserLocationProfile.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserLocationProfile] by its [id] or null if no such row exists.
  Future<UserLocationProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserLocationProfile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserLocationProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [UserLocationProfile]s will have their `id` fields set.
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
  Future<List<UserLocationProfile>> insert(
    _is.DatabaseSession session,
    List<UserLocationProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<UserLocationProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [UserLocationProfile] and returns the inserted row.
  ///
  /// The returned [UserLocationProfile] will have its `id` field set.
  Future<UserLocationProfile> insertRow(
    _is.DatabaseSession session,
    UserLocationProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserLocationProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [UserLocationProfile]s in the list and returns the resulting rows.
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
  /// The returned [UserLocationProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserLocationProfile>> upsert(
    _is.DatabaseSession session,
    List<UserLocationProfile> rows, {
    required _is.ColumnSelections<UserLocationProfileTable> conflictColumns,
    _is.ColumnSelections<UserLocationProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<UserLocationProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<UserLocationProfile>(
      rows,
      conflictColumns: conflictColumns(UserLocationProfile.t),
      updateColumns: updateColumns?.call(UserLocationProfile.t),
      updateWhere: updateWhere?.call(UserLocationProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [UserLocationProfile] and returns the resulting row.
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
  /// The returned [UserLocationProfile] will have its `id` field set.
  Future<UserLocationProfile?> upsertRow(
    _is.DatabaseSession session,
    UserLocationProfile row, {
    required _is.ColumnSelections<UserLocationProfileTable> conflictColumns,
    _is.ColumnSelections<UserLocationProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<UserLocationProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<UserLocationProfile>(
      row,
      conflictColumns: conflictColumns(UserLocationProfile.t),
      updateColumns: updateColumns?.call(UserLocationProfile.t),
      updateWhere: updateWhere?.call(UserLocationProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [UserLocationProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserLocationProfile>> update(
    _is.DatabaseSession session,
    List<UserLocationProfile> rows, {
    _is.ColumnSelections<UserLocationProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<UserLocationProfile>(
      rows,
      columns: columns?.call(UserLocationProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [UserLocationProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserLocationProfile> updateRow(
    _is.DatabaseSession session,
    UserLocationProfile row, {
    _is.ColumnSelections<UserLocationProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserLocationProfile>(
      row,
      columns: columns?.call(UserLocationProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserLocationProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserLocationProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<UserLocationProfileUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<UserLocationProfile>(
      id,
      columnValues: columnValues(UserLocationProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserLocationProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserLocationProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UserLocationProfileUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<UserLocationProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserLocationProfileTable>? orderBy,
    _is.OrderByListBuilder<UserLocationProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<UserLocationProfile>(
      columnValues: columnValues(UserLocationProfile.t.updateTable),
      where: where(UserLocationProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserLocationProfile.t),
      orderByList: orderByList?.call(UserLocationProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [UserLocationProfile]s in the list and returns the deleted rows.
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
  Future<List<UserLocationProfile>> delete(
    _is.DatabaseSession session,
    List<UserLocationProfile> rows, {
    _is.OrderByBuilder<UserLocationProfileTable>? orderBy,
    _is.OrderByListBuilder<UserLocationProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<UserLocationProfile>(
      rows,
      orderBy: orderBy?.call(UserLocationProfile.t),
      orderByList: orderByList?.call(UserLocationProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [UserLocationProfile].
  Future<UserLocationProfile> deleteRow(
    _is.DatabaseSession session,
    UserLocationProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserLocationProfile>(
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
  Future<List<UserLocationProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserLocationProfileTable> where,
    _is.OrderByBuilder<UserLocationProfileTable>? orderBy,
    _is.OrderByListBuilder<UserLocationProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<UserLocationProfile>(
      where: where(UserLocationProfile.t),
      orderBy: orderBy?.call(UserLocationProfile.t),
      orderByList: orderByList?.call(UserLocationProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserLocationProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<UserLocationProfile>(
      where: where?.call(UserLocationProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserLocationProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserLocationProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserLocationProfile>(
      where: where(UserLocationProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
