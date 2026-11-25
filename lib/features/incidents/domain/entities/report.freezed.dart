// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Report {

 int get id; DateTime get at; String get note;/// How many photos the report has, 0 to 3. Photos cannot be downloaded.
 int get photos;/// The check the report points to.
 String? get checkRef;/// The retail user the report names.
 String? get retailUserName;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.note, note) || other.note == note)&&(identical(other.photos, photos) || other.photos == photos)&&(identical(other.checkRef, checkRef) || other.checkRef == checkRef)&&(identical(other.retailUserName, retailUserName) || other.retailUserName == retailUserName));
}


@override
int get hashCode => Object.hash(runtimeType,id,at,note,photos,checkRef,retailUserName);

@override
String toString() {
  return 'Report(id: $id, at: $at, note: $note, photos: $photos, checkRef: $checkRef, retailUserName: $retailUserName)';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 int id, DateTime at, String note, int photos, String? checkRef, String? retailUserName
});




}
/// @nodoc
class _$ReportCopyWithImpl<$Res>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._self, this._then);

  final Report _self;
  final $Res Function(Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? at = null,Object? note = null,Object? photos = null,Object? checkRef = freezed,Object? retailUserName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as int,checkRef: freezed == checkRef ? _self.checkRef : checkRef // ignore: cast_nullable_to_non_nullable
as String?,retailUserName: freezed == retailUserName ? _self.retailUserName : retailUserName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Report].
extension ReportPatterns on Report {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Report value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Report value)  $default,){
final _that = this;
switch (_that) {
case _Report():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Report value)?  $default,){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime at,  String note,  int photos,  String? checkRef,  String? retailUserName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.at,_that.note,_that.photos,_that.checkRef,_that.retailUserName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime at,  String note,  int photos,  String? checkRef,  String? retailUserName)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.at,_that.note,_that.photos,_that.checkRef,_that.retailUserName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime at,  String note,  int photos,  String? checkRef,  String? retailUserName)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.at,_that.note,_that.photos,_that.checkRef,_that.retailUserName);case _:
  return null;

}
}

}

/// @nodoc


class _Report implements Report {
  const _Report({required this.id, required this.at, required this.note, required this.photos, this.checkRef, this.retailUserName});
  

@override final  int id;
@override final  DateTime at;
@override final  String note;
/// How many photos the report has, 0 to 3. Photos cannot be downloaded.
@override final  int photos;
/// The check the report points to.
@override final  String? checkRef;
/// The retail user the report names.
@override final  String? retailUserName;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCopyWith<_Report> get copyWith => __$ReportCopyWithImpl<_Report>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.note, note) || other.note == note)&&(identical(other.photos, photos) || other.photos == photos)&&(identical(other.checkRef, checkRef) || other.checkRef == checkRef)&&(identical(other.retailUserName, retailUserName) || other.retailUserName == retailUserName));
}


@override
int get hashCode => Object.hash(runtimeType,id,at,note,photos,checkRef,retailUserName);

@override
String toString() {
  return 'Report(id: $id, at: $at, note: $note, photos: $photos, checkRef: $checkRef, retailUserName: $retailUserName)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime at, String note, int photos, String? checkRef, String? retailUserName
});




}
/// @nodoc
class __$ReportCopyWithImpl<$Res>
    implements _$ReportCopyWith<$Res> {
  __$ReportCopyWithImpl(this._self, this._then);

  final _Report _self;
  final $Res Function(_Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? at = null,Object? note = null,Object? photos = null,Object? checkRef = freezed,Object? retailUserName = freezed,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as int,checkRef: freezed == checkRef ? _self.checkRef : checkRef // ignore: cast_nullable_to_non_nullable
as String?,retailUserName: freezed == retailUserName ? _self.retailUserName : retailUserName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
