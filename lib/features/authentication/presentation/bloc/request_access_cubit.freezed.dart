// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_access_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestAccessState {

 AccessStage get stage; List<RequestableRole> get roles; bool get busy; Failure? get failure; DateTime? get retryAt; String? get email; int get codeVersion;/// The role list was answered at least once. An empty [roles] means
/// "none can be asked for" only then; before, the load failed or runs.
 bool get rolesLoaded;/// The waits of a `429` on asking for a code and on sending the
/// request: the limits are counted apart, so one never blocks the
/// other.
 DateTime? get codeRetryAt; DateTime? get submitRetryAt;
/// Create a copy of RequestAccessState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestAccessStateCopyWith<RequestAccessState> get copyWith => _$RequestAccessStateCopyWithImpl<RequestAccessState>(this as RequestAccessState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestAccessState&&(identical(other.stage, stage) || other.stage == stage)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt)&&(identical(other.email, email) || other.email == email)&&(identical(other.codeVersion, codeVersion) || other.codeVersion == codeVersion)&&(identical(other.rolesLoaded, rolesLoaded) || other.rolesLoaded == rolesLoaded)&&(identical(other.codeRetryAt, codeRetryAt) || other.codeRetryAt == codeRetryAt)&&(identical(other.submitRetryAt, submitRetryAt) || other.submitRetryAt == submitRetryAt));
}


@override
int get hashCode => Object.hash(runtimeType,stage,const DeepCollectionEquality().hash(roles),busy,failure,retryAt,email,codeVersion,rolesLoaded,codeRetryAt,submitRetryAt);

@override
String toString() {
  return 'RequestAccessState(stage: $stage, roles: $roles, busy: $busy, failure: $failure, retryAt: $retryAt, email: $email, codeVersion: $codeVersion, rolesLoaded: $rolesLoaded, codeRetryAt: $codeRetryAt, submitRetryAt: $submitRetryAt)';
}


}

