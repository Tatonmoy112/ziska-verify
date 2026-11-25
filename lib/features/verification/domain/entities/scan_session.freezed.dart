// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionQuery {

 ScanStatus? get status;/// Calendar days, both included.
 DateTime? get from; DateTime? get to;
/// Create a copy of SessionQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionQueryCopyWith<SessionQuery> get copyWith => _$SessionQueryCopyWithImpl<SessionQuery>(this as SessionQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionQuery&&(identical(other.status, status) || other.status == status)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,status,from,to);

@override
String toString() {
  return 'SessionQuery(status: $status, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $SessionQueryCopyWith<$Res>  {
  factory $SessionQueryCopyWith(SessionQuery value, $Res Function(SessionQuery) _then) = _$SessionQueryCopyWithImpl;
@useResult
$Res call({
 ScanStatus? status, DateTime? from, DateTime? to
});




}
/// @nodoc
class _$SessionQueryCopyWithImpl<$Res>
    implements $SessionQueryCopyWith<$Res> {
  _$SessionQueryCopyWithImpl(this._self, this._then);

  final SessionQuery _self;
  final $Res Function(SessionQuery) _then;

/// Create a copy of SessionQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? from = freezed,Object? to = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScanStatus?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionQuery].
extension SessionQueryPatterns on SessionQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionQuery value)  $default,){
final _that = this;
switch (_that) {
case _SessionQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionQuery value)?  $default,){
final _that = this;
switch (_that) {
case _SessionQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ScanStatus? status,  DateTime? from,  DateTime? to)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionQuery() when $default != null:
return $default(_that.status,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ScanStatus? status,  DateTime? from,  DateTime? to)  $default,) {final _that = this;
switch (_that) {
case _SessionQuery():
return $default(_that.status,_that.from,_that.to);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ScanStatus? status,  DateTime? from,  DateTime? to)?  $default,) {final _that = this;
switch (_that) {
case _SessionQuery() when $default != null:
return $default(_that.status,_that.from,_that.to);case _:
  return null;

}
}

}

/// @nodoc


class _SessionQuery implements SessionQuery {
  const _SessionQuery({this.status, this.from, this.to});
  

@override final  ScanStatus? status;
/// Calendar days, both included.
@override final  DateTime? from;
@override final  DateTime? to;

/// Create a copy of SessionQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionQueryCopyWith<_SessionQuery> get copyWith => __$SessionQueryCopyWithImpl<_SessionQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionQuery&&(identical(other.status, status) || other.status == status)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,status,from,to);

@override
String toString() {
  return 'SessionQuery(status: $status, from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class _$SessionQueryCopyWith<$Res> implements $SessionQueryCopyWith<$Res> {
  factory _$SessionQueryCopyWith(_SessionQuery value, $Res Function(_SessionQuery) _then) = __$SessionQueryCopyWithImpl;
@override @useResult
$Res call({
 ScanStatus? status, DateTime? from, DateTime? to
});




}
/// @nodoc
class __$SessionQueryCopyWithImpl<$Res>
    implements _$SessionQueryCopyWith<$Res> {
  __$SessionQueryCopyWithImpl(this._self, this._then);

  final _SessionQuery _self;
  final $Res Function(_SessionQuery) _then;

/// Create a copy of SessionQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? from = freezed,Object? to = freezed,}) {
  return _then(_SessionQuery(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ScanStatus?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
