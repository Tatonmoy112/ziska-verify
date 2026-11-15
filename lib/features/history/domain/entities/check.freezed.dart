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
mixin _$CheckQuery {

 CheckResult? get result; CheckWay? get way;/// Calendar days, both included.
 DateTime? get from; DateTime? get to;/// A serial or a reference number.
 String? get search; CheckScope get scope;
/// Create a copy of CheckQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckQueryCopyWith<CheckQuery> get copyWith => _$CheckQueryCopyWithImpl<CheckQuery>(this as CheckQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckQuery&&(identical(other.result, result) || other.result == result)&&(identical(other.way, way) || other.way == way)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.search, search) || other.search == search)&&(identical(other.scope, scope) || other.scope == scope));
}


@override
int get hashCode => Object.hash(runtimeType,result,way,from,to,search,scope);

@override
String toString() {
  return 'CheckQuery(result: $result, way: $way, from: $from, to: $to, search: $search, scope: $scope)';
}


}

/// @nodoc
abstract mixin class $CheckQueryCopyWith<$Res>  {
  factory $CheckQueryCopyWith(CheckQuery value, $Res Function(CheckQuery) _then) = _$CheckQueryCopyWithImpl;
@useResult
$Res call({
 CheckResult? result, CheckWay? way, DateTime? from, DateTime? to, String? search, CheckScope scope
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
@pragma('vm:prefer-inline') @override $Res call({Object? result = freezed,Object? way = freezed,Object? from = freezed,Object? to = freezed,Object? search = freezed,Object? scope = null,}) {
  return _then(_self.copyWith(
result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CheckResult?,way: freezed == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as CheckWay?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as CheckScope,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CheckResult? result,  CheckWay? way,  DateTime? from,  DateTime? to,  String? search,  CheckScope scope)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckQuery() when $default != null:
return $default(_that.result,_that.way,_that.from,_that.to,_that.search,_that.scope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CheckResult? result,  CheckWay? way,  DateTime? from,  DateTime? to,  String? search,  CheckScope scope)  $default,) {final _that = this;
switch (_that) {
case _CheckQuery():
return $default(_that.result,_that.way,_that.from,_that.to,_that.search,_that.scope);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CheckResult? result,  CheckWay? way,  DateTime? from,  DateTime? to,  String? search,  CheckScope scope)?  $default,) {final _that = this;
switch (_that) {
case _CheckQuery() when $default != null:
return $default(_that.result,_that.way,_that.from,_that.to,_that.search,_that.scope);case _:
  return null;

}
}

}

/// @nodoc


class _CheckQuery extends CheckQuery {
  const _CheckQuery({this.result, this.way, this.from, this.to, this.search, this.scope = CheckScope.own}): super._();
  

@override final  CheckResult? result;
@override final  CheckWay? way;
/// Calendar days, both included.
@override final  DateTime? from;
@override final  DateTime? to;
/// A serial or a reference number.
@override final  String? search;
@override@JsonKey() final  CheckScope scope;

/// Create a copy of CheckQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckQueryCopyWith<_CheckQuery> get copyWith => __$CheckQueryCopyWithImpl<_CheckQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckQuery&&(identical(other.result, result) || other.result == result)&&(identical(other.way, way) || other.way == way)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.search, search) || other.search == search)&&(identical(other.scope, scope) || other.scope == scope));
}


@override
int get hashCode => Object.hash(runtimeType,result,way,from,to,search,scope);

@override
String toString() {
  return 'CheckQuery(result: $result, way: $way, from: $from, to: $to, search: $search, scope: $scope)';
}


}

/// @nodoc
abstract mixin class _$CheckQueryCopyWith<$Res> implements $CheckQueryCopyWith<$Res> {
  factory _$CheckQueryCopyWith(_CheckQuery value, $Res Function(_CheckQuery) _then) = __$CheckQueryCopyWithImpl;
@override @useResult
$Res call({
 CheckResult? result, CheckWay? way, DateTime? from, DateTime? to, String? search, CheckScope scope
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
@override @pragma('vm:prefer-inline') $Res call({Object? result = freezed,Object? way = freezed,Object? from = freezed,Object? to = freezed,Object? search = freezed,Object? scope = null,}) {
  return _then(_CheckQuery(
result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as CheckResult?,way: freezed == way ? _self.way : way // ignore: cast_nullable_to_non_nullable
as CheckWay?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as CheckScope,
  ));
}


}

// dart format on
