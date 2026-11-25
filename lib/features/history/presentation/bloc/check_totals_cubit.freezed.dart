// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_totals_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckTotalsState {

 CheckTotalsStatus get status;/// The last counts; kept while they are asked for again.
 CheckTotals? get totals;/// After a `429` with `Retry-After`: when the counts may be asked for
/// again (final.md §13.10). `null` without a usable `Retry-After`.
 DateTime? get retryAt;
/// Create a copy of CheckTotalsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckTotalsStateCopyWith<CheckTotalsState> get copyWith => _$CheckTotalsStateCopyWithImpl<CheckTotalsState>(this as CheckTotalsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckTotalsState&&(identical(other.status, status) || other.status == status)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,totals,retryAt);

@override
String toString() {
  return 'CheckTotalsState(status: $status, totals: $totals, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class $CheckTotalsStateCopyWith<$Res>  {
  factory $CheckTotalsStateCopyWith(CheckTotalsState value, $Res Function(CheckTotalsState) _then) = _$CheckTotalsStateCopyWithImpl;
@useResult
$Res call({
 CheckTotalsStatus status, CheckTotals? totals, DateTime? retryAt
});




}
/// @nodoc
class _$CheckTotalsStateCopyWithImpl<$Res>
    implements $CheckTotalsStateCopyWith<$Res> {
  _$CheckTotalsStateCopyWithImpl(this._self, this._then);

  final CheckTotalsState _self;
  final $Res Function(CheckTotalsState) _then;

/// Create a copy of CheckTotalsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? totals = freezed,Object? retryAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CheckTotalsStatus,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as CheckTotals?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckTotalsState].
extension CheckTotalsStatePatterns on CheckTotalsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckTotalsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckTotalsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckTotalsState value)  $default,){
final _that = this;
switch (_that) {
case _CheckTotalsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckTotalsState value)?  $default,){
final _that = this;
switch (_that) {
case _CheckTotalsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CheckTotalsStatus status,  CheckTotals? totals,  DateTime? retryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckTotalsState() when $default != null:
return $default(_that.status,_that.totals,_that.retryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CheckTotalsStatus status,  CheckTotals? totals,  DateTime? retryAt)  $default,) {final _that = this;
switch (_that) {
case _CheckTotalsState():
return $default(_that.status,_that.totals,_that.retryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CheckTotalsStatus status,  CheckTotals? totals,  DateTime? retryAt)?  $default,) {final _that = this;
switch (_that) {
case _CheckTotalsState() when $default != null:
return $default(_that.status,_that.totals,_that.retryAt);case _:
  return null;

}
}

}

/// @nodoc


class _CheckTotalsState extends CheckTotalsState {
  const _CheckTotalsState({required this.status, this.totals, this.retryAt}): super._();
  

@override final  CheckTotalsStatus status;
/// The last counts; kept while they are asked for again.
@override final  CheckTotals? totals;
/// After a `429` with `Retry-After`: when the counts may be asked for
/// again (final.md §13.10). `null` without a usable `Retry-After`.
@override final  DateTime? retryAt;

/// Create a copy of CheckTotalsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckTotalsStateCopyWith<_CheckTotalsState> get copyWith => __$CheckTotalsStateCopyWithImpl<_CheckTotalsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckTotalsState&&(identical(other.status, status) || other.status == status)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,totals,retryAt);

@override
String toString() {
  return 'CheckTotalsState(status: $status, totals: $totals, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class _$CheckTotalsStateCopyWith<$Res> implements $CheckTotalsStateCopyWith<$Res> {
  factory _$CheckTotalsStateCopyWith(_CheckTotalsState value, $Res Function(_CheckTotalsState) _then) = __$CheckTotalsStateCopyWithImpl;
@override @useResult
$Res call({
 CheckTotalsStatus status, CheckTotals? totals, DateTime? retryAt
});




}
/// @nodoc
class __$CheckTotalsStateCopyWithImpl<$Res>
    implements _$CheckTotalsStateCopyWith<$Res> {
  __$CheckTotalsStateCopyWithImpl(this._self, this._then);

  final _CheckTotalsState _self;
  final $Res Function(_CheckTotalsState) _then;

/// Create a copy of CheckTotalsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? totals = freezed,Object? retryAt = freezed,}) {
  return _then(_CheckTotalsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CheckTotalsStatus,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as CheckTotals?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
