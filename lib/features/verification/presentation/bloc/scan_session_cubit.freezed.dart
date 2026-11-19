// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_session_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScanSessionState {

 String? get id; InputFormats? get formats; SessionTotals? get totals; LookupResult? get latest; CheckedInput? get checked; bool get repeat;/// The session was another official's (`409 session_not_yours`): a new
/// one started; the screen says so once (guide section 4.3).
 bool get restarted;/// A resumed session's scans could not be read: Try again reloads them
/// (guide section 4.6); scanning goes on meanwhile.
 bool get rowsFailed;/// A saved session was taken up again; without its totals (no
/// `history:own`) the counters wait for the next scan's answer instead
/// of showing zeros.
 bool get resumed;/// Reads waiting behind the one being checked.
 int get pending;/// Reads let go when a scan failed: they were not checked and must be
/// scanned again (guide section 4.6: nothing is queued for later).
 int get notChecked;/// Goes up with every answered scan, so each answer is announced, even
/// two equal ones in a row.
 int get answered;/// After a `429` on loading those scans: not asked again before this.
 DateTime? get rowsRetryAt; bool get loading; bool get busy; bool get paused; bool get loadingMore; List<RecoveredScan> get rows; String? get nextCursor; Failure? get failure; DateTime? get retryAt;
/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanSessionStateCopyWith<ScanSessionState> get copyWith => _$ScanSessionStateCopyWithImpl<ScanSessionState>(this as ScanSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanSessionState&&(identical(other.id, id) || other.id == id)&&(identical(other.formats, formats) || other.formats == formats)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.latest, latest) || other.latest == latest)&&(identical(other.checked, checked) || other.checked == checked)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.restarted, restarted) || other.restarted == restarted)&&(identical(other.rowsFailed, rowsFailed) || other.rowsFailed == rowsFailed)&&(identical(other.resumed, resumed) || other.resumed == resumed)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.notChecked, notChecked) || other.notChecked == notChecked)&&(identical(other.answered, answered) || other.answered == answered)&&(identical(other.rowsRetryAt, rowsRetryAt) || other.rowsRetryAt == rowsRetryAt)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&const DeepCollectionEquality().equals(other.rows, rows)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,formats,totals,latest,checked,repeat,restarted,rowsFailed,resumed,pending,notChecked,answered,rowsRetryAt,loading,busy,paused,loadingMore,const DeepCollectionEquality().hash(rows),nextCursor,failure,retryAt]);

