// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bulk_lookup_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BulkLookupState {

 InputFormats? get formats; Failure? get formatsFailure; List<BulkEntry> get entries; BulkStatus get status;/// The last add that was refused, and a counter so each one is shown.
 AddProblem? get addProblem; int get addProblemCount;/// The last item added (feedback while scanning many codes).
 BulkEntry? get lastAdded; BulkOutcome? get outcome;/// When the [outcome] arrived: the check time of every row.
 DateTime? get checkedAt; Failure? get failure;/// After a `429`: when the list may be sent again.
 DateTime? get retryAt;
/// Create a copy of BulkLookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BulkLookupStateCopyWith<BulkLookupState> get copyWith => _$BulkLookupStateCopyWithImpl<BulkLookupState>(this as BulkLookupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BulkLookupState&&(identical(other.formats, formats) || other.formats == formats)&&(identical(other.formatsFailure, formatsFailure) || other.formatsFailure == formatsFailure)&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.status, status) || other.status == status)&&(identical(other.addProblem, addProblem) || other.addProblem == addProblem)&&(identical(other.addProblemCount, addProblemCount) || other.addProblemCount == addProblemCount)&&(identical(other.lastAdded, lastAdded) || other.lastAdded == lastAdded)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,formats,formatsFailure,const DeepCollectionEquality().hash(entries),status,addProblem,addProblemCount,lastAdded,outcome,checkedAt,failure,retryAt);

