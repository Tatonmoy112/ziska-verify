// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prepared_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreparedInput {

 LookupWay get way;
/// Create a copy of PreparedInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreparedInputCopyWith<PreparedInput> get copyWith => _$PreparedInputCopyWithImpl<PreparedInput>(this as PreparedInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreparedInput&&(identical(other.way, way) || other.way == way));
}


@override
int get hashCode => Object.hash(runtimeType,way);

@override
String toString() {
  return 'PreparedInput(way: $way)';
}


}

/// @nodoc
abstract mixin class $PreparedInputCopyWith<$Res>  {
  factory $PreparedInputCopyWith(PreparedInput value, $Res Function(PreparedInput) _then) = _$PreparedInputCopyWithImpl;
@useResult
$Res call({
 LookupWay way
});




}
/// @nodoc
class _$PreparedInputCopyWithImpl<$Res>
    implements $PreparedInputCopyWith<$Res> {
  _$PreparedInputCopyWithImpl(this._self, this._then);

  final PreparedInput _self;
  final $Res Function(PreparedInput) _then;

/// Create a copy of PreparedInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? way = null,}) {
  return _then(_self.copyWith(
way: null == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as LookupWay,
  ));
}

}


/// Adds pattern-matching-related methods to [PreparedInput].
extension PreparedInputPatterns on PreparedInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ReadyInput value)?  ready,TResult Function( RefusedInput value)?  refused,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ReadyInput() when ready != null:
return ready(_that);case RefusedInput() when refused != null:
return refused(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ReadyInput value)  ready,required TResult Function( RefusedInput value)  refused,}){
final _that = this;
switch (_that) {
case ReadyInput():
return ready(_that);case RefusedInput():
return refused(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ReadyInput value)?  ready,TResult? Function( RefusedInput value)?  refused,}){
final _that = this;
switch (_that) {
case ReadyInput() when ready != null:
return ready(_that);case RefusedInput() when refused != null:
return refused(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LookupWay way,  String value)?  ready,TResult Function( LookupWay way,  InputProblem problem)?  refused,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ReadyInput() when ready != null:
return ready(_that.way,_that.value);case RefusedInput() when refused != null:
return refused(_that.way,_that.problem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LookupWay way,  String value)  ready,required TResult Function( LookupWay way,  InputProblem problem)  refused,}) {final _that = this;
switch (_that) {
case ReadyInput():
return ready(_that.way,_that.value);case RefusedInput():
return refused(_that.way,_that.problem);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LookupWay way,  String value)?  ready,TResult? Function( LookupWay way,  InputProblem problem)?  refused,}) {final _that = this;
switch (_that) {
case ReadyInput() when ready != null:
return ready(_that.way,_that.value);case RefusedInput() when refused != null:
return refused(_that.way,_that.problem);case _:
  return null;

}
}

}

/// @nodoc


class ReadyInput implements PreparedInput {
  const ReadyInput(this.way, this.value);
  

@override final  LookupWay way;
 final  String value;

/// Create a copy of PreparedInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadyInputCopyWith<ReadyInput> get copyWith => _$ReadyInputCopyWithImpl<ReadyInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadyInput&&(identical(other.way, way) || other.way == way)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,way,value);

@override
String toString() {
  return 'PreparedInput.ready(way: $way, value: $value)';
}


}

/// @nodoc
abstract mixin class $ReadyInputCopyWith<$Res> implements $PreparedInputCopyWith<$Res> {
  factory $ReadyInputCopyWith(ReadyInput value, $Res Function(ReadyInput) _then) = _$ReadyInputCopyWithImpl;
@override @useResult
$Res call({
 LookupWay way, String value
});




}
/// @nodoc
class _$ReadyInputCopyWithImpl<$Res>
    implements $ReadyInputCopyWith<$Res> {
  _$ReadyInputCopyWithImpl(this._self, this._then);

  final ReadyInput _self;
  final $Res Function(ReadyInput) _then;

/// Create a copy of PreparedInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? way = null,Object? value = null,}) {
  return _then(ReadyInput(
null == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as LookupWay,null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RefusedInput implements PreparedInput {
  const RefusedInput(this.way, this.problem);
  

@override final  LookupWay way;
 final  InputProblem problem;

/// Create a copy of PreparedInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefusedInputCopyWith<RefusedInput> get copyWith => _$RefusedInputCopyWithImpl<RefusedInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefusedInput&&(identical(other.way, way) || other.way == way)&&(identical(other.problem, problem) || other.problem == problem));
}


@override
int get hashCode => Object.hash(runtimeType,way,problem);

@override
String toString() {
  return 'PreparedInput.refused(way: $way, problem: $problem)';
}


}

/// @nodoc
abstract mixin class $RefusedInputCopyWith<$Res> implements $PreparedInputCopyWith<$Res> {
  factory $RefusedInputCopyWith(RefusedInput value, $Res Function(RefusedInput) _then) = _$RefusedInputCopyWithImpl;
@override @useResult
$Res call({
 LookupWay way, InputProblem problem
});




}
/// @nodoc
class _$RefusedInputCopyWithImpl<$Res>
    implements $RefusedInputCopyWith<$Res> {
  _$RefusedInputCopyWithImpl(this._self, this._then);

  final RefusedInput _self;
  final $Res Function(RefusedInput) _then;

/// Create a copy of PreparedInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? way = null,Object? problem = null,}) {
  return _then(RefusedInput(
null == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as LookupWay,null == problem ? _self.problem : problem // ignore: cast_nullable_to_non_nullable
as InputProblem,
  ));
}


}

// dart format on
