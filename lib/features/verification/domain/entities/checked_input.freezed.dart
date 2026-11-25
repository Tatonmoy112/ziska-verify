// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checked_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CheckedInput {

 LookupWay get way; String get shown; DateTime get at;
/// Create a copy of CheckedInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckedInputCopyWith<CheckedInput> get copyWith => _$CheckedInputCopyWithImpl<CheckedInput>(this as CheckedInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckedInput&&(identical(other.way, way) || other.way == way)&&(identical(other.shown, shown) || other.shown == shown)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,way,shown,at);

@override
String toString() {
  return 'CheckedInput(way: $way, shown: $shown, at: $at)';
}


}

/// @nodoc
abstract mixin class $CheckedInputCopyWith<$Res>  {
  factory $CheckedInputCopyWith(CheckedInput value, $Res Function(CheckedInput) _then) = _$CheckedInputCopyWithImpl;
@useResult
$Res call({
 LookupWay way, String shown, DateTime at
});




}
/// @nodoc
class _$CheckedInputCopyWithImpl<$Res>
    implements $CheckedInputCopyWith<$Res> {
  _$CheckedInputCopyWithImpl(this._self, this._then);

  final CheckedInput _self;
  final $Res Function(CheckedInput) _then;

/// Create a copy of CheckedInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? way = null,Object? shown = null,Object? at = null,}) {
  return _then(_self.copyWith(
way: null == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as LookupWay,shown: null == shown ? _self.shown : shown // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckedInput].
extension CheckedInputPatterns on CheckedInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckedInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckedInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckedInput value)  $default,){
final _that = this;
switch (_that) {
case _CheckedInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckedInput value)?  $default,){
final _that = this;
switch (_that) {
case _CheckedInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LookupWay way,  String shown,  DateTime at)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckedInput() when $default != null:
return $default(_that.way,_that.shown,_that.at);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LookupWay way,  String shown,  DateTime at)  $default,) {final _that = this;
switch (_that) {
case _CheckedInput():
return $default(_that.way,_that.shown,_that.at);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LookupWay way,  String shown,  DateTime at)?  $default,) {final _that = this;
switch (_that) {
case _CheckedInput() when $default != null:
return $default(_that.way,_that.shown,_that.at);case _:
  return null;

}
}

}

/// @nodoc


class _CheckedInput implements CheckedInput {
  const _CheckedInput({required this.way, required this.shown, required this.at});
  

@override final  LookupWay way;
@override final  String shown;
@override final  DateTime at;

/// Create a copy of CheckedInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckedInputCopyWith<_CheckedInput> get copyWith => __$CheckedInputCopyWithImpl<_CheckedInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckedInput&&(identical(other.way, way) || other.way == way)&&(identical(other.shown, shown) || other.shown == shown)&&(identical(other.at, at) || other.at == at));
}


@override
int get hashCode => Object.hash(runtimeType,way,shown,at);

@override
String toString() {
  return 'CheckedInput(way: $way, shown: $shown, at: $at)';
}


}

/// @nodoc
abstract mixin class _$CheckedInputCopyWith<$Res> implements $CheckedInputCopyWith<$Res> {
  factory _$CheckedInputCopyWith(_CheckedInput value, $Res Function(_CheckedInput) _then) = __$CheckedInputCopyWithImpl;
@override @useResult
$Res call({
 LookupWay way, String shown, DateTime at
});




}
/// @nodoc
class __$CheckedInputCopyWithImpl<$Res>
    implements _$CheckedInputCopyWith<$Res> {
  __$CheckedInputCopyWithImpl(this._self, this._then);

  final _CheckedInput _self;
  final $Res Function(_CheckedInput) _then;

/// Create a copy of CheckedInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? way = null,Object? shown = null,Object? at = null,}) {
  return _then(_CheckedInput(
way: null == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as LookupWay,shown: null == shown ? _self.shown : shown // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
