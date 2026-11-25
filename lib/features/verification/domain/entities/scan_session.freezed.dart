// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionTotals {

 String get id; int get scanned; int get valid; int get warning; int get notFound; int get unassigned; int? get left;
/// Create a copy of SessionTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionTotalsCopyWith<SessionTotals> get copyWith => _$SessionTotalsCopyWithImpl<SessionTotals>(this as SessionTotals, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionTotals&&(identical(other.id, id) || other.id == id)&&(identical(other.scanned, scanned) || other.scanned == scanned)&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.notFound, notFound) || other.notFound == notFound)&&(identical(other.unassigned, unassigned) || other.unassigned == unassigned)&&(identical(other.left, left) || other.left == left));
}


@override
int get hashCode => Object.hash(runtimeType,id,scanned,valid,warning,notFound,unassigned,left);

@override
String toString() {
  return 'SessionTotals(id: $id, scanned: $scanned, valid: $valid, warning: $warning, notFound: $notFound, unassigned: $unassigned, left: $left)';
}


}

/// @nodoc
abstract mixin class $SessionTotalsCopyWith<$Res>  {
  factory $SessionTotalsCopyWith(SessionTotals value, $Res Function(SessionTotals) _then) = _$SessionTotalsCopyWithImpl;
@useResult
$Res call({
 String id, int scanned, int valid, int warning, int notFound, int unassigned, int? left
});




}
/// @nodoc
class _$SessionTotalsCopyWithImpl<$Res>
    implements $SessionTotalsCopyWith<$Res> {
  _$SessionTotalsCopyWithImpl(this._self, this._then);

  final SessionTotals _self;
  final $Res Function(SessionTotals) _then;

/// Create a copy of SessionTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scanned = null,Object? valid = null,Object? warning = null,Object? notFound = null,Object? unassigned = null,Object? left = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scanned: null == scanned ? _self.scanned : scanned // ignore: cast_nullable_to_non_nullable
as int,valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as int,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as int,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as int,unassigned: null == unassigned ? _self.unassigned : unassigned // ignore: cast_nullable_to_non_nullable
as int,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionTotals].
extension SessionTotalsPatterns on SessionTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionTotals value)  $default,){
final _that = this;
switch (_that) {
case _SessionTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionTotals value)?  $default,){
final _that = this;
switch (_that) {
case _SessionTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int scanned,  int valid,  int warning,  int notFound,  int unassigned,  int? left)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionTotals() when $default != null:
return $default(_that.id,_that.scanned,_that.valid,_that.warning,_that.notFound,_that.unassigned,_that.left);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int scanned,  int valid,  int warning,  int notFound,  int unassigned,  int? left)  $default,) {final _that = this;
switch (_that) {
case _SessionTotals():
return $default(_that.id,_that.scanned,_that.valid,_that.warning,_that.notFound,_that.unassigned,_that.left);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int scanned,  int valid,  int warning,  int notFound,  int unassigned,  int? left)?  $default,) {final _that = this;
switch (_that) {
case _SessionTotals() when $default != null:
return $default(_that.id,_that.scanned,_that.valid,_that.warning,_that.notFound,_that.unassigned,_that.left);case _:
  return null;

}
}

}

/// @nodoc


class _SessionTotals implements SessionTotals {
  const _SessionTotals({required this.id, required this.scanned, required this.valid, required this.warning, required this.notFound, required this.unassigned, this.left});
  

@override final  String id;
@override final  int scanned;
@override final  int valid;
@override final  int warning;
@override final  int notFound;
@override final  int unassigned;
@override final  int? left;

/// Create a copy of SessionTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionTotalsCopyWith<_SessionTotals> get copyWith => __$SessionTotalsCopyWithImpl<_SessionTotals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionTotals&&(identical(other.id, id) || other.id == id)&&(identical(other.scanned, scanned) || other.scanned == scanned)&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.notFound, notFound) || other.notFound == notFound)&&(identical(other.unassigned, unassigned) || other.unassigned == unassigned)&&(identical(other.left, left) || other.left == left));
}


@override
int get hashCode => Object.hash(runtimeType,id,scanned,valid,warning,notFound,unassigned,left);

@override
String toString() {
  return 'SessionTotals(id: $id, scanned: $scanned, valid: $valid, warning: $warning, notFound: $notFound, unassigned: $unassigned, left: $left)';
}


}

