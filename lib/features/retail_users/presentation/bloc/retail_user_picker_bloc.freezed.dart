// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retail_user_picker_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RetailUserPickerState {

 String? get search; PaginatedState<RetailUser> get list;
/// Create a copy of RetailUserPickerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RetailUserPickerStateCopyWith<RetailUserPickerState> get copyWith => _$RetailUserPickerStateCopyWithImpl<RetailUserPickerState>(this as RetailUserPickerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RetailUserPickerState&&(identical(other.search, search) || other.search == search)&&(identical(other.list, list) || other.list == list));
}


@override
int get hashCode => Object.hash(runtimeType,search,list);

@override
String toString() {
  return 'RetailUserPickerState(search: $search, list: $list)';
}


}

/// @nodoc
abstract mixin class $RetailUserPickerStateCopyWith<$Res>  {
  factory $RetailUserPickerStateCopyWith(RetailUserPickerState value, $Res Function(RetailUserPickerState) _then) = _$RetailUserPickerStateCopyWithImpl;
@useResult
$Res call({
 String? search, PaginatedState<RetailUser> list
});


$PaginatedStateCopyWith<RetailUser, $Res> get list;

}
/// @nodoc
class _$RetailUserPickerStateCopyWithImpl<$Res>
    implements $RetailUserPickerStateCopyWith<$Res> {
  _$RetailUserPickerStateCopyWithImpl(this._self, this._then);

  final RetailUserPickerState _self;
  final $Res Function(RetailUserPickerState) _then;

/// Create a copy of RetailUserPickerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = freezed,Object? list = null,}) {
  return _then(_self.copyWith(
search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as PaginatedState<RetailUser>,
  ));
}
/// Create a copy of RetailUserPickerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginatedStateCopyWith<RetailUser, $Res> get list {
  
  return $PaginatedStateCopyWith<RetailUser, $Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}


/// Adds pattern-matching-related methods to [RetailUserPickerState].
extension RetailUserPickerStatePatterns on RetailUserPickerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RetailUserPickerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RetailUserPickerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RetailUserPickerState value)  $default,){
final _that = this;
switch (_that) {
case _RetailUserPickerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RetailUserPickerState value)?  $default,){
final _that = this;
switch (_that) {
case _RetailUserPickerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? search,  PaginatedState<RetailUser> list)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RetailUserPickerState() when $default != null:
return $default(_that.search,_that.list);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? search,  PaginatedState<RetailUser> list)  $default,) {final _that = this;
switch (_that) {
case _RetailUserPickerState():
return $default(_that.search,_that.list);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? search,  PaginatedState<RetailUser> list)?  $default,) {final _that = this;
switch (_that) {
case _RetailUserPickerState() when $default != null:
return $default(_that.search,_that.list);case _:
  return null;

}
}

}

/// @nodoc


class _RetailUserPickerState implements RetailUserPickerState {
  const _RetailUserPickerState({this.search, this.list = const PaginatedState<RetailUser>()});
  

@override final  String? search;
@override@JsonKey() final  PaginatedState<RetailUser> list;

/// Create a copy of RetailUserPickerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RetailUserPickerStateCopyWith<_RetailUserPickerState> get copyWith => __$RetailUserPickerStateCopyWithImpl<_RetailUserPickerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RetailUserPickerState&&(identical(other.search, search) || other.search == search)&&(identical(other.list, list) || other.list == list));
}


@override
int get hashCode => Object.hash(runtimeType,search,list);

@override
String toString() {
  return 'RetailUserPickerState(search: $search, list: $list)';
}


}

/// @nodoc
abstract mixin class _$RetailUserPickerStateCopyWith<$Res> implements $RetailUserPickerStateCopyWith<$Res> {
  factory _$RetailUserPickerStateCopyWith(_RetailUserPickerState value, $Res Function(_RetailUserPickerState) _then) = __$RetailUserPickerStateCopyWithImpl;
@override @useResult
$Res call({
 String? search, PaginatedState<RetailUser> list
});


@override $PaginatedStateCopyWith<RetailUser, $Res> get list;

}
/// @nodoc
class __$RetailUserPickerStateCopyWithImpl<$Res>
    implements _$RetailUserPickerStateCopyWith<$Res> {
  __$RetailUserPickerStateCopyWithImpl(this._self, this._then);

  final _RetailUserPickerState _self;
  final $Res Function(_RetailUserPickerState) _then;

/// Create a copy of RetailUserPickerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = freezed,Object? list = null,}) {
  return _then(_RetailUserPickerState(
search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,list: null == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as PaginatedState<RetailUser>,
  ));
}

/// Create a copy of RetailUserPickerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginatedStateCopyWith<RetailUser, $Res> get list {
  
  return $PaginatedStateCopyWith<RetailUser, $Res>(_self.list, (value) {
    return _then(_self.copyWith(list: value));
  });
}
}

// dart format on
