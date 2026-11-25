// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckRecord {

 String get ref; DateTime get at; CheckWay get way; CheckResult get result;/// Empty unless the result is `warning`.
 List<CheckReason> get reasons;/// Whoever made the check.
 String get official;/// `null` for `not_found`; [product] and [batch] also for `unassigned`.
 String? get serial; String? get product; String? get batch; String? get sessionId;
/// Create a copy of CheckRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckRecordCopyWith<CheckRecord> get copyWith => _$CheckRecordCopyWithImpl<CheckRecord>(this as CheckRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckRecord&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.at, at) || other.at == at)&&(identical(other.way, way) || other.way == way)&&(identical(other.result, result) || other.result == result)&&const DeepCollectionEquality().equals(other.reasons, reasons)&&(identical(other.official, official) || other.official == official)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.product, product) || other.product == product)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,ref,at,way,result,const DeepCollectionEquality().hash(reasons),official,serial,product,batch,sessionId);

@override
String toString() {
  return 'CheckRecord(ref: $ref, at: $at, way: $way, result: $result, reasons: $reasons, official: $official, serial: $serial, product: $product, batch: $batch, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $CheckRecordCopyWith<$Res>  {
  factory $CheckRecordCopyWith(CheckRecord value, $Res Function(CheckRecord) _then) = _$CheckRecordCopyWithImpl;
@useResult
$Res call({
 String ref, DateTime at, CheckWay way, CheckResult result, List<CheckReason> reasons, String official, String? serial, String? product, String? batch, String? sessionId
});




}
/// @nodoc
class _$CheckRecordCopyWithImpl<$Res>
    implements $CheckRecordCopyWith<$Res> {
  _$CheckRecordCopyWithImpl(this._self, this._then);

  final CheckRecord _self;
  final $Res Function(CheckRecord) _then;

/// Create a copy of CheckRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? at = null,Object? way = null,Object? result = null,Object? reasons = null,Object? official = null,Object? serial = freezed,Object? product = freezed,Object? batch = freezed,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,way: null == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as CheckWay,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CheckResult,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<CheckReason>,official: null == official ? _self.official : official // ignore: cast_nullable_to_non_nullable
as String,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as String?,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckRecord].
extension CheckRecordPatterns on CheckRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckRecord value)  $default,){
final _that = this;
switch (_that) {
case _CheckRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckRecord value)?  $default,){
final _that = this;
switch (_that) {
case _CheckRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  DateTime at,  CheckWay way,  CheckResult result,  List<CheckReason> reasons,  String official,  String? serial,  String? product,  String? batch,  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckRecord() when $default != null:
return $default(_that.ref,_that.at,_that.way,_that.result,_that.reasons,_that.official,_that.serial,_that.product,_that.batch,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  DateTime at,  CheckWay way,  CheckResult result,  List<CheckReason> reasons,  String official,  String? serial,  String? product,  String? batch,  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _CheckRecord():
return $default(_that.ref,_that.at,_that.way,_that.result,_that.reasons,_that.official,_that.serial,_that.product,_that.batch,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  DateTime at,  CheckWay way,  CheckResult result,  List<CheckReason> reasons,  String official,  String? serial,  String? product,  String? batch,  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _CheckRecord() when $default != null:
return $default(_that.ref,_that.at,_that.way,_that.result,_that.reasons,_that.official,_that.serial,_that.product,_that.batch,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc


class _CheckRecord implements CheckRecord {
  const _CheckRecord({required this.ref, required this.at, required this.way, required this.result, required final  List<CheckReason> reasons, required this.official, this.serial, this.product, this.batch, this.sessionId}): _reasons = reasons;
  

@override final  String ref;
@override final  DateTime at;
@override final  CheckWay way;
@override final  CheckResult result;
/// Empty unless the result is `warning`.
 final  List<CheckReason> _reasons;
/// Empty unless the result is `warning`.
@override List<CheckReason> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

/// Whoever made the check.
@override final  String official;
/// `null` for `not_found`; [product] and [batch] also for `unassigned`.
@override final  String? serial;
@override final  String? product;
@override final  String? batch;
@override final  String? sessionId;

/// Create a copy of CheckRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckRecordCopyWith<_CheckRecord> get copyWith => __$CheckRecordCopyWithImpl<_CheckRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckRecord&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.at, at) || other.at == at)&&(identical(other.way, way) || other.way == way)&&(identical(other.result, result) || other.result == result)&&const DeepCollectionEquality().equals(other._reasons, _reasons)&&(identical(other.official, official) || other.official == official)&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.product, product) || other.product == product)&&(identical(other.batch, batch) || other.batch == batch)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,ref,at,way,result,const DeepCollectionEquality().hash(_reasons),official,serial,product,batch,sessionId);

@override
String toString() {
  return 'CheckRecord(ref: $ref, at: $at, way: $way, result: $result, reasons: $reasons, official: $official, serial: $serial, product: $product, batch: $batch, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$CheckRecordCopyWith<$Res> implements $CheckRecordCopyWith<$Res> {
  factory _$CheckRecordCopyWith(_CheckRecord value, $Res Function(_CheckRecord) _then) = __$CheckRecordCopyWithImpl;
@override @useResult
$Res call({
 String ref, DateTime at, CheckWay way, CheckResult result, List<CheckReason> reasons, String official, String? serial, String? product, String? batch, String? sessionId
});




}
/// @nodoc
class __$CheckRecordCopyWithImpl<$Res>
    implements _$CheckRecordCopyWith<$Res> {
  __$CheckRecordCopyWithImpl(this._self, this._then);

  final _CheckRecord _self;
  final $Res Function(_CheckRecord) _then;

/// Create a copy of CheckRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? at = null,Object? way = null,Object? result = null,Object? reasons = null,Object? official = null,Object? serial = freezed,Object? product = freezed,Object? batch = freezed,Object? sessionId = freezed,}) {
  return _then(_CheckRecord(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,way: null == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as CheckWay,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CheckResult,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<CheckReason>,official: null == official ? _self.official : official // ignore: cast_nullable_to_non_nullable
as String,serial: freezed == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as String?,batch: freezed == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CheckTotals {

 int get total; int get valid; int get warning; int get notFound; int get unassigned;
/// Create a copy of CheckTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckTotalsCopyWith<CheckTotals> get copyWith => _$CheckTotalsCopyWithImpl<CheckTotals>(this as CheckTotals, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckTotals&&(identical(other.total, total) || other.total == total)&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.notFound, notFound) || other.notFound == notFound)&&(identical(other.unassigned, unassigned) || other.unassigned == unassigned));
}


@override
int get hashCode => Object.hash(runtimeType,total,valid,warning,notFound,unassigned);

@override
String toString() {
  return 'CheckTotals(total: $total, valid: $valid, warning: $warning, notFound: $notFound, unassigned: $unassigned)';
}


}

/// @nodoc
abstract mixin class $CheckTotalsCopyWith<$Res>  {
  factory $CheckTotalsCopyWith(CheckTotals value, $Res Function(CheckTotals) _then) = _$CheckTotalsCopyWithImpl;
@useResult
$Res call({
 int total, int valid, int warning, int notFound, int unassigned
});




}
/// @nodoc
class _$CheckTotalsCopyWithImpl<$Res>
    implements $CheckTotalsCopyWith<$Res> {
  _$CheckTotalsCopyWithImpl(this._self, this._then);

  final CheckTotals _self;
  final $Res Function(CheckTotals) _then;

/// Create a copy of CheckTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? valid = null,Object? warning = null,Object? notFound = null,Object? unassigned = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as int,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as int,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as int,unassigned: null == unassigned ? _self.unassigned : unassigned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckTotals].
extension CheckTotalsPatterns on CheckTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckTotals value)  $default,){
final _that = this;
switch (_that) {
case _CheckTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckTotals value)?  $default,){
final _that = this;
switch (_that) {
case _CheckTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int valid,  int warning,  int notFound,  int unassigned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckTotals() when $default != null:
return $default(_that.total,_that.valid,_that.warning,_that.notFound,_that.unassigned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int valid,  int warning,  int notFound,  int unassigned)  $default,) {final _that = this;
switch (_that) {
case _CheckTotals():
return $default(_that.total,_that.valid,_that.warning,_that.notFound,_that.unassigned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int valid,  int warning,  int notFound,  int unassigned)?  $default,) {final _that = this;
switch (_that) {
case _CheckTotals() when $default != null:
return $default(_that.total,_that.valid,_that.warning,_that.notFound,_that.unassigned);case _:
  return null;

}
}

}

/// @nodoc


class _CheckTotals implements CheckTotals {
  const _CheckTotals({required this.total, required this.valid, required this.warning, required this.notFound, required this.unassigned});
  

@override final  int total;
@override final  int valid;
@override final  int warning;
@override final  int notFound;
@override final  int unassigned;

/// Create a copy of CheckTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckTotalsCopyWith<_CheckTotals> get copyWith => __$CheckTotalsCopyWithImpl<_CheckTotals>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckTotals&&(identical(other.total, total) || other.total == total)&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.notFound, notFound) || other.notFound == notFound)&&(identical(other.unassigned, unassigned) || other.unassigned == unassigned));
}


@override
int get hashCode => Object.hash(runtimeType,total,valid,warning,notFound,unassigned);

@override
String toString() {
  return 'CheckTotals(total: $total, valid: $valid, warning: $warning, notFound: $notFound, unassigned: $unassigned)';
}


}

/// @nodoc
abstract mixin class _$CheckTotalsCopyWith<$Res> implements $CheckTotalsCopyWith<$Res> {
  factory _$CheckTotalsCopyWith(_CheckTotals value, $Res Function(_CheckTotals) _then) = __$CheckTotalsCopyWithImpl;
@override @useResult
$Res call({
 int total, int valid, int warning, int notFound, int unassigned
});




}
/// @nodoc
class __$CheckTotalsCopyWithImpl<$Res>
    implements _$CheckTotalsCopyWith<$Res> {
  __$CheckTotalsCopyWithImpl(this._self, this._then);

  final _CheckTotals _self;
  final $Res Function(_CheckTotals) _then;

/// Create a copy of CheckTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? valid = null,Object? warning = null,Object? notFound = null,Object? unassigned = null,}) {
  return _then(_CheckTotals(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as int,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as int,notFound: null == notFound ? _self.notFound : notFound // ignore: cast_nullable_to_non_nullable
as int,unassigned: null == unassigned ? _self.unassigned : unassigned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$CheckQuery {

 CheckResult? get result; CheckWay? get way;/// Calendar days, both included.
 DateTime? get from; DateTime? get to;/// A serial or a reference number.
 String? get search; String? get sessionId;
/// Create a copy of CheckQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckQueryCopyWith<CheckQuery> get copyWith => _$CheckQueryCopyWithImpl<CheckQuery>(this as CheckQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckQuery&&(identical(other.result, result) || other.result == result)&&(identical(other.way, way) || other.way == way)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.search, search) || other.search == search)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,result,way,from,to,search,sessionId);

@override
String toString() {
  return 'CheckQuery(result: $result, way: $way, from: $from, to: $to, search: $search, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $CheckQueryCopyWith<$Res>  {
  factory $CheckQueryCopyWith(CheckQuery value, $Res Function(CheckQuery) _then) = _$CheckQueryCopyWithImpl;
@useResult
$Res call({
 CheckResult? result, CheckWay? way, DateTime? from, DateTime? to, String? search, String? sessionId
});




}
/// @nodoc
class _$CheckQueryCopyWithImpl<$Res>
    implements $CheckQueryCopyWith<$Res> {
  _$CheckQueryCopyWithImpl(this._self, this._then);

  final CheckQuery _self;
  final $Res Function(CheckQuery) _then;

/// Create a copy of CheckQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? result = freezed,Object? way = freezed,Object? from = freezed,Object? to = freezed,Object? search = freezed,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CheckResult?,way: freezed == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as CheckWay?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckQuery].
extension CheckQueryPatterns on CheckQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckQuery value)  $default,){
final _that = this;
switch (_that) {
case _CheckQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckQuery value)?  $default,){
final _that = this;
switch (_that) {
case _CheckQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CheckResult? result,  CheckWay? way,  DateTime? from,  DateTime? to,  String? search,  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckQuery() when $default != null:
return $default(_that.result,_that.way,_that.from,_that.to,_that.search,_that.sessionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CheckResult? result,  CheckWay? way,  DateTime? from,  DateTime? to,  String? search,  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _CheckQuery():
return $default(_that.result,_that.way,_that.from,_that.to,_that.search,_that.sessionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CheckResult? result,  CheckWay? way,  DateTime? from,  DateTime? to,  String? search,  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _CheckQuery() when $default != null:
return $default(_that.result,_that.way,_that.from,_that.to,_that.search,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc


class _CheckQuery extends CheckQuery {
  const _CheckQuery({this.result, this.way, this.from, this.to, this.search, this.sessionId}): super._();
  

@override final  CheckResult? result;
@override final  CheckWay? way;
/// Calendar days, both included.
@override final  DateTime? from;
@override final  DateTime? to;
/// A serial or a reference number.
@override final  String? search;
@override final  String? sessionId;

/// Create a copy of CheckQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckQueryCopyWith<_CheckQuery> get copyWith => __$CheckQueryCopyWithImpl<_CheckQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckQuery&&(identical(other.result, result) || other.result == result)&&(identical(other.way, way) || other.way == way)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.search, search) || other.search == search)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}


@override
int get hashCode => Object.hash(runtimeType,result,way,from,to,search,sessionId);

@override
String toString() {
  return 'CheckQuery(result: $result, way: $way, from: $from, to: $to, search: $search, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$CheckQueryCopyWith<$Res> implements $CheckQueryCopyWith<$Res> {
  factory _$CheckQueryCopyWith(_CheckQuery value, $Res Function(_CheckQuery) _then) = __$CheckQueryCopyWithImpl;
@override @useResult
$Res call({
 CheckResult? result, CheckWay? way, DateTime? from, DateTime? to, String? search, String? sessionId
});




}
/// @nodoc
class __$CheckQueryCopyWithImpl<$Res>
    implements _$CheckQueryCopyWith<$Res> {
  __$CheckQueryCopyWithImpl(this._self, this._then);

  final _CheckQuery _self;
  final $Res Function(_CheckQuery) _then;

/// Create a copy of CheckQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? result = freezed,Object? way = freezed,Object? from = freezed,Object? to = freezed,Object? search = freezed,Object? sessionId = freezed,}) {
  return _then(_CheckQuery(
result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CheckResult?,way: freezed == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as CheckWay?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CheckPage {

 CursorPage<CheckRecord> get page; CheckTotals? get totals;
/// Create a copy of CheckPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckPageCopyWith<CheckPage> get copyWith => _$CheckPageCopyWithImpl<CheckPage>(this as CheckPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckPage&&(identical(other.page, page) || other.page == page)&&(identical(other.totals, totals) || other.totals == totals));
}


@override
int get hashCode => Object.hash(runtimeType,page,totals);

@override
String toString() {
  return 'CheckPage(page: $page, totals: $totals)';
}


}

/// @nodoc
abstract mixin class $CheckPageCopyWith<$Res>  {
  factory $CheckPageCopyWith(CheckPage value, $Res Function(CheckPage) _then) = _$CheckPageCopyWithImpl;
@useResult
$Res call({
 CursorPage<CheckRecord> page, CheckTotals? totals
});


$CursorPageCopyWith<CheckRecord, $Res> get page;$CheckTotalsCopyWith<$Res>? get totals;

}
/// @nodoc
class _$CheckPageCopyWithImpl<$Res>
    implements $CheckPageCopyWith<$Res> {
  _$CheckPageCopyWithImpl(this._self, this._then);

  final CheckPage _self;
  final $Res Function(CheckPage) _then;

/// Create a copy of CheckPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? totals = freezed,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as CursorPage<CheckRecord>,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as CheckTotals?,
  ));
}
/// Create a copy of CheckPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CursorPageCopyWith<CheckRecord, $Res> get page {
  
  return $CursorPageCopyWith<CheckRecord, $Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}/// Create a copy of CheckPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckTotalsCopyWith<$Res>? get totals {
    if (_self.totals == null) {
    return null;
  }

  return $CheckTotalsCopyWith<$Res>(_self.totals!, (value) {
    return _then(_self.copyWith(totals: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckPage].
extension CheckPagePatterns on CheckPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckPage value)  $default,){
final _that = this;
switch (_that) {
case _CheckPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckPage value)?  $default,){
final _that = this;
switch (_that) {
case _CheckPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CursorPage<CheckRecord> page,  CheckTotals? totals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckPage() when $default != null:
return $default(_that.page,_that.totals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CursorPage<CheckRecord> page,  CheckTotals? totals)  $default,) {final _that = this;
switch (_that) {
case _CheckPage():
return $default(_that.page,_that.totals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CursorPage<CheckRecord> page,  CheckTotals? totals)?  $default,) {final _that = this;
switch (_that) {
case _CheckPage() when $default != null:
return $default(_that.page,_that.totals);case _:
  return null;

}
}

}

/// @nodoc


class _CheckPage implements CheckPage {
  const _CheckPage({required this.page, this.totals});
  

@override final  CursorPage<CheckRecord> page;
@override final  CheckTotals? totals;

/// Create a copy of CheckPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckPageCopyWith<_CheckPage> get copyWith => __$CheckPageCopyWithImpl<_CheckPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckPage&&(identical(other.page, page) || other.page == page)&&(identical(other.totals, totals) || other.totals == totals));
}


@override
int get hashCode => Object.hash(runtimeType,page,totals);

@override
String toString() {
  return 'CheckPage(page: $page, totals: $totals)';
}


}

/// @nodoc
abstract mixin class _$CheckPageCopyWith<$Res> implements $CheckPageCopyWith<$Res> {
  factory _$CheckPageCopyWith(_CheckPage value, $Res Function(_CheckPage) _then) = __$CheckPageCopyWithImpl;
@override @useResult
$Res call({
 CursorPage<CheckRecord> page, CheckTotals? totals
});


@override $CursorPageCopyWith<CheckRecord, $Res> get page;@override $CheckTotalsCopyWith<$Res>? get totals;

}
/// @nodoc
class __$CheckPageCopyWithImpl<$Res>
    implements _$CheckPageCopyWith<$Res> {
  __$CheckPageCopyWithImpl(this._self, this._then);

  final _CheckPage _self;
  final $Res Function(_CheckPage) _then;

/// Create a copy of CheckPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? totals = freezed,}) {
  return _then(_CheckPage(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as CursorPage<CheckRecord>,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as CheckTotals?,
  ));
}

/// Create a copy of CheckPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CursorPageCopyWith<CheckRecord, $Res> get page {
  
  return $CursorPageCopyWith<CheckRecord, $Res>(_self.page, (value) {
    return _then(_self.copyWith(page: value));
  });
}/// Create a copy of CheckPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckTotalsCopyWith<$Res>? get totals {
    if (_self.totals == null) {
    return null;
  }

  return $CheckTotalsCopyWith<$Res>(_self.totals!, (value) {
    return _then(_self.copyWith(totals: value));
  });
}
}

// dart format on