/// @nodoc
abstract mixin class _$SessionTotalsCopyWith<$Res> implements $SessionTotalsCopyWith<$Res> {
  factory _$SessionTotalsCopyWith(_SessionTotals value, $Res Function(_SessionTotals) _then) = __$SessionTotalsCopyWithImpl;
@override @useResult
$Res call({
 String id, int scanned, int valid, int warning, int notFound, int unassigned, int? left
});




}
/// @nodoc
class __$SessionTotalsCopyWithImpl<$Res>
    implements _$SessionTotalsCopyWith<$Res> {
  __$SessionTotalsCopyWithImpl(this._self, this._then);

  final _SessionTotals _self;
  final $Res Function(_SessionTotals) _then;

/// Create a copy of SessionTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scanned = null,Object? valid = null,Object? warning = null,Object? notFound = null,Object? unassigned = null,Object? left = freezed,}) {
  return _then(_SessionTotals(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scanned: null == scanned ? _self.scanned : scanned // ignore: cast_nullable_to_non_nullable
as int,valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as int,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as int,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as int,unassigned: null == unassigned ? _self.unassigned : unassigned // ignore: cast_nullable_to_non_nullable
as int,left: freezed == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$ScanResult {

 LookupResult get result; bool get repeat; SessionTotals get session;
/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanResultCopyWith<ScanResult> get copyWith => _$ScanResultCopyWithImpl<ScanResult>(this as ScanResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanResult&&(identical(other.result, result) || other.result == result)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,result,repeat,session);

@override
String toString() {
  return 'ScanResult(result: $result, repeat: $repeat, session: $session)';
}


}

/// @nodoc
abstract mixin class $ScanResultCopyWith<$Res>  {
  factory $ScanResultCopyWith(ScanResult value, $Res Function(ScanResult) _then) = _$ScanResultCopyWithImpl;
@useResult
$Res call({
 LookupResult result, bool repeat, SessionTotals session
});


$LookupResultCopyWith<$Res> get result;$SessionTotalsCopyWith<$Res> get session;

}
/// @nodoc
class _$ScanResultCopyWithImpl<$Res>
    implements $ScanResultCopyWith<$Res> {
  _$ScanResultCopyWithImpl(this._self, this._then);

  final ScanResult _self;
  final $Res Function(ScanResult) _then;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? result = null,Object? repeat = null,Object? session = null,}) {
  return _then(_self.copyWith(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as LookupResult,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as bool,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionTotals,
  ));
}
/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LookupResultCopyWith<$Res> get result {
  
  return $LookupResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionTotalsCopyWith<$Res> get session {
  
  return $SessionTotalsCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanResult].
extension ScanResultPatterns on ScanResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanResult value)  $default,){
final _that = this;
switch (_that) {
case _ScanResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanResult value)?  $default,){
final _that = this;
switch (_that) {
case _ScanResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LookupResult result,  bool repeat,  SessionTotals session)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanResult() when $default != null:
return $default(_that.result,_that.repeat,_that.session);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LookupResult result,  bool repeat,  SessionTotals session)  $default,) {final _that = this;
switch (_that) {
case _ScanResult():
return $default(_that.result,_that.repeat,_that.session);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LookupResult result,  bool repeat,  SessionTotals session)?  $default,) {final _that = this;
switch (_that) {
case _ScanResult() when $default != null:
return $default(_that.result,_that.repeat,_that.session);case _:
  return null;

}
}

}

/// @nodoc


class _ScanResult implements ScanResult {
  const _ScanResult({required this.result, required this.repeat, required this.session});
  

@override final  LookupResult result;
@override final  bool repeat;
@override final  SessionTotals session;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanResultCopyWith<_ScanResult> get copyWith => __$ScanResultCopyWithImpl<_ScanResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanResult&&(identical(other.result, result) || other.result == result)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode => Object.hash(runtimeType,result,repeat,session);

@override
String toString() {
  return 'ScanResult(result: $result, repeat: $repeat, session: $session)';
}


}

