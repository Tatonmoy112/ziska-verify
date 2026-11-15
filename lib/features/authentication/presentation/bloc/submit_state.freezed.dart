// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubmitState {

 SubmitStatus get status; Failure? get failure;/// After a `429`: no new request before this time (final.md Section
/// 15.4: a countdown from `Retry-After`, then a retry is allowed).
 DateTime? get retryAt;
/// Create a copy of SubmitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitStateCopyWith<SubmitState> get copyWith => _$SubmitStateCopyWithImpl<SubmitState>(this as SubmitState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitState&&(identical(other.status, status) || other.status == status)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,failure,retryAt);

@override
String toString() {
  return 'SubmitState(status: $status, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class $SubmitStateCopyWith<$Res>  {
  factory $SubmitStateCopyWith(SubmitState value, $Res Function(SubmitState) _then) = _$SubmitStateCopyWithImpl;
@useResult
$Res call({
 SubmitStatus status, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class _$SubmitStateCopyWithImpl<$Res>
    implements $SubmitStateCopyWith<$Res> {
  _$SubmitStateCopyWithImpl(this._self, this._then);

  final SubmitState _self;
  final $Res Function(SubmitState) _then;

/// Create a copy of SubmitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubmitStatus,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubmitState].
extension SubmitStatePatterns on SubmitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubmitState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubmitState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubmitState value)  $default,){
final _that = this;
switch (_that) {
case _SubmitState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubmitState value)?  $default,){
final _that = this;
switch (_that) {
case _SubmitState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SubmitStatus status,  Failure? failure,  DateTime? retryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubmitState() when $default != null:
return $default(_that.status,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SubmitStatus status,  Failure? failure,  DateTime? retryAt)  $default,) {final _that = this;
switch (_that) {
case _SubmitState():
return $default(_that.status,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SubmitStatus status,  Failure? failure,  DateTime? retryAt)?  $default,) {final _that = this;
switch (_that) {
case _SubmitState() when $default != null:
return $default(_that.status,_that.failure,_that.retryAt);case _:
  return null;

}
}

}

/// @nodoc


class _SubmitState extends SubmitState {
  const _SubmitState({this.status = SubmitStatus.idle, this.failure, this.retryAt}): super._();
  

@override@JsonKey() final  SubmitStatus status;
@override final  Failure? failure;
/// After a `429`: no new request before this time (final.md Section
/// 15.4: a countdown from `Retry-After`, then a retry is allowed).
@override final  DateTime? retryAt;

/// Create a copy of SubmitState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubmitStateCopyWith<_SubmitState> get copyWith => __$SubmitStateCopyWithImpl<_SubmitState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubmitState&&(identical(other.status, status) || other.status == status)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,failure,retryAt);

@override
String toString() {
  return 'SubmitState(status: $status, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class _$SubmitStateCopyWith<$Res> implements $SubmitStateCopyWith<$Res> {
  factory _$SubmitStateCopyWith(_SubmitState value, $Res Function(_SubmitState) _then) = __$SubmitStateCopyWithImpl;
@override @useResult
$Res call({
 SubmitStatus status, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class __$SubmitStateCopyWithImpl<$Res>
    implements _$SubmitStateCopyWith<$Res> {
  __$SubmitStateCopyWithImpl(this._self, this._then);

  final _SubmitState _self;
  final $Res Function(_SubmitState) _then;

/// Create a copy of SubmitState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_SubmitState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubmitStatus,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
