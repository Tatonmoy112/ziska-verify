// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'serial_stack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SerialStackRow {

 String get serial; LookupResult get result;
/// Create a copy of SerialStackRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SerialStackRowCopyWith<SerialStackRow> get copyWith => _$SerialStackRowCopyWithImpl<SerialStackRow>(this as SerialStackRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SerialStackRow&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,serial,result);

@override
String toString() {
  return 'SerialStackRow(serial: $serial, result: $result)';
}


}

/// @nodoc
abstract mixin class $SerialStackRowCopyWith<$Res>  {
  factory $SerialStackRowCopyWith(SerialStackRow value, $Res Function(SerialStackRow) _then) = _$SerialStackRowCopyWithImpl;
@useResult
$Res call({
 String serial, LookupResult result
});


$LookupResultCopyWith<$Res> get result;

}
/// @nodoc
class _$SerialStackRowCopyWithImpl<$Res>
    implements $SerialStackRowCopyWith<$Res> {
  _$SerialStackRowCopyWithImpl(this._self, this._then);

  final SerialStackRow _self;
  final $Res Function(SerialStackRow) _then;

/// Create a copy of SerialStackRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serial = null,Object? result = null,}) {
  return _then(_self.copyWith(
serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as LookupResult,
  ));
}
/// Create a copy of SerialStackRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LookupResultCopyWith<$Res> get result {
  
  return $LookupResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [SerialStackRow].
extension SerialStackRowPatterns on SerialStackRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SerialStackRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SerialStackRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SerialStackRow value)  $default,){
final _that = this;
switch (_that) {
case _SerialStackRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SerialStackRow value)?  $default,){
final _that = this;
switch (_that) {
case _SerialStackRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serial,  LookupResult result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SerialStackRow() when $default != null:
return $default(_that.serial,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serial,  LookupResult result)  $default,) {final _that = this;
switch (_that) {
case _SerialStackRow():
return $default(_that.serial,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serial,  LookupResult result)?  $default,) {final _that = this;
switch (_that) {
case _SerialStackRow() when $default != null:
return $default(_that.serial,_that.result);case _:
  return null;

}
}

}

/// @nodoc


class _SerialStackRow implements SerialStackRow {
  const _SerialStackRow({required this.serial, required this.result});
  

@override final  String serial;
@override final  LookupResult result;

/// Create a copy of SerialStackRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SerialStackRowCopyWith<_SerialStackRow> get copyWith => __$SerialStackRowCopyWithImpl<_SerialStackRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SerialStackRow&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,serial,result);

@override
String toString() {
  return 'SerialStackRow(serial: $serial, result: $result)';
}


}

/// @nodoc
abstract mixin class _$SerialStackRowCopyWith<$Res> implements $SerialStackRowCopyWith<$Res> {
  factory _$SerialStackRowCopyWith(_SerialStackRow value, $Res Function(_SerialStackRow) _then) = __$SerialStackRowCopyWithImpl;
@override @useResult
$Res call({
 String serial, LookupResult result
});


@override $LookupResultCopyWith<$Res> get result;

}
/// @nodoc
class __$SerialStackRowCopyWithImpl<$Res>
    implements _$SerialStackRowCopyWith<$Res> {
  __$SerialStackRowCopyWithImpl(this._self, this._then);

  final _SerialStackRow _self;
  final $Res Function(_SerialStackRow) _then;

/// Create a copy of SerialStackRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serial = null,Object? result = null,}) {
  return _then(_SerialStackRow(
serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as LookupResult,
  ));
}

/// Create a copy of SerialStackRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LookupResultCopyWith<$Res> get result {
  
  return $LookupResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

/// @nodoc
mixin _$SerialStackResult {

 SessionTotals get session; List<SerialStackRow> get items;
/// Create a copy of SerialStackResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SerialStackResultCopyWith<SerialStackResult> get copyWith => _$SerialStackResultCopyWithImpl<SerialStackResult>(this as SerialStackResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SerialStackResult&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,session,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'SerialStackResult(session: $session, items: $items)';
}


}