@override
String toString() {
  return 'ScanSessionState(id: $id, formats: $formats, totals: $totals, latest: $latest, checked: $checked, repeat: $repeat, restarted: $restarted, rowsFailed: $rowsFailed, resumed: $resumed, pending: $pending, notChecked: $notChecked, answered: $answered, rowsRetryAt: $rowsRetryAt, loading: $loading, busy: $busy, paused: $paused, loadingMore: $loadingMore, rows: $rows, nextCursor: $nextCursor, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class $ScanSessionStateCopyWith<$Res>  {
  factory $ScanSessionStateCopyWith(ScanSessionState value, $Res Function(ScanSessionState) _then) = _$ScanSessionStateCopyWithImpl;
@useResult
$Res call({
 String? id, InputFormats? formats, SessionTotals? totals, LookupResult? latest, CheckedInput? checked, bool repeat, bool restarted, bool rowsFailed, bool resumed, int pending, int notChecked, int answered, DateTime? rowsRetryAt, bool loading, bool busy, bool paused, bool loadingMore, List<RecoveredScan> rows, String? nextCursor, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class _$ScanSessionStateCopyWithImpl<$Res>
    implements $ScanSessionStateCopyWith<$Res> {
  _$ScanSessionStateCopyWithImpl(this._self, this._then);

  final ScanSessionState _self;
  final $Res Function(ScanSessionState) _then;

/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? formats = freezed,Object? totals = freezed,Object? latest = freezed,Object? checked = freezed,Object? repeat = null,Object? restarted = null,Object? rowsFailed = null,Object? resumed = null,Object? pending = null,Object? notChecked = null,Object? answered = null,Object? rowsRetryAt = freezed,Object? loading = null,Object? busy = null,Object? paused = null,Object? loadingMore = null,Object? rows = null,Object? nextCursor = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,formats: freezed == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as InputFormats?,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as SessionTotals?,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as LookupResult?,checked: freezed == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as CheckedInput?,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as bool,restarted: null == restarted ? _self.restarted : restarted // ignore: cast_nullable_to_non_nullable
as bool,rowsFailed: null == rowsFailed ? _self.rowsFailed : rowsFailed // ignore: cast_nullable_to_non_nullable
as bool,resumed: null == resumed ? _self.resumed : resumed // ignore: cast_nullable_to_non_nullable
as bool,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,notChecked: null == notChecked ? _self.notChecked : notChecked // ignore: cast_nullable_to_non_nullable
as int,answered: null == answered ? _self.answered : answered // ignore: cast_nullable_to_non_nullable
as int,rowsRetryAt: freezed == rowsRetryAt ? _self.rowsRetryAt : rowsRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<RecoveredScan>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScanSessionState].
extension ScanSessionStatePatterns on ScanSessionState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanSessionState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanSessionState value)  $default,){
final _that = this;
switch (_that) {
case _ScanSessionState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _ScanSessionState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  InputFormats? formats,  SessionTotals? totals,  LookupResult? latest,  CheckedInput? checked,  bool repeat,  bool restarted,  bool rowsFailed,  bool resumed,  int pending,  int notChecked,  int answered,  DateTime? rowsRetryAt,  bool loading,  bool busy,  bool paused,  bool loadingMore,  List<RecoveredScan> rows,  String? nextCursor,  Failure? failure,  DateTime? retryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanSessionState() when $default != null:
return $default(_that.id,_that.formats,_that.totals,_that.latest,_that.checked,_that.repeat,_that.restarted,_that.rowsFailed,_that.resumed,_that.pending,_that.notChecked,_that.answered,_that.rowsRetryAt,_that.loading,_that.busy,_that.paused,_that.loadingMore,_that.rows,_that.nextCursor,_that.failure,_that.retryAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  InputFormats? formats,  SessionTotals? totals,  LookupResult? latest,  CheckedInput? checked,  bool repeat,  bool restarted,  bool rowsFailed,  bool resumed,  int pending,  int notChecked,  int answered,  DateTime? rowsRetryAt,  bool loading,  bool busy,  bool paused,  bool loadingMore,  List<RecoveredScan> rows,  String? nextCursor,  Failure? failure,  DateTime? retryAt)  $default,) {final _that = this;
switch (_that) {
case _ScanSessionState():
return $default(_that.id,_that.formats,_that.totals,_that.latest,_that.checked,_that.repeat,_that.restarted,_that.rowsFailed,_that.resumed,_that.pending,_that.notChecked,_that.answered,_that.rowsRetryAt,_that.loading,_that.busy,_that.paused,_that.loadingMore,_that.rows,_that.nextCursor,_that.failure,_that.retryAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  InputFormats? formats,  SessionTotals? totals,  LookupResult? latest,  CheckedInput? checked,  bool repeat,  bool restarted,  bool rowsFailed,  bool resumed,  int pending,  int notChecked,  int answered,  DateTime? rowsRetryAt,  bool loading,  bool busy,  bool paused,  bool loadingMore,  List<RecoveredScan> rows,  String? nextCursor,  Failure? failure,  DateTime? retryAt)?  $default,) {final _that = this;
switch (_that) {
case _ScanSessionState() when $default != null:
return $default(_that.id,_that.formats,_that.totals,_that.latest,_that.checked,_that.repeat,_that.restarted,_that.rowsFailed,_that.resumed,_that.pending,_that.notChecked,_that.answered,_that.rowsRetryAt,_that.loading,_that.busy,_that.paused,_that.loadingMore,_that.rows,_that.nextCursor,_that.failure,_that.retryAt);case _:
  return null;

}
}

}

/// @nodoc


class _ScanSessionState implements ScanSessionState {
  const _ScanSessionState({this.id, this.formats, this.totals, this.latest, this.checked, this.repeat = false, this.restarted = false, this.rowsFailed = false, this.resumed = false, this.pending = 0, this.notChecked = 0, this.answered = 0, this.rowsRetryAt, this.loading = true, this.busy = false, this.paused = false, this.loadingMore = false, final  List<RecoveredScan> rows = const <RecoveredScan>[], this.nextCursor, this.failure, this.retryAt}): _rows = rows;
  

@override final  String? id;
@override final  InputFormats? formats;
@override final  SessionTotals? totals;
@override final  LookupResult? latest;
@override final  CheckedInput? checked;
@override@JsonKey() final  bool repeat;
/// The session was another official's (`409 session_not_yours`): a new
/// one started; the screen says so once (guide section 4.3).
@override@JsonKey() final  bool restarted;
/// A resumed session's scans could not be read: Try again reloads them
/// (guide section 4.6); scanning goes on meanwhile.
@override@JsonKey() final  bool rowsFailed;
/// A saved session was taken up again; without its totals (no
/// `history:own`) the counters wait for the next scan's answer instead
/// of showing zeros.
@override@JsonKey() final  bool resumed;
/// Reads waiting behind the one being checked.
@override@JsonKey() final  int pending;
/// Reads let go when a scan failed: they were not checked and must be
/// scanned again (guide section 4.6: nothing is queued for later).
@override@JsonKey() final  int notChecked;
/// Goes up with every answered scan, so each answer is announced, even
/// two equal ones in a row.
@override@JsonKey() final  int answered;
/// After a `429` on loading those scans: not asked again before this.
@override final  DateTime? rowsRetryAt;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool paused;
@override@JsonKey() final  bool loadingMore;
 final  List<RecoveredScan> _rows;
@override@JsonKey() List<RecoveredScan> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

@override final  String? nextCursor;
@override final  Failure? failure;
@override final  DateTime? retryAt;

/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanSessionStateCopyWith<_ScanSessionState> get copyWith => __$ScanSessionStateCopyWithImpl<_ScanSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanSessionState&&(identical(other.id, id) || other.id == id)&&(identical(other.formats, formats) || other.formats == formats)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.latest, latest) || other.latest == latest)&&(identical(other.checked, checked) || other.checked == checked)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.restarted, restarted) || other.restarted == restarted)&&(identical(other.rowsFailed, rowsFailed) || other.rowsFailed == rowsFailed)&&(identical(other.resumed, resumed) || other.resumed == resumed)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.notChecked, notChecked) || other.notChecked == notChecked)&&(identical(other.answered, answered) || other.answered == answered)&&(identical(other.rowsRetryAt, rowsRetryAt) || other.rowsRetryAt == rowsRetryAt)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&const DeepCollectionEquality().equals(other._rows, _rows)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,formats,totals,latest,checked,repeat,restarted,rowsFailed,resumed,pending,notChecked,answered,rowsRetryAt,loading,busy,paused,loadingMore,const DeepCollectionEquality().hash(_rows),nextCursor,failure,retryAt]);

