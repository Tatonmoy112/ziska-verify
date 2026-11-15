// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_code_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerifyCodeState {

 SubmitState get submit;/// When "Send the code again" becomes available.
 DateTime? get resendAvailableAt; bool get resending; Failure? get resendFailure;/// Increments on every successful resend, to show "A new code was
/// sent." once.
 int get resentCount;/// The 3 resends are used up: the official must log in again.
 bool get resendLimitReached;
/// Create a copy of VerifyCodeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerifyCodeStateCopyWith<VerifyCodeState> get copyWith => _$VerifyCodeStateCopyWithImpl<VerifyCodeState>(this as VerifyCodeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerifyCodeState&&(identical(other.submit, submit) || other.submit == submit)&&(identical(other.resendAvailableAt, resendAvailableAt) || other.resendAvailableAt == resendAvailableAt)&&(identical(other.resending, resending) || other.resending == resending)&&(identical(other.resendFailure, resendFailure) || other.resendFailure == resendFailure)&&(identical(other.resentCount, resentCount) || other.resentCount == resentCount)&&(identical(other.resendLimitReached, resendLimitReached) || other.resendLimitReached == resendLimitReached));
}


@override
int get hashCode => Object.hash(runtimeType,submit,resendAvailableAt,resending,resendFailure,resentCount,resendLimitReached);

@override
String toString() {
  return 'VerifyCodeState(submit: $submit, resendAvailableAt: $resendAvailableAt, resending: $resending, resendFailure: $resendFailure, resentCount: $resentCount, resendLimitReached: $resendLimitReached)';
}


}

/// @nodoc
abstract mixin class $VerifyCodeStateCopyWith<$Res>  {
  factory $VerifyCodeStateCopyWith(VerifyCodeState value, $Res Function(VerifyCodeState) _then) = _$VerifyCodeStateCopyWithImpl;
@useResult
$Res call({
 SubmitState submit, DateTime? resendAvailableAt, bool resending, Failure? resendFailure, int resentCount, bool resendLimitReached
});


$SubmitStateCopyWith<$Res> get submit;

}
/// @nodoc
class _$VerifyCodeStateCopyWithImpl<$Res>
    implements $VerifyCodeStateCopyWith<$Res> {
  _$VerifyCodeStateCopyWithImpl(this._self, this._then);

  final VerifyCodeState _self;
  final $Res Function(VerifyCodeState) _then;

/// Create a copy of VerifyCodeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? submit = null,Object? resendAvailableAt = freezed,Object? resending = null,Object? resendFailure = freezed,Object? resentCount = null,Object? resendLimitReached = null,}) {
  return _then(_self.copyWith(
submit: null == submit ? _self.submit : submit // ignore: cast_nullable_to_non_nullable
as SubmitState,resendAvailableAt: freezed == resendAvailableAt ? _self.resendAvailableAt : resendAvailableAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resending: null == resending ? _self.resending : resending // ignore: cast_nullable_to_non_nullable
as bool,resendFailure: freezed == resendFailure ? _self.resendFailure : resendFailure // ignore: cast_nullable_to_non_nullable
as Failure?,resentCount: null == resentCount ? _self.resentCount : resentCount // ignore: cast_nullable_to_non_nullable
as int,resendLimitReached: null == resendLimitReached ? _self.resendLimitReached : resendLimitReached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of VerifyCodeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubmitStateCopyWith<$Res> get submit {
  
  return $SubmitStateCopyWith<$Res>(_self.submit, (value) {
    return _then(_self.copyWith(submit: value));
  });
}
}


/// Adds pattern-matching-related methods to [VerifyCodeState].
extension VerifyCodeStatePatterns on VerifyCodeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerifyCodeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerifyCodeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerifyCodeState value)  $default,){
final _that = this;
switch (_that) {
case _VerifyCodeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerifyCodeState value)?  $default,){
final _that = this;
switch (_that) {
case _VerifyCodeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SubmitState submit,  DateTime? resendAvailableAt,  bool resending,  Failure? resendFailure,  int resentCount,  bool resendLimitReached)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerifyCodeState() when $default != null:
return $default(_that.submit,_that.resendAvailableAt,_that.resending,_that.resendFailure,_that.resentCount,_that.resendLimitReached);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SubmitState submit,  DateTime? resendAvailableAt,  bool resending,  Failure? resendFailure,  int resentCount,  bool resendLimitReached)  $default,) {final _that = this;
switch (_that) {
case _VerifyCodeState():
return $default(_that.submit,_that.resendAvailableAt,_that.resending,_that.resendFailure,_that.resentCount,_that.resendLimitReached);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SubmitState submit,  DateTime? resendAvailableAt,  bool resending,  Failure? resendFailure,  int resentCount,  bool resendLimitReached)?  $default,) {final _that = this;
switch (_that) {
case _VerifyCodeState() when $default != null:
return $default(_that.submit,_that.resendAvailableAt,_that.resending,_that.resendFailure,_that.resentCount,_that.resendLimitReached);case _:
  return null;

}
}

}