@override
String toString() {
  return 'BulkLookupState(formats: $formats, formatsFailure: $formatsFailure, entries: $entries, status: $status, addProblem: $addProblem, addProblemCount: $addProblemCount, lastAdded: $lastAdded, outcome: $outcome, checkedAt: $checkedAt, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class $BulkLookupStateCopyWith<$Res>  {
  factory $BulkLookupStateCopyWith(BulkLookupState value, $Res Function(BulkLookupState) _then) = _$BulkLookupStateCopyWithImpl;
@useResult
$Res call({
 InputFormats? formats, Failure? formatsFailure, List<BulkEntry> entries, BulkStatus status, AddProblem? addProblem, int addProblemCount, BulkEntry? lastAdded, BulkOutcome? outcome, DateTime? checkedAt, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class _$BulkLookupStateCopyWithImpl<$Res>
    implements $BulkLookupStateCopyWith<$Res> {
  _$BulkLookupStateCopyWithImpl(this._self, this._then);

  final BulkLookupState _self;
  final $Res Function(BulkLookupState) _then;

/// Create a copy of BulkLookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? formats = freezed,Object? formatsFailure = freezed,Object? entries = null,Object? status = null,Object? addProblem = freezed,Object? addProblemCount = null,Object? lastAdded = freezed,Object? outcome = freezed,Object? checkedAt = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_self.copyWith(
formats: freezed == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as InputFormats?,formatsFailure: freezed == formatsFailure ? _self.formatsFailure : formatsFailure // ignore: cast_nullable_to_non_nullable
as Failure?,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<BulkEntry>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BulkStatus,addProblem: freezed == addProblem ? _self.addProblem : addProblem // ignore: cast_nullable_to_non_nullable
as AddProblem?,addProblemCount: null == addProblemCount ? _self.addProblemCount : addProblemCount // ignore: cast_nullable_to_non_nullable
as int,lastAdded: freezed == lastAdded ? _self.lastAdded : lastAdded // ignore: cast_nullable_to_non_nullable
as BulkEntry?,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as BulkOutcome?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BulkLookupState].
extension BulkLookupStatePatterns on BulkLookupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BulkLookupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BulkLookupState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BulkLookupState value)  $default,){
final _that = this;
switch (_that) {
case _BulkLookupState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BulkLookupState value)?  $default,){
final _that = this;
switch (_that) {
case _BulkLookupState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InputFormats? formats,  Failure? formatsFailure,  List<BulkEntry> entries,  BulkStatus status,  AddProblem? addProblem,  int addProblemCount,  BulkEntry? lastAdded,  BulkOutcome? outcome,  DateTime? checkedAt,  Failure? failure,  DateTime? retryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BulkLookupState() when $default != null:
return $default(_that.formats,_that.formatsFailure,_that.entries,_that.status,_that.addProblem,_that.addProblemCount,_that.lastAdded,_that.outcome,_that.checkedAt,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InputFormats? formats,  Failure? formatsFailure,  List<BulkEntry> entries,  BulkStatus status,  AddProblem? addProblem,  int addProblemCount,  BulkEntry? lastAdded,  BulkOutcome? outcome,  DateTime? checkedAt,  Failure? failure,  DateTime? retryAt)  $default,) {final _that = this;
switch (_that) {
case _BulkLookupState():
return $default(_that.formats,_that.formatsFailure,_that.entries,_that.status,_that.addProblem,_that.addProblemCount,_that.lastAdded,_that.outcome,_that.checkedAt,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InputFormats? formats,  Failure? formatsFailure,  List<BulkEntry> entries,  BulkStatus status,  AddProblem? addProblem,  int addProblemCount,  BulkEntry? lastAdded,  BulkOutcome? outcome,  DateTime? checkedAt,  Failure? failure,  DateTime? retryAt)?  $default,) {final _that = this;
switch (_that) {
case _BulkLookupState() when $default != null:
return $default(_that.formats,_that.formatsFailure,_that.entries,_that.status,_that.addProblem,_that.addProblemCount,_that.lastAdded,_that.outcome,_that.checkedAt,_that.failure,_that.retryAt);case _:
  return null;

}
}

}

/// @nodoc


class _BulkLookupState extends BulkLookupState {
  const _BulkLookupState({this.formats, this.formatsFailure, final  List<BulkEntry> entries = const <BulkEntry>[], this.status = BulkStatus.composing, this.addProblem, this.addProblemCount = 0, this.lastAdded, this.outcome, this.checkedAt, this.failure, this.retryAt}): _entries = entries,super._();
  

@override final  InputFormats? formats;
@override final  Failure? formatsFailure;
 final  List<BulkEntry> _entries;
@override@JsonKey() List<BulkEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override@JsonKey() final  BulkStatus status;
/// The last add that was refused, and a counter so each one is shown.
@override final  AddProblem? addProblem;
@override@JsonKey() final  int addProblemCount;
/// The last item added (feedback while scanning many codes).
@override final  BulkEntry? lastAdded;
@override final  BulkOutcome? outcome;
/// When the [outcome] arrived: the check time of every row.
@override final  DateTime? checkedAt;
@override final  Failure? failure;
/// After a `429`: when the list may be sent again.
@override final  DateTime? retryAt;

/// Create a copy of BulkLookupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BulkLookupStateCopyWith<_BulkLookupState> get copyWith => __$BulkLookupStateCopyWithImpl<_BulkLookupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BulkLookupState&&(identical(other.formats, formats) || other.formats == formats)&&(identical(other.formatsFailure, formatsFailure) || other.formatsFailure == formatsFailure)&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.status, status) || other.status == status)&&(identical(other.addProblem, addProblem) || other.addProblem == addProblem)&&(identical(other.addProblemCount, addProblemCount) || other.addProblemCount == addProblemCount)&&(identical(other.lastAdded, lastAdded) || other.lastAdded == lastAdded)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,formats,formatsFailure,const DeepCollectionEquality().hash(_entries),status,addProblem,addProblemCount,lastAdded,outcome,checkedAt,failure,retryAt);

@override
String toString() {
  return 'BulkLookupState(formats: $formats, formatsFailure: $formatsFailure, entries: $entries, status: $status, addProblem: $addProblem, addProblemCount: $addProblemCount, lastAdded: $lastAdded, outcome: $outcome, checkedAt: $checkedAt, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class _$BulkLookupStateCopyWith<$Res> implements $BulkLookupStateCopyWith<$Res> {
  factory _$BulkLookupStateCopyWith(_BulkLookupState value, $Res Function(_BulkLookupState) _then) = __$BulkLookupStateCopyWithImpl;
@override @useResult
$Res call({
 InputFormats? formats, Failure? formatsFailure, List<BulkEntry> entries, BulkStatus status, AddProblem? addProblem, int addProblemCount, BulkEntry? lastAdded, BulkOutcome? outcome, DateTime? checkedAt, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class __$BulkLookupStateCopyWithImpl<$Res>
    implements _$BulkLookupStateCopyWith<$Res> {
  __$BulkLookupStateCopyWithImpl(this._self, this._then);

  final _BulkLookupState _self;
  final $Res Function(_BulkLookupState) _then;

/// Create a copy of BulkLookupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? formats = freezed,Object? formatsFailure = freezed,Object? entries = null,Object? status = null,Object? addProblem = freezed,Object? addProblemCount = null,Object? lastAdded = freezed,Object? outcome = freezed,Object? checkedAt = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_BulkLookupState(
formats: freezed == formats ? _self.formats : formats // ignore: cast_nullable_to_non_nullable
as InputFormats?,formatsFailure: freezed == formatsFailure ? _self.formatsFailure : formatsFailure // ignore: cast_nullable_to_non_nullable
as Failure?,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<BulkEntry>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BulkStatus,addProblem: freezed == addProblem ? _self.addProblem : addProblem // ignore: cast_nullable_to_non_nullable
as AddProblem?,addProblemCount: null == addProblemCount ? _self.addProblemCount : addProblemCount // ignore: cast_nullable_to_non_nullable
as int,lastAdded: freezed == lastAdded ? _self.lastAdded : lastAdded // ignore: cast_nullable_to_non_nullable
as BulkEntry?,outcome: freezed == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as BulkOutcome?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
