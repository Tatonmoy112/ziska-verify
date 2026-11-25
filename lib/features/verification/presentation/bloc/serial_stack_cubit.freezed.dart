// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'serial_stack_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SerialStackState {

 InputFormats? get formats; bool get busy; bool get paused; bool get uncertain;/// The stack was recorded, but its answer could not be read (it did not
/// match what was sent). Never sent again: all or nothing applies only
/// to an answer that is not 200 (app API guide §4.7).
 bool get recorded;/// The serial that stopped the stack before sending, by its place.
 ({int position, String value})? get badSerial; bool get submitted;/// The stack as typed, counted as it will be sent: shown under the box
/// (production audit P-38). `null` before the formats or with no text.
 ParsedStack? get draft; List<String> get serials; SerialStackResult? get result; DateTime? get checkedAt; Failure? get failure; DateTime? get retryAt;
/// Create a copy of SerialStackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SerialStackStateCopyWith<SerialStackState> get copyWith => _$SerialStackStateCopyWithImpl<SerialStackState>(this as SerialStackState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SerialStackState&&(identical(other.formats, formats) || other.formats == formats)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.recorded, recorded) || other.recorded == recorded)&&(identical(other.badSerial, badSerial) || other.badSerial == badSerial)&&(identical(other.submitted, submitted) || other.submitted == submitted)&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other.serials, serials)&&(identical(other.result, result) || other.result == result)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,formats,busy,paused,uncertain,recorded,badSerial,submitted,draft,const DeepCollectionEquality().hash(serials),result,checkedAt,failure,retryAt);