@override
String toString() {
  return 'ScanSessionState(id: $id, formats: $formats, totals: $totals, latest: $latest, checked: $checked, repeat: $repeat, restarted: $restarted, rowsFailed: $rowsFailed, resumed: $resumed, pending: $pending, notChecked: $notChecked, answered: $answered, rowsRetryAt: $rowsRetryAt, loading: $loading, busy: $busy, paused: $paused, loadingMore: $loadingMore, rows: $rows, nextCursor: $nextCursor, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class _$ScanSessionStateCopyWith<$Res> implements $ScanSessionStateCopyWith<$Res> {
  factory _$ScanSessionStateCopyWith(_ScanSessionState value, $Res Function(_ScanSessionState) _then) = __$ScanSessionStateCopyWithImpl;
@override @useResult
$Res call({
 String? id, InputFormats? formats, SessionTotals? totals, LookupResult? latest, CheckedInput? checked, bool repeat, bool restarted, bool rowsFailed, bool resumed, int pending, int notChecked, int answered, DateTime? rowsRetryAt, bool loading, bool busy, bool paused, bool loadingMore, List<RecoveredScan> rows, String? nextCursor, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class __$ScanSessionStateCopyWithImpl<$Res>
    implements _$ScanSessionStateCopyWith<$Res> {
  __$ScanSessionStateCopyWithImpl(this._self, this._then);

  final _ScanSessionState _self;
  final $Res Function(_ScanSessionState) _then;

/// Create a copy of ScanSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? formats = freezed,Object? totals = freezed,Object? latest = freezed,Object? checked = freezed,Object? repeat = null,Object? restarted = null,Object? rowsFailed = null,Object? resumed = null,Object? pending = null,Object? notChecked = null,Object? answered = null,Object? rowsRetryAt = freezed,Object? loading = null,Object? busy = null,Object? paused = null,Object? loadingMore = null,Object? rows = null,Object? nextCursor = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_ScanSessionState(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,formats: freezed == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as InputFormats?,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as SessionTotals?,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as LookupResult?,checked: freezed == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as CheckedInput?,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as bool,restarted: null == restarted ? _self.restarted : restarted // ignore: cast_nullable_to_non_nullable
as bool,rowsFailed: null == rowsFailed ? _self.rowsFailed : rowsFailed // ignore: cast_nullable_to_non_nullable
as bool,resumed: null == resumed ? _self.resumed : resumed // ignore: cast_nullable_to_non_nullable
as bool,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,notChecked: null == notChecked ? _self.notChecked : notChecked // ignore: cast_nullable_to_non_nullable
as int,answered: null == answered ? _self.answered : answered // ignore: cast_nullable_to_non_nullable
as int,rowsRetryAt: freezed == rowsRetryAt ? _self.rowsRetryAt : rowsRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<RecoveredScan>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