/// @nodoc
abstract mixin class $RequestAccessStateCopyWith<$Res>  {
  factory $RequestAccessStateCopyWith(RequestAccessState value, $Res Function(RequestAccessState) _then) = _$RequestAccessStateCopyWithImpl;
@useResult
$Res call({
 AccessStage stage, List<RequestableRole> roles, bool busy, Failure? failure, DateTime? retryAt, String? email, int codeVersion, bool rolesLoaded, DateTime? codeRetryAt, DateTime? submitRetryAt
});




}
/// @nodoc
class _$RequestAccessStateCopyWithImpl<$Res>
    implements $RequestAccessStateCopyWith<$Res> {
  _$RequestAccessStateCopyWithImpl(this._self, this._then);

  final RequestAccessState _self;
  final $Res Function(RequestAccessState) _then;

/// Create a copy of RequestAccessState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? roles = null,Object? busy = null,Object? failure = freezed,Object? retryAt = freezed,Object? email = freezed,Object? codeVersion = null,Object? rolesLoaded = null,Object? codeRetryAt = freezed,Object? submitRetryAt = freezed,}) {
  return _then(_self.copyWith(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as AccessStage,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<RequestableRole>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,codeVersion: null == codeVersion ? _self.codeVersion : codeVersion // ignore: cast_nullable_to_non_nullable
as int,rolesLoaded: null == rolesLoaded ? _self.rolesLoaded : rolesLoaded // ignore: cast_nullable_to_non_nullable
as bool,codeRetryAt: freezed == codeRetryAt ? _self.codeRetryAt : codeRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,submitRetryAt: freezed == submitRetryAt ? _self.submitRetryAt : submitRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestAccessState].
extension RequestAccessStatePatterns on RequestAccessState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestAccessState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestAccessState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestAccessState value)  $default,){
final _that = this;
switch (_that) {
case _RequestAccessState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestAccessState value)?  $default,){
final _that = this;
switch (_that) {
case _RequestAccessState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccessStage stage,  List<RequestableRole> roles,  bool busy,  Failure? failure,  DateTime? retryAt,  String? email,  int codeVersion,  bool rolesLoaded,  DateTime? codeRetryAt,  DateTime? submitRetryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestAccessState() when $default != null:
return $default(_that.stage,_that.roles,_that.busy,_that.failure,_that.retryAt,_that.email,_that.codeVersion,_that.rolesLoaded,_that.codeRetryAt,_that.submitRetryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccessStage stage,  List<RequestableRole> roles,  bool busy,  Failure? failure,  DateTime? retryAt,  String? email,  int codeVersion,  bool rolesLoaded,  DateTime? codeRetryAt,  DateTime? submitRetryAt)  $default,) {final _that = this;
switch (_that) {
case _RequestAccessState():
return $default(_that.stage,_that.roles,_that.busy,_that.failure,_that.retryAt,_that.email,_that.codeVersion,_that.rolesLoaded,_that.codeRetryAt,_that.submitRetryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccessStage stage,  List<RequestableRole> roles,  bool busy,  Failure? failure,  DateTime? retryAt,  String? email,  int codeVersion,  bool rolesLoaded,  DateTime? codeRetryAt,  DateTime? submitRetryAt)?  $default,) {final _that = this;
switch (_that) {
case _RequestAccessState() when $default != null:
return $default(_that.stage,_that.roles,_that.busy,_that.failure,_that.retryAt,_that.email,_that.codeVersion,_that.rolesLoaded,_that.codeRetryAt,_that.submitRetryAt);case _:
  return null;

}
}

}

/// @nodoc


class _RequestAccessState extends RequestAccessState {
  const _RequestAccessState({this.stage = AccessStage.loading, final  List<RequestableRole> roles = const <RequestableRole>[], this.busy = false, this.failure, this.retryAt, this.email, this.codeVersion = 0, this.rolesLoaded = false, this.codeRetryAt, this.submitRetryAt}): _roles = roles,super._();
  

@override@JsonKey() final  AccessStage stage;
 final  List<RequestableRole> _roles;
@override@JsonKey() List<RequestableRole> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override@JsonKey() final  bool busy;
@override final  Failure? failure;
@override final  DateTime? retryAt;
@override final  String? email;
@override@JsonKey() final  int codeVersion;
/// The role list was answered at least once. An empty [roles] means
/// "none can be asked for" only then; before, the load failed or runs.
@override@JsonKey() final  bool rolesLoaded;
/// The waits of a `429` on asking for a code and on sending the
/// request: the limits are counted apart, so one never blocks the
/// other.
@override final  DateTime? codeRetryAt;
@override final  DateTime? submitRetryAt;

/// Create a copy of RequestAccessState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestAccessStateCopyWith<_RequestAccessState> get copyWith => __$RequestAccessStateCopyWithImpl<_RequestAccessState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestAccessState&&(identical(other.stage, stage) || other.stage == stage)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt)&&(identical(other.email, email) || other.email == email)&&(identical(other.codeVersion, codeVersion) || other.codeVersion == codeVersion)&&(identical(other.rolesLoaded, rolesLoaded) || other.rolesLoaded == rolesLoaded)&&(identical(other.codeRetryAt, codeRetryAt) || other.codeRetryAt == codeRetryAt)&&(identical(other.submitRetryAt, submitRetryAt) || other.submitRetryAt == submitRetryAt));
}


@override
int get hashCode => Object.hash(runtimeType,stage,const DeepCollectionEquality().hash(_roles),busy,failure,retryAt,email,codeVersion,rolesLoaded,codeRetryAt,submitRetryAt);

@override
String toString() {
  return 'RequestAccessState(stage: $stage, roles: $roles, busy: $busy, failure: $failure, retryAt: $retryAt, email: $email, codeVersion: $codeVersion, rolesLoaded: $rolesLoaded, codeRetryAt: $codeRetryAt, submitRetryAt: $submitRetryAt)';
}


}

/// @nodoc
abstract mixin class _$RequestAccessStateCopyWith<$Res> implements $RequestAccessStateCopyWith<$Res> {
  factory _$RequestAccessStateCopyWith(_RequestAccessState value, $Res Function(_RequestAccessState) _then) = __$RequestAccessStateCopyWithImpl;
@override @useResult
$Res call({
 AccessStage stage, List<RequestableRole> roles, bool busy, Failure? failure, DateTime? retryAt, String? email, int codeVersion, bool rolesLoaded, DateTime? codeRetryAt, DateTime? submitRetryAt
});




}
/// @nodoc
class __$RequestAccessStateCopyWithImpl<$Res>
    implements _$RequestAccessStateCopyWith<$Res> {
  __$RequestAccessStateCopyWithImpl(this._self, this._then);

  final _RequestAccessState _self;
  final $Res Function(_RequestAccessState) _then;

/// Create a copy of RequestAccessState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? roles = null,Object? busy = null,Object? failure = freezed,Object? retryAt = freezed,Object? email = freezed,Object? codeVersion = null,Object? rolesLoaded = null,Object? codeRetryAt = freezed,Object? submitRetryAt = freezed,}) {
  return _then(_RequestAccessState(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as AccessStage,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<RequestableRole>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,codeVersion: null == codeVersion ? _self.codeVersion : codeVersion // ignore: cast_nullable_to_non_nullable
as int,rolesLoaded: null == rolesLoaded ? _self.rolesLoaded : rolesLoaded // ignore: cast_nullable_to_non_nullable
as bool,codeRetryAt: freezed == codeRetryAt ? _self.codeRetryAt : codeRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,submitRetryAt: freezed == submitRetryAt ? _self.submitRetryAt : submitRetryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
