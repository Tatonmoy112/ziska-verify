// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cursor_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CursorPage<T> {

 List<T> get items;/// Opaque: never parsed, compared, or built (§10).
 String? get nextCursor;
/// Create a copy of CursorPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CursorPageCopyWith<T, CursorPage<T>> get copyWith => _$CursorPageCopyWithImpl<T, CursorPage<T>>(this as CursorPage<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CursorPage<T>&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),nextCursor);

@override
String toString() {
  return 'CursorPage<$T>(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $CursorPageCopyWith<T,$Res>  {
  factory $CursorPageCopyWith(CursorPage<T> value, $Res Function(CursorPage<T>) _then) = _$CursorPageCopyWithImpl;
@useResult
$Res call({
 List<T> items, String? nextCursor
});




}
/// @nodoc
class _$CursorPageCopyWithImpl<T,$Res>
    implements $CursorPageCopyWith<T, $Res> {
  _$CursorPageCopyWithImpl(this._self, this._then);

  final CursorPage<T> _self;
  final $Res Function(CursorPage<T>) _then;

/// Create a copy of CursorPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CursorPage].
extension CursorPagePatterns<T> on CursorPage<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CursorPage<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CursorPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CursorPage<T> value)  $default,){
final _that = this;
switch (_that) {
case _CursorPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CursorPage<T> value)?  $default,){
final _that = this;
switch (_that) {
case _CursorPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CursorPage() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _CursorPage():
return $default(_that.items,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _CursorPage() when $default != null:
return $default(_that.items,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc


class _CursorPage<T> extends CursorPage<T> {
  const _CursorPage({required final  List<T> items, this.nextCursor}): _items = items,super._();
  

 final  List<T> _items;
@override List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// Opaque: never parsed, compared, or built (§10).
@override final  String? nextCursor;

/// Create a copy of CursorPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CursorPageCopyWith<T, _CursorPage<T>> get copyWith => __$CursorPageCopyWithImpl<T, _CursorPage<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CursorPage<T>&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),nextCursor);

@override
String toString() {
  return 'CursorPage<$T>(items: $items, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$CursorPageCopyWith<T,$Res> implements $CursorPageCopyWith<T, $Res> {
  factory _$CursorPageCopyWith(_CursorPage<T> value, $Res Function(_CursorPage<T>) _then) = __$CursorPageCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, String? nextCursor
});




}
/// @nodoc
class __$CursorPageCopyWithImpl<T,$Res>
    implements _$CursorPageCopyWith<T, $Res> {
  __$CursorPageCopyWithImpl(this._self, this._then);

  final _CursorPage<T> _self;
  final $Res Function(_CursorPage<T>) _then;

/// Create a copy of CursorPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? nextCursor = freezed,}) {
  return _then(_CursorPage<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
