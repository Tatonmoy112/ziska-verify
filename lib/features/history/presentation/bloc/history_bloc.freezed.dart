// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistoryState {

 CheckQuery get query; PaginatedState<CheckRecord> get list;/// From the first page; kept while later pages load (§10).
 CheckTotals? get totals;/// The counts on the result chips: every check matching the search and
/// the other filters, whatever result is picked, so picking a chip
/// never changes them. `null` while unknown (the chips then show no
/// count).
 CheckTotals? get chipTotals;/// The search is neither a serial nor a reference number, so nothing
/// was asked for (finding F-4): the list says what to type instead.
 bool get searchRefused;
/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryStateCopyWith<HistoryState> get copyWith => _$HistoryStateCopyWithImpl<HistoryState>(this as HistoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryState&&(identical(other.query, query) || other.query == query)&&(identical(other.list, list) || other.list == list)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.chipTotals, chipTotals) || other.chipTotals == chipTotals)&&(identical(other.searchRefused, searchRefused) || other.searchRefused == searchRefused));
}


@override
int get hashCode => Object.hash(runtimeType,query,list,totals,chipTotals,searchRefused);

@override
String toString() {
  return 'HistoryState(query: $query, list: $list, totals: $totals, chipTotals: $chipTotals, searchRefused: $searchRefused)';
}


}

/// @nodoc
abstract mixin class $HistoryStateCopyWith<$Res>  {
  factory $HistoryStateCopyWith(HistoryState value, $Res Function(HistoryState) _then) = _$HistoryStateCopyWithImpl;
@useResult
$Res call({
 CheckQuery query, PaginatedState<CheckRecord> list, CheckTotals? totals, CheckTotals? chipTotals, bool searchRefused
});


$CheckQueryCopyWith<$Res> get query;$PaginatedStateCopyWith<CheckRecord, $Res> get list;

}
/// @nodoc
class _$HistoryStateCopyWithImpl<$Res>
    implements $HistoryStateCopyWith<$Res> {
  _$HistoryStateCopyWithImpl(this._self, this._then);

  final HistoryState _self;
  final $Res Function(HistoryState) _then;

/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? list = null,Object? totals = freezed,Object? chipTotals = freezed,Object? searchRefused = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as CheckQuery,list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as PaginatedState<CheckRecord>,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as CheckTotals?,chipTotals: freezed == chipTotals ? _self.chipTotals : chipTotals // ignore: cast_nullable_to_non_nullable
as CheckTotals?,searchRefused: null == searchRefused ? _self.searchRefused : searchRefused // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckQueryCopyWith<$Res> get query {
  
  return $CheckQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginatedStateCopyWith<CheckRecord, $Res> get list {
  
  return $PaginatedStateCopyWith<CheckRecord, $Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}


/// Adds pattern-matching-related methods to [HistoryState].
extension HistoryStatePatterns on HistoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryState value)  $default,){
final _that = this;
switch (_that) {
case _HistoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryState value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CheckQuery query,  PaginatedState<CheckRecord> list,  CheckTotals? totals,  CheckTotals? chipTotals,  bool searchRefused)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryState() when $default != null:
return $default(_that.query,_that.list,_that.totals,_that.chipTotals,_that.searchRefused);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CheckQuery query,  PaginatedState<CheckRecord> list,  CheckTotals? totals,  CheckTotals? chipTotals,  bool searchRefused)  $default,) {final _that = this;
switch (_that) {
case _HistoryState():
return $default(_that.query,_that.list,_that.totals,_that.chipTotals,_that.searchRefused);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CheckQuery query,  PaginatedState<CheckRecord> list,  CheckTotals? totals,  CheckTotals? chipTotals,  bool searchRefused)?  $default,) {final _that = this;
switch (_that) {
case _HistoryState() when $default != null:
return $default(_that.query,_that.list,_that.totals,_that.chipTotals,_that.searchRefused);case _:
  return null;

}
}

}

/// @nodoc


class _HistoryState implements HistoryState {
  const _HistoryState({this.query = const CheckQuery(), this.list = const PaginatedState<CheckRecord>(), this.totals, this.chipTotals, this.searchRefused = false});
  

@override@JsonKey() final  CheckQuery query;
@override@JsonKey() final  PaginatedState<CheckRecord> list;
/// From the first page; kept while later pages load (§10).
@override final  CheckTotals? totals;
/// The counts on the result chips: every check matching the search and
/// the other filters, whatever result is picked, so picking a chip
/// never changes them. `null` while unknown (the chips then show no
/// count).
@override final  CheckTotals? chipTotals;
/// The search is neither a serial nor a reference number, so nothing
/// was asked for (finding F-4): the list says what to type instead.
@override@JsonKey() final  bool searchRefused;

/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryStateCopyWith<_HistoryState> get copyWith => __$HistoryStateCopyWithImpl<_HistoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryState&&(identical(other.query, query) || other.query == query)&&(identical(other.list, list) || other.list == list)&&(identical(other.totals, totals) || other.totals == totals)&&(identical(other.chipTotals, chipTotals) || other.chipTotals == chipTotals)&&(identical(other.searchRefused, searchRefused) || other.searchRefused == searchRefused));
}


@override
int get hashCode => Object.hash(runtimeType,query,list,totals,chipTotals,searchRefused);

@override
String toString() {
  return 'HistoryState(query: $query, list: $list, totals: $totals, chipTotals: $chipTotals, searchRefused: $searchRefused)';
}


}

/// @nodoc
abstract mixin class _$HistoryStateCopyWith<$Res> implements $HistoryStateCopyWith<$Res> {
  factory _$HistoryStateCopyWith(_HistoryState value, $Res Function(_HistoryState) _then) = __$HistoryStateCopyWithImpl;
@override @useResult
$Res call({
 CheckQuery query, PaginatedState<CheckRecord> list, CheckTotals? totals, CheckTotals? chipTotals, bool searchRefused
});


@override $CheckQueryCopyWith<$Res> get query;@override $PaginatedStateCopyWith<CheckRecord, $Res> get list;

}
/// @nodoc
class __$HistoryStateCopyWithImpl<$Res>
    implements _$HistoryStateCopyWith<$Res> {
  __$HistoryStateCopyWithImpl(this._self, this._then);

  final _HistoryState _self;
  final $Res Function(_HistoryState) _then;

/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? list = null,Object? totals = freezed,Object? chipTotals = freezed,Object? searchRefused = null,}) {
  return _then(_HistoryState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as CheckQuery,list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as PaginatedState<CheckRecord>,totals: freezed == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as CheckTotals?,chipTotals: freezed == chipTotals ? _self.chipTotals : chipTotals // ignore: cast_nullable_to_non_nullable
as CheckTotals?,searchRefused: null == searchRefused ? _self.searchRefused : searchRefused // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckQueryCopyWith<$Res> get query {
  
  return $CheckQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginatedStateCopyWith<CheckRecord, $Res> get list {
  
  return $PaginatedStateCopyWith<CheckRecord, $Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}

// dart format on