/// @nodoc
abstract mixin class _$ScanResultCopyWith<$Res> implements $ScanResultCopyWith<$Res> {
  factory _$ScanResultCopyWith(_ScanResult value, $Res Function(_ScanResult) _then) = __$ScanResultCopyWithImpl;
@override @useResult
$Res call({
 LookupResult result, bool repeat, SessionTotals session
});


@override $LookupResultCopyWith<$Res> get result;@override $SessionTotalsCopyWith<$Res> get session;

}
/// @nodoc
class __$ScanResultCopyWithImpl<$Res>
    implements _$ScanResultCopyWith<$Res> {
  __$ScanResultCopyWithImpl(this._self, this._then);

  final _ScanResult _self;
  final $Res Function(_ScanResult) _then;

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? result = null,Object? repeat = null,Object? session = null,}) {
  return _then(_ScanResult(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as LookupResult,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as bool,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionTotals,
  ));
}

/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LookupResultCopyWith<$Res> get result {
  
  return $LookupResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}/// Create a copy of ScanResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionTotalsCopyWith<$Res> get session {
  
  return $SessionTotalsCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc
mixin _$ScanSessionSummary {

 SessionTotals get totals; SessionKind get kind; ScanStatus get status; DateTime get startedAt; DateTime get lastScanAt;
/// Create a copy of ScanSessionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScanSessionSummaryCopyWith<ScanSessionSummary> get copyWith => _$ScanSessionSummaryCopyWithImpl<ScanSessionSummary>(this as ScanSessionSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScanSessionSummary&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.lastScanAt, lastScanAt) || other.lastScanAt == lastScanAt));
}


@override
int get hashCode => Object.hash(runtimeType,totals,kind,status,startedAt,lastScanAt);

@override
String toString() {
  return 'ScanSessionSummary(totals: $totals, kind: $kind, status: $status, startedAt: $startedAt, lastScanAt: $lastScanAt)';
}


}

