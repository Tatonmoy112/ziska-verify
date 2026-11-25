// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_summary_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionSummaryState {

 SessionSummaryStatus get status; ScanSessionSummary? get session; Failure? get failure;/// After a `429`: Try again sends nothing before this (guide §1).
 DateTime? get retryAt;
/// Create a copy of SessionSummaryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSummaryStateCopyWith<SessionSummaryState> get copyWith => _$SessionSummaryStateCopyWithImpl<SessionSummaryState>(this as SessionSummaryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSummaryState&&(identical(other.status, status) || other.status == status)&&(identical(other.session, session) || other.session == session)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,session,failure,retryAt);

@override
String toString() {
  return 'SessionSummaryState(status: $status, session: $session, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class $SessionSummaryStateCopyWith<$Res>  {
  factory $SessionSummaryStateCopyWith(SessionSummaryState value, $Res Function(SessionSummaryState) _then) = _$SessionSummaryStateCopyWithImpl;
@useResult
$Res call({
 SessionSummaryStatus status, ScanSessionSummary? session, Failure? failure, DateTime? retryAt
});


$ScanSessionSummaryCopyWith<$Res>? get session;

}
/// @nodoc
class _$SessionSummaryStateCopyWithImpl<$Res>
    implements $SessionSummaryStateCopyWith<$Res> {
  _$SessionSummaryStateCopyWithImpl(this._self, this._then);

  final SessionSummaryState _self;
  final $Res Function(SessionSummaryState) _then;

/// Create a copy of SessionSummaryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? session = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionSummaryStatus,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ScanSessionSummary?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SessionSummaryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanSessionSummaryCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $ScanSessionSummaryCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionSummaryState].
extension SessionSummaryStatePatterns on SessionSummaryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSummaryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSummaryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSummaryState value)  $default,){
final _that = this;
switch (_that) {
case _SessionSummaryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSummaryState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSummaryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SessionSummaryStatus status,  ScanSessionSummary? session,  Failure? failure,  DateTime? retryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSummaryState() when $default != null:
return $default(_that.status,_that.session,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SessionSummaryStatus status,  ScanSessionSummary? session,  Failure? failure,  DateTime? retryAt)  $default,) {final _that = this;
switch (_that) {
case _SessionSummaryState():
return $default(_that.status,_that.session,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SessionSummaryStatus status,  ScanSessionSummary? session,  Failure? failure,  DateTime? retryAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionSummaryState() when $default != null:
return $default(_that.status,_that.session,_that.failure,_that.retryAt);case _:
  return null;

}
}

}

/// @nodoc


class _SessionSummaryState extends SessionSummaryState {
  const _SessionSummaryState({this.status = SessionSummaryStatus.loading, this.session, this.failure, this.retryAt}): super._();
  

@override@JsonKey() final  SessionSummaryStatus status;
@override final  ScanSessionSummary? session;
@override final  Failure? failure;
/// After a `429`: Try again sends nothing before this (guide §1).
@override final  DateTime? retryAt;

/// Create a copy of SessionSummaryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSummaryStateCopyWith<_SessionSummaryState> get copyWith => __$SessionSummaryStateCopyWithImpl<_SessionSummaryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSummaryState&&(identical(other.status, status) || other.status == status)&&(identical(other.session, session) || other.session == session)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,session,failure,retryAt);

@override
String toString() {
  return 'SessionSummaryState(status: $status, session: $session, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class _$SessionSummaryStateCopyWith<$Res> implements $SessionSummaryStateCopyWith<$Res> {
  factory _$SessionSummaryStateCopyWith(_SessionSummaryState value, $Res Function(_SessionSummaryState) _then) = __$SessionSummaryStateCopyWithImpl;
@override @useResult
$Res call({
 SessionSummaryStatus status, ScanSessionSummary? session, Failure? failure, DateTime? retryAt
});


@override $ScanSessionSummaryCopyWith<$Res>? get session;

}
/// @nodoc
class __$SessionSummaryStateCopyWithImpl<$Res>
    implements _$SessionSummaryStateCopyWith<$Res> {
  __$SessionSummaryStateCopyWithImpl(this._self, this._then);

  final _SessionSummaryState _self;
  final $Res Function(_SessionSummaryState) _then;

/// Create a copy of SessionSummaryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? session = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_SessionSummaryState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionSummaryStatus,session: freezed == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as ScanSessionSummary?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SessionSummaryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScanSessionSummaryCopyWith<$Res>? get session {
    if (_self.session == null) {
    return null;
  }

  return $ScanSessionSummaryCopyWith<$Res>(_self.session!, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

// dart format on