/// @nodoc


class _VerifyCodeState implements VerifyCodeState {
  const _VerifyCodeState({this.submit = const SubmitState(), this.resendAvailableAt, this.resending = false, this.resendFailure, this.resentCount = 0, this.resendLimitReached = false});
  

@override@JsonKey() final  SubmitState submit;
/// When "Send the code again" becomes available.
@override final  DateTime? resendAvailableAt;
@override@JsonKey() final  bool resending;
@override final  Failure? resendFailure;
/// Increments on every successful resend, to show "A new code was
/// sent." once.
@override@JsonKey() final  int resentCount;
/// The 3 resends are used up: the official must log in again.
@override@JsonKey() final  bool resendLimitReached;

/// Create a copy of VerifyCodeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerifyCodeStateCopyWith<_VerifyCodeState> get copyWith => __$VerifyCodeStateCopyWithImpl<_VerifyCodeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerifyCodeState&&(identical(other.submit, submit) || other.submit == submit)&&(identical(other.resendAvailableAt, resendAvailableAt) || other.resendAvailableAt == resendAvailableAt)&&(identical(other.resending, resending) || other.resending == resending)&&(identical(other.resendFailure, resendFailure) || other.resendFailure == resendFailure)&&(identical(other.resentCount, resentCount) || other.resentCount == resentCount)&&(identical(other.resendLimitReached, resendLimitReached) || other.resendLimitReached == resendLimitReached));
}


@override
int get hashCode => Object.hash(runtimeType,submit,resendAvailableAt,resending,resendFailure,resentCount,resendLimitReached);

@override
String toString() {
  return 'VerifyCodeState(submit: $submit, resendAvailableAt: $resendAvailableAt, resending: $resending, resendFailure: $resendFailure, resentCount: $resentCount, resendLimitReached: $resendLimitReached)';
}


}

/// @nodoc
abstract mixin class _$VerifyCodeStateCopyWith<$Res> implements $VerifyCodeStateCopyWith<$Res> {
  factory _$VerifyCodeStateCopyWith(_VerifyCodeState value, $Res Function(_VerifyCodeState) _then) = __$VerifyCodeStateCopyWithImpl;
@override @useResult
$Res call({
 SubmitState submit, DateTime? resendAvailableAt, bool resending, Failure? resendFailure, int resentCount, bool resendLimitReached
});


@override $SubmitStateCopyWith<$Res> get submit;

}
/// @nodoc
class __$VerifyCodeStateCopyWithImpl<$Res>
    implements _$VerifyCodeStateCopyWith<$Res> {
  __$VerifyCodeStateCopyWithImpl(this._self, this._then);

  final _VerifyCodeState _self;
  final $Res Function(_VerifyCodeState) _then;

/// Create a copy of VerifyCodeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? submit = null,Object? resendAvailableAt = freezed,Object? resending = null,Object? resendFailure = freezed,Object? resentCount = null,Object? resendLimitReached = null,}) {
  return _then(_VerifyCodeState(
submit: null == submit ? _self.submit : submit // ignore: cast_nullable_to_non_nullable
as SubmitState,resendAvailableAt: freezed == resendAvailableAt ? _self.resendAvailableAt : resendAvailableAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resending: null == resending ? _self.resending : resending // ignore: cast_nullable_to_non_nullable
as bool,resendFailure: freezed == resendFailure ? _self.resendFailure : resendFailure // ignore: cast_nullable_to_non_nullable
as Failure?,resentCount: null == resentCount ? _self.resentCount : resentCount // ignore: cast_nullable_to_non_nullable
as int,resendLimitReached: null == resendLimitReached ? _self.resendLimitReached : resendLimitReached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of VerifyCodeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubmitStateCopyWith<$Res> get submit {
  
  return $SubmitStateCopyWith<$Res>(_self.submit, (value) {
    return _then(_self.copyWith(submit: value));
  });
}
}

// dart format on
