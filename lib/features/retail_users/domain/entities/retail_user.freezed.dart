// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retail_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RetailUser {

 String get id; String get name;/// Masked by the API (`ra***@gmail.com`) and shown as received.
 String get maskedEmail;
/// Create a copy of RetailUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RetailUserCopyWith<RetailUser> get copyWith => _$RetailUserCopyWithImpl<RetailUser>(this as RetailUser, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RetailUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.maskedEmail, maskedEmail) || other.maskedEmail == maskedEmail));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,maskedEmail);

@override
String toString() {
  return 'RetailUser(id: $id, name: $name, maskedEmail: $maskedEmail)';
}


}

/// @nodoc
abstract mixin class $RetailUserCopyWith<$Res>  {
  factory $RetailUserCopyWith(RetailUser value, $Res Function(RetailUser) _then) = _$RetailUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String maskedEmail
});




}
/// @nodoc
class _$RetailUserCopyWithImpl<$Res>
    implements $RetailUserCopyWith<$Res> {
  _$RetailUserCopyWithImpl(this._self, this._then);

  final RetailUser _self;
  final $Res Function(RetailUser) _then;

/// Create a copy of RetailUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? maskedEmail = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,maskedEmail: null == maskedEmail ? _self.maskedEmail : maskedEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RetailUser].
extension RetailUserPatterns on RetailUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RetailUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RetailUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RetailUser value)  $default,){
final _that = this;
switch (_that) {
case _RetailUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RetailUser value)?  $default,){
final _that = this;
switch (_that) {
case _RetailUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String maskedEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RetailUser() when $default != null:
return $default(_that.id,_that.name,_that.maskedEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String maskedEmail)  $default,) {final _that = this;
switch (_that) {
case _RetailUser():
return $default(_that.id,_that.name,_that.maskedEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String maskedEmail)?  $default,) {final _that = this;
switch (_that) {
case _RetailUser() when $default != null:
return $default(_that.id,_that.name,_that.maskedEmail);case _:
  return null;

}
}

}

/// @nodoc


class _RetailUser implements RetailUser {
  const _RetailUser({required this.id, required this.name, required this.maskedEmail});
  

@override final  String id;
@override final  String name;
/// Masked by the API (`ra***@gmail.com`) and shown as received.
@override final  String maskedEmail;

/// Create a copy of RetailUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RetailUserCopyWith<_RetailUser> get copyWith => __$RetailUserCopyWithImpl<_RetailUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RetailUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.maskedEmail, maskedEmail) || other.maskedEmail == maskedEmail));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,maskedEmail);

@override
String toString() {
  return 'RetailUser(id: $id, name: $name, maskedEmail: $maskedEmail)';
}


}

/// @nodoc
abstract mixin class _$RetailUserCopyWith<$Res> implements $RetailUserCopyWith<$Res> {
  factory _$RetailUserCopyWith(_RetailUser value, $Res Function(_RetailUser) _then) = __$RetailUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String maskedEmail
});




}
/// @nodoc
class __$RetailUserCopyWithImpl<$Res>
    implements _$RetailUserCopyWith<$Res> {
  __$RetailUserCopyWithImpl(this._self, this._then);

  final _RetailUser _self;
  final $Res Function(_RetailUser) _then;

/// Create a copy of RetailUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? maskedEmail = null,}) {
  return _then(_RetailUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,maskedEmail: null == maskedEmail ? _self.maskedEmail : maskedEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