/// @nodoc
abstract mixin class $SerialStackResultCopyWith<$Res>  {
  factory $SerialStackResultCopyWith(SerialStackResult value, $Res Function(SerialStackResult) _then) = _$SerialStackResultCopyWithImpl;
@useResult
$Res call({
 SessionTotals session, List<SerialStackRow> items
});


$SessionTotalsCopyWith<$Res> get session;

}
/// @nodoc
class _$SerialStackResultCopyWithImpl<$Res>
    implements $SerialStackResultCopyWith<$Res> {
  _$SerialStackResultCopyWithImpl(this._self, this._then);

  final SerialStackResult _self;
  final $Res Function(SerialStackResult) _then;

/// Create a copy of SerialStackResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? session = null,Object? items = null,}) {
  return _then(_self.copyWith(
session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionTotals,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SerialStackRow>,
  ));
}
/// Create a copy of SerialStackResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionTotalsCopyWith<$Res> get session {
  
  return $SessionTotalsCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}


/// Adds pattern-matching-related methods to [SerialStackResult].
extension SerialStackResultPatterns on SerialStackResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SerialStackResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SerialStackResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SerialStackResult value)  $default,){
final _that = this;
switch (_that) {
case _SerialStackResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SerialStackResult value)?  $default,){
final _that = this;
switch (_that) {
case _SerialStackResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SessionTotals session,  List<SerialStackRow> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SerialStackResult() when $default != null:
return $default(_that.session,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SessionTotals session,  List<SerialStackRow> items)  $default,) {final _that = this;
switch (_that) {
case _SerialStackResult():
return $default(_that.session,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SessionTotals session,  List<SerialStackRow> items)?  $default,) {final _that = this;
switch (_that) {
case _SerialStackResult() when $default != null:
return $default(_that.session,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _SerialStackResult implements SerialStackResult {
  const _SerialStackResult({required this.session, required final  List<SerialStackRow> items}): _items = items;
  

@override final  SessionTotals session;
 final  List<SerialStackRow> _items;
@override List<SerialStackRow> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of SerialStackResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SerialStackResultCopyWith<_SerialStackResult> get copyWith => __$SerialStackResultCopyWithImpl<_SerialStackResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SerialStackResult&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,session,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'SerialStackResult(session: $session, items: $items)';
}


}

/// @nodoc
abstract mixin class _$SerialStackResultCopyWith<$Res> implements $SerialStackResultCopyWith<$Res> {
  factory _$SerialStackResultCopyWith(_SerialStackResult value, $Res Function(_SerialStackResult) _then) = __$SerialStackResultCopyWithImpl;
@override @useResult
$Res call({
 SessionTotals session, List<SerialStackRow> items
});


@override $SessionTotalsCopyWith<$Res> get session;

}
/// @nodoc
class __$SerialStackResultCopyWithImpl<$Res>
    implements _$SerialStackResultCopyWith<$Res> {
  __$SerialStackResultCopyWithImpl(this._self, this._then);

  final _SerialStackResult _self;
  final $Res Function(_SerialStackResult) _then;

/// Create a copy of SerialStackResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? session = null,Object? items = null,}) {
  return _then(_SerialStackResult(
session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as SessionTotals,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SerialStackRow>,
  ));
}

/// Create a copy of SerialStackResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionTotalsCopyWith<$Res> get session {
  
  return $SessionTotalsCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc
mixin _$ParsedStack {

/// The serials sent, each once, in the order typed.
 List<String> get serials;/// How many values were typed, repeats included.
 int get typed;/// The first value that is not a serial, by its place (from 1).
 ({int position, String value})? get bad;
/// Create a copy of ParsedStack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedStackCopyWith<ParsedStack> get copyWith => _$ParsedStackCopyWithImpl<ParsedStack>(this as ParsedStack, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedStack&&const DeepCollectionEquality().equals(other.serials, serials)&&(identical(other.typed, typed) || other.typed == typed)&&(identical(other.bad, bad) || other.bad == bad));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(serials),typed,bad);

@override
String toString() {
  return 'ParsedStack(serials: $serials, typed: $typed, bad: $bad)';
}


}

/// @nodoc
abstract mixin class $ParsedStackCopyWith<$Res>  {
  factory $ParsedStackCopyWith(ParsedStack value, $Res Function(ParsedStack) _then) = _$ParsedStackCopyWithImpl;
@useResult
$Res call({
 List<String> serials, int typed, ({int position, String value})? bad
});




}
/// @nodoc
class _$ParsedStackCopyWithImpl<$Res>
    implements $ParsedStackCopyWith<$Res> {
  _$ParsedStackCopyWithImpl(this._self, this._then);

  final ParsedStack _self;
  final $Res Function(ParsedStack) _then;

/// Create a copy of ParsedStack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serials = null,Object? typed = null,Object? bad = freezed,}) {
  return _then(_self.copyWith(
serials: null == serials ? _self.serials : serials // ignore: cast_nullable_to_non_nullable
as List<String>,typed: null == typed ? _self.typed : typed // ignore: cast_nullable_to_non_nullable
as int,bad: freezed == bad ? _self.bad : bad // ignore: cast_nullable_to_non_nullable
as ({int position, String value})?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedStack].
extension ParsedStackPatterns on ParsedStack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedStack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedStack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedStack value)  $default,){
final _that = this;
switch (_that) {
case _ParsedStack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedStack value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedStack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> serials,  int typed,  ({int position, String value})? bad)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedStack() when $default != null:
return $default(_that.serials,_that.typed,_that.bad);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> serials,  int typed,  ({int position, String value})? bad)  $default,) {final _that = this;
switch (_that) {
case _ParsedStack():
return $default(_that.serials,_that.typed,_that.bad);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> serials,  int typed,  ({int position, String value})? bad)?  $default,) {final _that = this;
switch (_that) {
case _ParsedStack() when $default != null:
return $default(_that.serials,_that.typed,_that.bad);case _:
  return null;

}
}

}

/// @nodoc


class _ParsedStack extends ParsedStack {
  const _ParsedStack({required final  List<String> serials, required this.typed, this.bad}): _serials = serials,super._();
  

/// The serials sent, each once, in the order typed.
 final  List<String> _serials;
/// The serials sent, each once, in the order typed.
@override List<String> get serials {
  if (_serials is EqualUnmodifiableListView) return _serials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serials);
}

/// How many values were typed, repeats included.
@override final  int typed;
/// The first value that is not a serial, by its place (from 1).
@override final  ({int position, String value})? bad;

/// Create a copy of ParsedStack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedStackCopyWith<_ParsedStack> get copyWith => __$ParsedStackCopyWithImpl<_ParsedStack>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedStack&&const DeepCollectionEquality().equals(other._serials, _serials)&&(identical(other.typed, typed) || other.typed == typed)&&(identical(other.bad, bad) || other.bad == bad));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_serials),typed,bad);

@override
String toString() {
  return 'ParsedStack(serials: $serials, typed: $typed, bad: $bad)';
}


}

/// @nodoc
abstract mixin class _$ParsedStackCopyWith<$Res> implements $ParsedStackCopyWith<$Res> {
  factory _$ParsedStackCopyWith(_ParsedStack value, $Res Function(_ParsedStack) _then) = __$ParsedStackCopyWithImpl;
@override @useResult
$Res call({
 List<String> serials, int typed, ({int position, String value})? bad
});




}
/// @nodoc
class __$ParsedStackCopyWithImpl<$Res>
    implements _$ParsedStackCopyWith<$Res> {
  __$ParsedStackCopyWithImpl(this._self, this._then);

  final _ParsedStack _self;
  final $Res Function(_ParsedStack) _then;

/// Create a copy of ParsedStack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serials = null,Object? typed = null,Object? bad = freezed,}) {
  return _then(_ParsedStack(
serials: null == serials ? _self._serials : serials // ignore: cast_nullable_to_non_nullable
as List<String>,typed: null == typed ? _self.typed : typed // ignore: cast_nullable_to_non_nullable
as int,bad: freezed == bad ? _self.bad : bad // ignore: cast_nullable_to_non_nullable
as ({int position, String value})?,
  ));
}


}

// dart format on