/// @nodoc
abstract mixin class $ScanSessionSummaryCopyWith<$Res>  {
  factory $ScanSessionSummaryCopyWith(ScanSessionSummary value, $Res Function(ScanSessionSummary) _then) = _$ScanSessionSummaryCopyWithImpl;
@useResult
$Res call({
 SessionTotals totals, SessionKind kind, ScanStatus status, DateTime startedAt, DateTime lastScanAt
});


$SessionTotalsCopyWith<$Res> get totals;

}
/// @nodoc
class _$ScanSessionSummaryCopyWithImpl<$Res>
    implements $ScanSessionSummaryCopyWith<$Res> {
  _$ScanSessionSummaryCopyWithImpl(this._self, this._then);

  final ScanSessionSummary _self;
  final $Res Function(ScanSessionSummary) _then;

/// Create a copy of ScanSessionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totals = null,Object? kind = null,Object? status = null,Object? startedAt = null,Object? lastScanAt = null,}) {
  return _then(_self.copyWith(
totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as SessionTotals,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SessionKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScanStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastScanAt: null == lastScanAt ? _self.lastScanAt : lastScanAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ScanSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionTotalsCopyWith<$Res> get totals {
  
  return $SessionTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScanSessionSummary].
extension ScanSessionSummaryPatterns on ScanSessionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScanSessionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScanSessionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScanSessionSummary value)  $default,){
final _that = this;
switch (_that) {
case _ScanSessionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScanSessionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ScanSessionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SessionTotals totals,  SessionKind kind,  ScanStatus status,  DateTime startedAt,  DateTime lastScanAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScanSessionSummary() when $default != null:
return $default(_that.totals,_that.kind,_that.status,_that.startedAt,_that.lastScanAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SessionTotals totals,  SessionKind kind,  ScanStatus status,  DateTime startedAt,  DateTime lastScanAt)  $default,) {final _that = this;
switch (_that) {
case _ScanSessionSummary():
return $default(_that.totals,_that.kind,_that.status,_that.startedAt,_that.lastScanAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SessionTotals totals,  SessionKind kind,  ScanStatus status,  DateTime startedAt,  DateTime lastScanAt)?  $default,) {final _that = this;
switch (_that) {
case _ScanSessionSummary() when $default != null:
return $default(_that.totals,_that.kind,_that.status,_that.startedAt,_that.lastScanAt);case _:
  return null;

}
}

}

/// @nodoc


class _ScanSessionSummary implements ScanSessionSummary {
  const _ScanSessionSummary({required this.totals, required this.kind, required this.status, required this.startedAt, required this.lastScanAt});
  

@override final  SessionTotals totals;
@override final  SessionKind kind;
@override final  ScanStatus status;
@override final  DateTime startedAt;
@override final  DateTime lastScanAt;

/// Create a copy of ScanSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScanSessionSummaryCopyWith<_ScanSessionSummary> get copyWith => __$ScanSessionSummaryCopyWithImpl<_ScanSessionSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScanSessionSummary&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.lastScanAt, lastScanAt) || other.lastScanAt == lastScanAt));
}


@override
int get hashCode => Object.hash(runtimeType,totals,kind,status,startedAt,lastScanAt);

@override
String toString() {
  return 'ScanSessionSummary(totals: $totals, kind: $kind, status: $status, startedAt: $startedAt, lastScanAt: $lastScanAt)';
}


}

/// @nodoc
abstract mixin class _$ScanSessionSummaryCopyWith<$Res> implements $ScanSessionSummaryCopyWith<$Res> {
  factory _$ScanSessionSummaryCopyWith(_ScanSessionSummary value, $Res Function(_ScanSessionSummary) _then) = __$ScanSessionSummaryCopyWithImpl;
@override @useResult
$Res call({
 SessionTotals totals, SessionKind kind, ScanStatus status, DateTime startedAt, DateTime lastScanAt
});


@override $SessionTotalsCopyWith<$Res> get totals;

}
/// @nodoc
class __$ScanSessionSummaryCopyWithImpl<$Res>
    implements _$ScanSessionSummaryCopyWith<$Res> {
  __$ScanSessionSummaryCopyWithImpl(this._self, this._then);

  final _ScanSessionSummary _self;
  final $Res Function(_ScanSessionSummary) _then;

/// Create a copy of ScanSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totals = null,Object? kind = null,Object? status = null,Object? startedAt = null,Object? lastScanAt = null,}) {
  return _then(_ScanSessionSummary(
totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as SessionTotals,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SessionKind,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScanStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastScanAt: null == lastScanAt ? _self.lastScanAt : lastScanAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ScanSessionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionTotalsCopyWith<$Res> get totals {
  
  return $SessionTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}
}

/// @nodoc
mixin _$SessionQuery {

 ScanStatus? get status;/// Calendar days, both included.
 DateTime? get from; DateTime? get to;
/// Create a copy of SessionQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionQueryCopyWith<SessionQuery> get copyWith => _$SessionQueryCopyWithImpl<SessionQuery>(this as SessionQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionQuery&&(identical(other.status, status) || other.status == status)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,status,from,to);

@override
String toString() {
  return 'SessionQuery(status: $status, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $SessionQueryCopyWith<$Res>  {
  factory $SessionQueryCopyWith(SessionQuery value, $Res Function(SessionQuery) _then) = _$SessionQueryCopyWithImpl;
@useResult
$Res call({
 ScanStatus? status, DateTime? from, DateTime? to
});




}
/// @nodoc
class _$SessionQueryCopyWithImpl<$Res>
    implements $SessionQueryCopyWith<$Res> {
  _$SessionQueryCopyWithImpl(this._self, this._then);

  final SessionQuery _self;
  final $Res Function(SessionQuery) _then;

/// Create a copy of SessionQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? from = freezed,Object? to = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScanStatus?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionQuery].
extension SessionQueryPatterns on SessionQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionQuery value)  $default,){
final _that = this;
switch (_that) {
case _SessionQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionQuery value)?  $default,){
final _that = this;
switch (_that) {
case _SessionQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScanStatus? status,  DateTime? from,  DateTime? to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionQuery() when $default != null:
return $default(_that.status,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScanStatus? status,  DateTime? from,  DateTime? to)  $default,) {final _that = this;
switch (_that) {
case _SessionQuery():
return $default(_that.status,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScanStatus? status,  DateTime? from,  DateTime? to)?  $default,) {final _that = this;
switch (_that) {
case _SessionQuery() when $default != null:
return $default(_that.status,_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc


class _SessionQuery implements SessionQuery {
  const _SessionQuery({this.status, this.from, this.to});
  

@override final  ScanStatus? status;
/// Calendar days, both included.
@override final  DateTime? from;
@override final  DateTime? to;

/// Create a copy of SessionQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionQueryCopyWith<_SessionQuery> get copyWith => __$SessionQueryCopyWithImpl<_SessionQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionQuery&&(identical(other.status, status) || other.status == status)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,status,from,to);

@override
String toString() {
  return 'SessionQuery(status: $status, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$SessionQueryCopyWith<$Res> implements $SessionQueryCopyWith<$Res> {
  factory _$SessionQueryCopyWith(_SessionQuery value, $Res Function(_SessionQuery) _then) = __$SessionQueryCopyWithImpl;
@override @useResult
$Res call({
 ScanStatus? status, DateTime? from, DateTime? to
});




}
/// @nodoc
class __$SessionQueryCopyWithImpl<$Res>
    implements _$SessionQueryCopyWith<$Res> {
  __$SessionQueryCopyWithImpl(this._self, this._then);

  final _SessionQuery _self;
  final $Res Function(_SessionQuery) _then;

/// Create a copy of SessionQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? from = freezed,Object? to = freezed,}) {
  return _then(_SessionQuery(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScanStatus?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$RecoveredScan {

 String get ref; LookupOutcome get outcome; String? get serial; String? get product;
/// Create a copy of RecoveredScan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveredScanCopyWith<RecoveredScan> get copyWith => _$RecoveredScanCopyWithImpl<RecoveredScan>(this as RecoveredScan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveredScan&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode => Object.hash(runtimeType,ref,outcome,serial,product);

@override
String toString() {
  return 'RecoveredScan(ref: $ref, outcome: $outcome, serial: $serial, product: $product)';
}


}

/// @nodoc
abstract mixin class $RecoveredScanCopyWith<$Res>  {
  factory $RecoveredScanCopyWith(RecoveredScan value, $Res Function(RecoveredScan) _then) = _$RecoveredScanCopyWithImpl;
@useResult
$Res call({
 String ref, LookupOutcome outcome, String? serial, String? product
});




}
/// @nodoc
class _$RecoveredScanCopyWithImpl<$Res>
    implements $RecoveredScanCopyWith<$Res> {
  _$RecoveredScanCopyWithImpl(this._self, this._then);

  final RecoveredScan _self;
  final $Res Function(RecoveredScan) _then;

/// Create a copy of RecoveredScan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? outcome = null,Object? serial = freezed,Object? product = freezed,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as LookupOutcome,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecoveredScan].
extension RecoveredScanPatterns on RecoveredScan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveredScan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveredScan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveredScan value)  $default,){
final _that = this;
switch (_that) {
case _RecoveredScan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveredScan value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveredScan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  LookupOutcome outcome,  String? serial,  String? product)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveredScan() when $default != null:
return $default(_that.ref,_that.outcome,_that.serial,_that.product);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  LookupOutcome outcome,  String? serial,  String? product)  $default,) {final _that = this;
switch (_that) {
case _RecoveredScan():
return $default(_that.ref,_that.outcome,_that.serial,_that.product);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  LookupOutcome outcome,  String? serial,  String? product)?  $default,) {final _that = this;
switch (_that) {
case _RecoveredScan() when $default != null:
return $default(_that.ref,_that.outcome,_that.serial,_that.product);case _:
  return null;

}
}

}

/// @nodoc


class _RecoveredScan implements RecoveredScan {
  const _RecoveredScan({required this.ref, required this.outcome, this.serial, this.product});
  

@override final  String ref;
@override final  LookupOutcome outcome;
@override final  String? serial;
@override final  String? product;

/// Create a copy of RecoveredScan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveredScanCopyWith<_RecoveredScan> get copyWith => __$RecoveredScanCopyWithImpl<_RecoveredScan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveredScan&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.product, product) || other.product == product));
}


@override
int get hashCode => Object.hash(runtimeType,ref,outcome,serial,product);

@override
String toString() {
  return 'RecoveredScan(ref: $ref, outcome: $outcome, serial: $serial, product: $product)';
}


}

/// @nodoc
abstract mixin class _$RecoveredScanCopyWith<$Res> implements $RecoveredScanCopyWith<$Res> {
  factory _$RecoveredScanCopyWith(_RecoveredScan value, $Res Function(_RecoveredScan) _then) = __$RecoveredScanCopyWithImpl;
@override @useResult
$Res call({
 String ref, LookupOutcome outcome, String? serial, String? product
});




}
/// @nodoc
class __$RecoveredScanCopyWithImpl<$Res>
    implements _$RecoveredScanCopyWith<$Res> {
  __$RecoveredScanCopyWithImpl(this._self, this._then);

  final _RecoveredScan _self;
  final $Res Function(_RecoveredScan) _then;

/// Create a copy of RecoveredScan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? outcome = null,Object? serial = freezed,Object? product = freezed,}) {
  return _then(_RecoveredScan(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as LookupOutcome,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
