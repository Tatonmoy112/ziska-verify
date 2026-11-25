// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_incident_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReportPhoto {

 int get localId; PreparedPhoto get photo; PhotoStatus get status;/// The photo's number on the report (`n`), once sent.
 int? get number; Failure? get failure;/// After a `429`: not sent again before this time (guide section 1).
 DateTime? get retryAt;
/// Create a copy of ReportPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportPhotoCopyWith<ReportPhoto> get copyWith => _$ReportPhotoCopyWithImpl<ReportPhoto>(this as ReportPhoto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportPhoto&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.status, status) || other.status == status)&&(identical(other.number, number) || other.number == number)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,localId,photo,status,number,failure,retryAt);

@override
String toString() {
  return 'ReportPhoto(localId: $localId, photo: $photo, status: $status, number: $number, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class $ReportPhotoCopyWith<$Res>  {
  factory $ReportPhotoCopyWith(ReportPhoto value, $Res Function(ReportPhoto) _then) = _$ReportPhotoCopyWithImpl;
@useResult
$Res call({
 int localId, PreparedPhoto photo, PhotoStatus status, int? number, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class _$ReportPhotoCopyWithImpl<$Res>
    implements $ReportPhotoCopyWith<$Res> {
  _$ReportPhotoCopyWithImpl(this._self, this._then);

  final ReportPhoto _self;
  final $Res Function(ReportPhoto) _then;

/// Create a copy of ReportPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localId = null,Object? photo = null,Object? status = null,Object? number = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_self.copyWith(
localId: null == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as int,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PreparedPhoto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PhotoStatus,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportPhoto].
extension ReportPhotoPatterns on ReportPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportPhoto value)  $default,){
final _that = this;
switch (_that) {
case _ReportPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _ReportPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int localId,  PreparedPhoto photo,  PhotoStatus status,  int? number,  Failure? failure,  DateTime? retryAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportPhoto() when $default != null:
return $default(_that.localId,_that.photo,_that.status,_that.number,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int localId,  PreparedPhoto photo,  PhotoStatus status,  int? number,  Failure? failure,  DateTime? retryAt)  $default,) {final _that = this;
switch (_that) {
case _ReportPhoto():
return $default(_that.localId,_that.photo,_that.status,_that.number,_that.failure,_that.retryAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int localId,  PreparedPhoto photo,  PhotoStatus status,  int? number,  Failure? failure,  DateTime? retryAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportPhoto() when $default != null:
return $default(_that.localId,_that.photo,_that.status,_that.number,_that.failure,_that.retryAt);case _:
  return null;

}
}

}

/// @nodoc


class _ReportPhoto extends ReportPhoto {
  const _ReportPhoto({required this.localId, required this.photo, this.status = PhotoStatus.waiting, this.number, this.failure, this.retryAt}): super._();
  

@override final  int localId;
@override final  PreparedPhoto photo;
@override@JsonKey() final  PhotoStatus status;
/// The photo's number on the report (`n`), once sent.
@override final  int? number;
@override final  Failure? failure;
/// After a `429`: not sent again before this time (guide section 1).
@override final  DateTime? retryAt;

/// Create a copy of ReportPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportPhotoCopyWith<_ReportPhoto> get copyWith => __$ReportPhotoCopyWithImpl<_ReportPhoto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportPhoto&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.photo, photo) || other.photo == photo)&&(identical(other.status, status) || other.status == status)&&(identical(other.number, number) || other.number == number)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt));
}


@override
int get hashCode => Object.hash(runtimeType,localId,photo,status,number,failure,retryAt);

@override
String toString() {
  return 'ReportPhoto(localId: $localId, photo: $photo, status: $status, number: $number, failure: $failure, retryAt: $retryAt)';
}


}

/// @nodoc
abstract mixin class _$ReportPhotoCopyWith<$Res> implements $ReportPhotoCopyWith<$Res> {
  factory _$ReportPhotoCopyWith(_ReportPhoto value, $Res Function(_ReportPhoto) _then) = __$ReportPhotoCopyWithImpl;
@override @useResult
$Res call({
 int localId, PreparedPhoto photo, PhotoStatus status, int? number, Failure? failure, DateTime? retryAt
});




}
/// @nodoc
class __$ReportPhotoCopyWithImpl<$Res>
    implements _$ReportPhotoCopyWith<$Res> {
  __$ReportPhotoCopyWithImpl(this._self, this._then);

  final _ReportPhoto _self;
  final $Res Function(_ReportPhoto) _then;

/// Create a copy of ReportPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localId = null,Object? photo = null,Object? status = null,Object? number = freezed,Object? failure = freezed,Object? retryAt = freezed,}) {
  return _then(_ReportPhoto(
localId: null == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as int,photo: null == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as PreparedPhoto,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PhotoStatus,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$ReportIncidentState {

 String? get checkRef; ({String id, String name})? get retailUser; List<ReportPhoto> get photos; FilingStatus get filing; int? get reportId; DateTime? get filedAt;/// Why filing failed.
 Failure? get failure;/// Why the last photo could not be prepared, and a counter to show it.
 PhotoProblem? get photoProblem; int get photoProblemCount;/// Counts photos the server already had on this report (it answered an
/// `n` another tile holds); each one is shown once.
 int get samePhotoCount;/// After a `429` on filing: no new filing before this time (final.md
/// §13.5, §15).
 DateTime? get retryAt;/// After a `404` on filing: what was not found.
 MissingLink? get missing;
/// Create a copy of ReportIncidentState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportIncidentStateCopyWith<ReportIncidentState> get copyWith => _$ReportIncidentStateCopyWithImpl<ReportIncidentState>(this as ReportIncidentState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportIncidentState&&(identical(other.checkRef, checkRef) || other.checkRef == checkRef)&&(identical(other.retailUser, retailUser) || other.retailUser == retailUser)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.filing, filing) || other.filing == filing)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.filedAt, filedAt) || other.filedAt == filedAt)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.photoProblem, photoProblem) || other.photoProblem == photoProblem)&&(identical(other.photoProblemCount, photoProblemCount) || other.photoProblemCount == photoProblemCount)&&(identical(other.samePhotoCount, samePhotoCount) || other.samePhotoCount == samePhotoCount)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt)&&(identical(other.missing, missing) || other.missing == missing));
}


@override
int get hashCode => Object.hash(runtimeType,checkRef,retailUser,const DeepCollectionEquality().hash(photos),filing,reportId,filedAt,failure,photoProblem,photoProblemCount,samePhotoCount,retryAt,missing);

@override
String toString() {
  return 'ReportIncidentState(checkRef: $checkRef, retailUser: $retailUser, photos: $photos, filing: $filing, reportId: $reportId, filedAt: $filedAt, failure: $failure, photoProblem: $photoProblem, photoProblemCount: $photoProblemCount, samePhotoCount: $samePhotoCount, retryAt: $retryAt, missing: $missing)';
}


}

/// @nodoc
abstract mixin class $ReportIncidentStateCopyWith<$Res>  {
  factory $ReportIncidentStateCopyWith(ReportIncidentState value, $Res Function(ReportIncidentState) _then) = _$ReportIncidentStateCopyWithImpl;
@useResult
$Res call({
 String? checkRef, ({String id, String name})? retailUser, List<ReportPhoto> photos, FilingStatus filing, int? reportId, DateTime? filedAt, Failure? failure, PhotoProblem? photoProblem, int photoProblemCount, int samePhotoCount, DateTime? retryAt, MissingLink? missing
});




}
/// @nodoc
class _$ReportIncidentStateCopyWithImpl<$Res>
    implements $ReportIncidentStateCopyWith<$Res> {
  _$ReportIncidentStateCopyWithImpl(this._self, this._then);

  final ReportIncidentState _self;
  final $Res Function(ReportIncidentState) _then;

/// Create a copy of ReportIncidentState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? checkRef = freezed,Object? retailUser = freezed,Object? photos = null,Object? filing = null,Object? reportId = freezed,Object? filedAt = freezed,Object? failure = freezed,Object? photoProblem = freezed,Object? photoProblemCount = null,Object? samePhotoCount = null,Object? retryAt = freezed,Object? missing = freezed,}) {
  return _then(_self.copyWith(
checkRef: freezed == checkRef ? _self.checkRef : checkRef // ignore: cast_nullable_to_non_nullable
as String?,retailUser: freezed == retailUser ? _self.retailUser : retailUser // ignore: cast_nullable_to_non_nullable
as ({String id, String name})?,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<ReportPhoto>,filing: null == filing ? _self.filing : filing // ignore: cast_nullable_to_non_nullable
as FilingStatus,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int?,filedAt: freezed == filedAt ? _self.filedAt : filedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,photoProblem: freezed == photoProblem ? _self.photoProblem : photoProblem // ignore: cast_nullable_to_non_nullable
as PhotoProblem?,photoProblemCount: null == photoProblemCount ? _self.photoProblemCount : photoProblemCount // ignore: cast_nullable_to_non_nullable
as int,samePhotoCount: null == samePhotoCount ? _self.samePhotoCount : samePhotoCount // ignore: cast_nullable_to_non_nullable
as int,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,missing: freezed == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as MissingLink?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportIncidentState].
extension ReportIncidentStatePatterns on ReportIncidentState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportIncidentState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportIncidentState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportIncidentState value)  $default,){
final _that = this;
switch (_that) {
case _ReportIncidentState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportIncidentState value)?  $default,){
final _that = this;
switch (_that) {
case _ReportIncidentState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? checkRef,  ({String id, String name})? retailUser,  List<ReportPhoto> photos,  FilingStatus filing,  int? reportId,  DateTime? filedAt,  Failure? failure,  PhotoProblem? photoProblem,  int photoProblemCount,  int samePhotoCount,  DateTime? retryAt,  MissingLink? missing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportIncidentState() when $default != null:
return $default(_that.checkRef,_that.retailUser,_that.photos,_that.filing,_that.reportId,_that.filedAt,_that.failure,_that.photoProblem,_that.photoProblemCount,_that.samePhotoCount,_that.retryAt,_that.missing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? checkRef,  ({String id, String name})? retailUser,  List<ReportPhoto> photos,  FilingStatus filing,  int? reportId,  DateTime? filedAt,  Failure? failure,  PhotoProblem? photoProblem,  int photoProblemCount,  int samePhotoCount,  DateTime? retryAt,  MissingLink? missing)  $default,) {final _that = this;
switch (_that) {
case _ReportIncidentState():
return $default(_that.checkRef,_that.retailUser,_that.photos,_that.filing,_that.reportId,_that.filedAt,_that.failure,_that.photoProblem,_that.photoProblemCount,_that.samePhotoCount,_that.retryAt,_that.missing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? checkRef,  ({String id, String name})? retailUser,  List<ReportPhoto> photos,  FilingStatus filing,  int? reportId,  DateTime? filedAt,  Failure? failure,  PhotoProblem? photoProblem,  int photoProblemCount,  int samePhotoCount,  DateTime? retryAt,  MissingLink? missing)?  $default,) {final _that = this;
switch (_that) {
case _ReportIncidentState() when $default != null:
return $default(_that.checkRef,_that.retailUser,_that.photos,_that.filing,_that.reportId,_that.filedAt,_that.failure,_that.photoProblem,_that.photoProblemCount,_that.samePhotoCount,_that.retryAt,_that.missing);case _:
  return null;

}
}

}

/// @nodoc


class _ReportIncidentState extends ReportIncidentState {
  const _ReportIncidentState({this.checkRef, this.retailUser, final  List<ReportPhoto> photos = const <ReportPhoto>[], this.filing = FilingStatus.editing, this.reportId, this.filedAt, this.failure, this.photoProblem, this.photoProblemCount = 0, this.samePhotoCount = 0, this.retryAt, this.missing}): _photos = photos,super._();
  

@override final  String? checkRef;
@override final  ({String id, String name})? retailUser;
 final  List<ReportPhoto> _photos;
@override@JsonKey() List<ReportPhoto> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override@JsonKey() final  FilingStatus filing;
@override final  int? reportId;
@override final  DateTime? filedAt;
/// Why filing failed.
@override final  Failure? failure;
/// Why the last photo could not be prepared, and a counter to show it.
@override final  PhotoProblem? photoProblem;
@override@JsonKey() final  int photoProblemCount;
/// Counts photos the server already had on this report (it answered an
/// `n` another tile holds); each one is shown once.
@override@JsonKey() final  int samePhotoCount;
/// After a `429` on filing: no new filing before this time (final.md
/// §13.5, §15).
@override final  DateTime? retryAt;
/// After a `404` on filing: what was not found.
@override final  MissingLink? missing;

/// Create a copy of ReportIncidentState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportIncidentStateCopyWith<_ReportIncidentState> get copyWith => __$ReportIncidentStateCopyWithImpl<_ReportIncidentState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportIncidentState&&(identical(other.checkRef, checkRef) || other.checkRef == checkRef)&&(identical(other.retailUser, retailUser) || other.retailUser == retailUser)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.filing, filing) || other.filing == filing)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.filedAt, filedAt) || other.filedAt == filedAt)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.photoProblem, photoProblem) || other.photoProblem == photoProblem)&&(identical(other.photoProblemCount, photoProblemCount) || other.photoProblemCount == photoProblemCount)&&(identical(other.samePhotoCount, samePhotoCount) || other.samePhotoCount == samePhotoCount)&&(identical(other.retryAt, retryAt) || other.retryAt == retryAt)&&(identical(other.missing, missing) || other.missing == missing));
}


@override
int get hashCode => Object.hash(runtimeType,checkRef,retailUser,const DeepCollectionEquality().hash(_photos),filing,reportId,filedAt,failure,photoProblem,photoProblemCount,samePhotoCount,retryAt,missing);

@override
String toString() {
  return 'ReportIncidentState(checkRef: $checkRef, retailUser: $retailUser, photos: $photos, filing: $filing, reportId: $reportId, filedAt: $filedAt, failure: $failure, photoProblem: $photoProblem, photoProblemCount: $photoProblemCount, samePhotoCount: $samePhotoCount, retryAt: $retryAt, missing: $missing)';
}


}

/// @nodoc
abstract mixin class _$ReportIncidentStateCopyWith<$Res> implements $ReportIncidentStateCopyWith<$Res> {
  factory _$ReportIncidentStateCopyWith(_ReportIncidentState value, $Res Function(_ReportIncidentState) _then) = __$ReportIncidentStateCopyWithImpl;
@override @useResult
$Res call({
 String? checkRef, ({String id, String name})? retailUser, List<ReportPhoto> photos, FilingStatus filing, int? reportId, DateTime? filedAt, Failure? failure, PhotoProblem? photoProblem, int photoProblemCount, int samePhotoCount, DateTime? retryAt, MissingLink? missing
});




}
/// @nodoc
class __$ReportIncidentStateCopyWithImpl<$Res>
    implements _$ReportIncidentStateCopyWith<$Res> {
  __$ReportIncidentStateCopyWithImpl(this._self, this._then);

  final _ReportIncidentState _self;
  final $Res Function(_ReportIncidentState) _then;

/// Create a copy of ReportIncidentState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? checkRef = freezed,Object? retailUser = freezed,Object? photos = null,Object? filing = null,Object? reportId = freezed,Object? filedAt = freezed,Object? failure = freezed,Object? photoProblem = freezed,Object? photoProblemCount = null,Object? samePhotoCount = null,Object? retryAt = freezed,Object? missing = freezed,}) {
  return _then(_ReportIncidentState(
checkRef: freezed == checkRef ? _self.checkRef : checkRef // ignore: cast_nullable_to_non_nullable
as String?,retailUser: freezed == retailUser ? _self.retailUser : retailUser // ignore: cast_nullable_to_non_nullable
as ({String id, String name})?,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<ReportPhoto>,filing: null == filing ? _self.filing : filing // ignore: cast_nullable_to_non_nullable
as FilingStatus,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as int?,filedAt: freezed == filedAt ? _self.filedAt : filedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure?,photoProblem: freezed == photoProblem ? _self.photoProblem : photoProblem // ignore: cast_nullable_to_non_nullable
as PhotoProblem?,photoProblemCount: null == photoProblemCount ? _self.photoProblemCount : photoProblemCount // ignore: cast_nullable_to_non_nullable
as int,samePhotoCount: null == samePhotoCount ? _self.samePhotoCount : samePhotoCount // ignore: cast_nullable_to_non_nullable
as int,retryAt: freezed == retryAt ? _self.retryAt : retryAt // ignore: cast_nullable_to_non_nullable
as DateTime?,missing: freezed == missing ? _self.missing : missing // ignore: cast_nullable_to_non_nullable
as MissingLink?,
  ));
}


}

// dart format on
