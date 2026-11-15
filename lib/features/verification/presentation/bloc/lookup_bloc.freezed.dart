// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lookup_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LookupState {

 InputFormats? get formats; bool get formatsLoading; Failure? get formatsFailure; LookupStatus get status; LookupResult? get result;/// What the [result] answers: the way, the value as sent (a hidden code
/// masked), and when (final.md Section 13.1.4).
 CheckedInput? get checked; Failure? get failure; RefusedInput? get refused;/// After a `429`: when the next lookup may be sent (`Retry-After`).
 DateTime? get retryAt;
/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LookupStateCopyWith<LookupState> get copyWith => _$LookupStateCopyWithImpl<LookupState>(this as LookupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupState&&(identical(other.formats, formats) || other.formats == formats)&&(identical(other.formatsLoading, formatsLoading) || other.formatsLoading == formatsLoading)&&(identical(other.formatsFailure, formatsFailure) || other.formatsFailure == formatsFailure)&&(identical(other.status, status) || other.status == status)&&(identical(other.result, result) || other.result == result)&&(identical(other.checked, checked) || other.checked == checked)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.refused, refused) || other.refused == refused)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,formats,formatsLoading,formatsFailure,status,result,checked,failure,refused,retryAt);

@override
String toString() {
  return 'LookupState(formats: $formats, formatsLoading: $formatsLoading, formatsFailure: $formatsFailure, status: $status, result: $result, checked: $checked, failure: $failure, refused: $refused, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class $LookupStateCopyWith<$Res>  {
  factory $LookupStateCopyWith(LookupState value, $Res Function(LookupState) _then) = _$LookupStateCopyWithImpl;
@useResult
$Res call({
 InputFormats? formats, bool formatsLoading, Failure? formatsFailure, LookupStatus status, LookupResult? result, CheckedInput? checked, Failure? failure, RefusedInput? refused, DateTime? retryAt
});




}
/// @nodoc
class _$LookupStateCopyWithImpl<$Res>
    implements $LookupStateCopyWith<$Res> {
  _$LookupStateCopyWithImpl(this._self, this._then);

  final LookupState _self;
  final $Res Function(LookupState) _then;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? formats = freezed,Object? formatsLoading = null,Object? formatsFailure = freezed,Object? status = null,Object? result = freezed,Object? checked = freezed,Object? failure = freezed,Object? refused = freezed,Object? retryAt = freezed,}) {
  return _then(_self.copyWith(
formats: freezed == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as InputFormats?,formatsLoading: null == formatsLoading ? _self.formatsLoading : formatsLoading // ignore: cast_nullable_to_non_nullable
as bool,formatsFailure: freezed == formatsFailure ? _self.formatsFailure : formatsFailure // ignore: cast_nullable_to_non_nullable
as Failure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LookupStatus,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as LookupResult?,checked: freezed == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as CheckedInput?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,refused: freezed == refused ? _self.refused : refused // ignore: cast_nullable_to_non_nullable
as RefusedInput?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LookupState].
extension LookupStatePatterns on LookupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LookupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LookupState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LookupState value)  $default,){
final _that = this;
switch (_that) {
case _LookupState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LookupState value)?  $default,){
final _that = this;
switch (_that) {
case _LookupState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InputFormats? formats,  bool formatsLoading,  Failure? formatsFailure,  LookupStatus status,  LookupResult? result,  CheckedInput? checked,  Failure? failure,  RefusedInput? refused,  DateTime? retryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LookupState() when $default != null:
return $default(_that.formats,_that.formatsLoading,_that.formatsFailure,_that.status,_that.result,_that.checked,_that.failure,_that.refused,_that.retryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InputFormats? formats,  bool formatsLoading,  Failure? formatsFailure,  LookupStatus status,  LookupResult? result,  CheckedInput? checked,  Failure? failure,  RefusedInput? refused,  DateTime? retryAt)  $default,) {final _that = this;
switch (_that) {
case _LookupState():
return $default(_that.formats,_that.formatsLoading,_that.formatsFailure,_that.status,_that.result,_that.checked,_that.failure,_that.refused,_that.retryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InputFormats? formats,  bool formatsLoading,  Failure? formatsFailure,  LookupStatus status,  LookupResult? result,  CheckedInput? checked,  Failure? failure,  RefusedInput? refused,  DateTime? retryAt)?  $default,) {final _that = this;
switch (_that) {
case _LookupState() when $default != null:
return $default(_that.formats,_that.formatsLoading,_that.formatsFailure,_that.status,_that.result,_that.checked,_that.failure,_that.refused,_that.retryAt);case _:
  return null;

}
}

}

/// @nodoc


class _LookupState extends LookupState {
  const _LookupState({this.formats, this.formatsLoading = false, this.formatsFailure, this.status = LookupStatus.idle, this.result, this.checked, this.failure, this.refused, this.retryAt}): super._();
  

@override final  InputFormats? formats;
@override@JsonKey() final  bool formatsLoading;
@override final  Failure? formatsFailure;
@override@JsonKey() final  LookupStatus status;
@override final  LookupResult? result;
/// What the [result] answers: the way, the value as sent (a hidden code
/// masked), and when (final.md Section 13.1.4).
@override final  CheckedInput? checked;
@override final  Failure? failure;
@override final  RefusedInput? refused;
/// After a `429`: when the next lookup may be sent (`Retry-After`).
@override final  DateTime? retryAt;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LookupStateCopyWith<_LookupState> get copyWith => __$LookupStateCopyWithImpl<_LookupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LookupState&&(identical(other.formats, formats) || other.formats == formats)&&(identical(other.formatsLoading, formatsLoading) || other.formatsLoading == formatsLoading)&&(identical(other.formatsFailure, formatsFailure) || other.formatsFailure == formatsFailure)&&(identical(other.status, status) || other.status == status)&&(identical(other.result, result) || other.result == result)&&(identical(other.checked, checked) || other.checked == checked)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.refused, refused) || other.refused == refused)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,formats,formatsLoading,formatsFailure,status,result,checked,failure,refused,retryAt);

