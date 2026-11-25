// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sessions_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionsState {

 SessionQuery get query; PaginatedState<ScanSessionSummary> get list;
/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionsStateCopyWith<SessionsState> get copyWith => _$SessionsStateCopyWithImpl<SessionsState>(this as SessionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionsState&&(identical(other.query, query) || other.query == query)&&(identical(other.list, list) || other.list == list));
}


@override
int get hashCode => Object.hash(runtimeType,query,list);

@override
String toString() {
  return 'SessionsState(query: $query, list: $list)';
}


}

/// @nodoc
abstract mixin class $SessionsStateCopyWith<$Res>  {
  factory $SessionsStateCopyWith(SessionsState value, $Res Function(SessionsState) _then) = _$SessionsStateCopyWithImpl;
@useResult
$Res call({
 SessionQuery query, PaginatedState<ScanSessionSummary> list
});


$PaginatedStateCopyWith<ScanSessionSummary, $Res> get list;

}
/// @nodoc
class _$SessionsStateCopyWithImpl<$Res>
    implements $SessionsStateCopyWith<$Res> {
  _$SessionsStateCopyWithImpl(this._self, this._then);

  final SessionsState _self;
  final $Res Function(SessionsState) _then;

/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? list = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as SessionQuery,list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as PaginatedState<ScanSessionSummary>,
  ));
}
/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginatedStateCopyWith<ScanSessionSummary, $Res> get list {
  
  return $PaginatedStateCopyWith<ScanSessionSummary, $Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionsState].
extension SessionsStatePatterns on SessionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionsState value)  $default,){
final _that = this;
switch (_that) {
case _SessionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionsState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SessionQuery query,  PaginatedState<ScanSessionSummary> list)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionsState() when $default != null:
return $default(_that.query,_that.list);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SessionQuery query,  PaginatedState<ScanSessionSummary> list)  $default,) {final _that = this;
switch (_that) {
case _SessionsState():
return $default(_that.query,_that.list);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SessionQuery query,  PaginatedState<ScanSessionSummary> list)?  $default,) {final _that = this;
switch (_that) {
case _SessionsState() when $default != null:
return $default(_that.query,_that.list);case _:
  return null;

}
}

}

/// @nodoc


class _SessionsState implements SessionsState {
  const _SessionsState({this.query = const SessionQuery(), this.list = const PaginatedState<ScanSessionSummary>()});
  

@override@JsonKey() final  SessionQuery query;
@override@JsonKey() final  PaginatedState<ScanSessionSummary> list;

/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionsStateCopyWith<_SessionsState> get copyWith => __$SessionsStateCopyWithImpl<_SessionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionsState&&(identical(other.query, query) || other.query == query)&&(identical(other.list, list) || other.list == list));
}


@override
int get hashCode => Object.hash(runtimeType,query,list);

@override
String toString() {
  return 'SessionsState(query: $query, list: $list)';
}


}

/// @nodoc
abstract mixin class _$SessionsStateCopyWith<$Res> implements $SessionsStateCopyWith<$Res> {
  factory _$SessionsStateCopyWith(_SessionsState value, $Res Function(_SessionsState) _then) = __$SessionsStateCopyWithImpl;
@override @useResult
$Res call({
 SessionQuery query, PaginatedState<ScanSessionSummary> list
});


@override $PaginatedStateCopyWith<ScanSessionSummary, $Res> get list;

}
/// @nodoc
class __$SessionsStateCopyWithImpl<$Res>
    implements _$SessionsStateCopyWith<$Res> {
  __$SessionsStateCopyWithImpl(this._self, this._then);

  final _SessionsState _self;
  final $Res Function(_SessionsState) _then;

/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? list = null,}) {
  return _then(_SessionsState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as SessionQuery,list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as PaginatedState<ScanSessionSummary>,
  ));
}

/// Create a copy of SessionsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginatedStateCopyWith<ScanSessionSummary, $Res> get list {
  
  return $PaginatedStateCopyWith<ScanSessionSummary, $Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}

// dart format on