@override
String toString() {
  return 'SerialStackState(formats: $formats, busy: $busy, paused: $paused, uncertain: $uncertain, recorded: $recorded, badSerial: $badSerial, submitted: $submitted, draft: $draft, serials: $serials, result: $result, checkedAt: $checkedAt, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class $SerialStackStateCopyWith<$Res>  {
  factory $SerialStackStateCopyWith(SerialStackState value, $Res Function(SerialStackState) _then) = _$SerialStackStateCopyWithImpl;
@useResult
$Res call({
 InputFormats? formats, bool busy, bool paused, bool uncertain, bool recorded, ({int position, String value})? badSerial, bool submitted, ParsedStack? draft, List<String> serials, SerialStackResult? result, DateTime? checkedAt, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class _$SerialStackStateCopyWithImpl<$Res>
    implements $SerialStackStateCopyWith<$Res> {
  _$SerialStackStateCopyWithImpl(this._self, this._then);

  final SerialStackState _self;
  final $Res Function(SerialStackState) _then;

/// Create a copy of SerialStackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? formats = freezed,Object? busy = null,Object? paused = null,Object? uncertain = null,Object? recorded = null,Object? badSerial = freezed,Object? submitted = null,Object? draft = freezed,Object? serials = null,Object? result = freezed,Object? checkedAt = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_self.copyWith(
formats: freezed == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as InputFormats?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,recorded: null == recorded ? _self.recorded : recorded // ignore: cast_nullable_to_non_nullable
as bool,badSerial: freezed == badSerial ? _self.badSerial : badSerial // ignore: cast_nullable_to_non_nullable
as ({int position, String value})?,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as bool,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as ParsedStack?,serials: null == serials ? _self.serials : serials // ignore: cast_nullable_to_non_nullable
as List<String>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as SerialStackResult?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SerialStackState].
extension SerialStackStatePatterns on SerialStackState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SerialStackState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SerialStackState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SerialStackState value)  $default,){
final _that = this;
switch (_that) {
case _SerialStackState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SerialStackState value)?  $default,){
final _that = this;
switch (_that) {
case _SerialStackState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InputFormats? formats,  bool busy,  bool paused,  bool uncertain,  bool recorded,  ({int position, String value})? badSerial,  bool submitted,  ParsedStack? draft,  List<String> serials,  SerialStackResult? result,  DateTime? checkedAt,  Failure? failure,  DateTime? retryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SerialStackState() when $default != null:
return $default(_that.formats,_that.busy,_that.paused,_that.uncertain,_that.recorded,_that.badSerial,_that.submitted,_that.draft,_that.serials,_that.result,_that.checkedAt,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InputFormats? formats,  bool busy,  bool paused,  bool uncertain,  bool recorded,  ({int position, String value})? badSerial,  bool submitted,  ParsedStack? draft,  List<String> serials,  SerialStackResult? result,  DateTime? checkedAt,  Failure? failure,  DateTime? retryAt)  $default,) {final _that = this;
switch (_that) {
case _SerialStackState():
return $default(_that.formats,_that.busy,_that.paused,_that.uncertain,_that.recorded,_that.badSerial,_that.submitted,_that.draft,_that.serials,_that.result,_that.checkedAt,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InputFormats? formats,  bool busy,  bool paused,  bool uncertain,  bool recorded,  ({int position, String value})? badSerial,  bool submitted,  ParsedStack? draft,  List<String> serials,  SerialStackResult? result,  DateTime? checkedAt,  Failure? failure,  DateTime? retryAt)?  $default,) {final _that = this;
switch (_that) {
case _SerialStackState() when $default != null:
return $default(_that.formats,_that.busy,_that.paused,_that.uncertain,_that.recorded,_that.badSerial,_that.submitted,_that.draft,_that.serials,_that.result,_that.checkedAt,_that.failure,_that.retryAt);case _:
  return null;

}
}

}

/// @nodoc


class _SerialStackState implements SerialStackState {
  const _SerialStackState({this.formats, this.busy = false, this.paused = false, this.uncertain = false, this.recorded = false, this.badSerial, this.submitted = false, this.draft, final  List<String> serials = const <String>[], this.result, this.checkedAt, this.failure, this.retryAt}): _serials = serials;
  

@override final  InputFormats? formats;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool paused;
@override@JsonKey() final  bool uncertain;
/// The stack was recorded, but its answer could not be read (it did not
/// match what was sent). Never sent again: all or nothing applies only
/// to an answer that is not 200 (app API guide §4.7).
@override@JsonKey() final  bool recorded;
/// The serial that stopped the stack before sending, by its place.
@override final  ({int position, String value})? badSerial;
@override@JsonKey() final  bool submitted;
/// The stack as typed, counted as it will be sent: shown under the box
/// (production audit P-38). `null` before the formats or with no text.
@override final  ParsedStack? draft;
 final  List<String> _serials;
@override@JsonKey() List<String> get serials {
  if (_serials is EqualUnmodifiableListView) return _serials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_serials);
}

@override final  SerialStackResult? result;
@override final  DateTime? checkedAt;
@override final  Failure? failure;
@override final  DateTime? retryAt;

/// Create a copy of SerialStackState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SerialStackStateCopyWith<_SerialStackState> get copyWith => __$SerialStackStateCopyWithImpl<_SerialStackState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SerialStackState&&(identical(other.formats, formats) || other.formats == formats)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.paused, paused) || other.paused == paused)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.recorded, recorded) || other.recorded == recorded)&&(identical(other.badSerial, badSerial) || other.badSerial == badSerial)&&(identical(other.submitted, submitted) || other.submitted == submitted)&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other._serials, _serials)&&(identical(other.result, result) || other.result == result)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,formats,busy,paused,uncertain,recorded,badSerial,submitted,draft,const DeepCollectionEquality().hash(_serials),result,checkedAt,failure,retryAt);

@override
String toString() {
  return 'SerialStackState(formats: $formats, busy: $busy, paused: $paused, uncertain: $uncertain, recorded: $recorded, badSerial: $badSerial, submitted: $submitted, draft: $draft, serials: $serials, result: $result, checkedAt: $checkedAt, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class _$SerialStackStateCopyWith<$Res> implements $SerialStackStateCopyWith<$Res> {
  factory _$SerialStackStateCopyWith(_SerialStackState value, $Res Function(_SerialStackState) _then) = __$SerialStackStateCopyWithImpl;
@override @useResult
$Res call({
 InputFormats? formats, bool busy, bool paused, bool uncertain, bool recorded, ({int position, String value})? badSerial, bool submitted, ParsedStack? draft, List<String> serials, SerialStackResult? result, DateTime? checkedAt, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class __$SerialStackStateCopyWithImpl<$Res>
    implements _$SerialStackStateCopyWith<$Res> {
  __$SerialStackStateCopyWithImpl(this._self, this._then);

  final _SerialStackState _self;
  final $Res Function(_SerialStackState) _then;

/// Create a copy of SerialStackState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? formats = freezed,Object? busy = null,Object? paused = null,Object? uncertain = null,Object? recorded = null,Object? badSerial = freezed,Object? submitted = null,Object? draft = freezed,Object? serials = null,Object? result = freezed,Object? checkedAt = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_SerialStackState(
formats: freezed == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as InputFormats?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,paused: null == paused ? _self.paused : paused // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,recorded: null == recorded ? _self.recorded : recorded // ignore: cast_nullable_to_non_nullable
as bool,badSerial: freezed == badSerial ? _self.badSerial : badSerial // ignore: cast_nullable_to_non_nullable
as ({int position, String value})?,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as bool,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as ParsedStack?,serials: null == serials ? _self._serials : serials // ignore: cast_nullable_to_non_nullable
as List<String>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as SerialStackResult?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