@override
String toString() {
  return 'LookupState(formats: $formats, formatsLoading: $formatsLoading, formatsFailure: $formatsFailure, status: $status, result: $result, checked: $checked, failure: $failure, refused: $refused, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class _$LookupStateCopyWith<$Res> implements $LookupStateCopyWith<$Res> {
  factory _$LookupStateCopyWith(_LookupState value, $Res Function(_LookupState) _then) = __$LookupStateCopyWithImpl;
@override @useResult
$Res call({
 InputFormats? formats, bool formatsLoading, Failure? formatsFailure, LookupStatus status, LookupResult? result, CheckedInput? checked, Failure? failure, RefusedInput? refused, DateTime? retryAt
});




}
/// @nodoc
class __$LookupStateCopyWithImpl<$Res>
    implements _$LookupStateCopyWith<$Res> {
  __$LookupStateCopyWithImpl(this._self, this._then);

  final _LookupState _self;
  final $Res Function(_LookupState) _then;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? formats = freezed,Object? formatsLoading = null,Object? formatsFailure = freezed,Object? status = null,Object? result = freezed,Object? checked = freezed,Object? failure = freezed,Object? refused = freezed,Object? retryAt = freezed,}) {
  return _then(_LookupState(
formats: freezed == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as InputFormats?,formatsLoading: null == formatsLoading ? _self.formatsLoading : formatsLoading // ignore: cast_nullable_to_non_nullable
as bool,formatsFailure: freezed == formatsFailure ? _self.formatsFailure : formatsFailure // ignore: cast_nullable_to_non_nullable
as Failure?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LookupStatus,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as LookupResult?,checked: freezed == checked ? _self.checked : checked // ignore: cast_nullable_to_non_nullable
as CheckedInput?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,refused: freezed == refused ? _self.refused : refused // ignore: cast_nullable_to_non_nullable
as RefusedInput?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
