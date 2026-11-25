// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'access_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestableRole {

 int get id; String get name;
/// Create a copy of RequestableRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestableRoleCopyWith<RequestableRole> get copyWith => _$RequestableRoleCopyWithImpl<RequestableRole>(this as RequestableRole, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestableRole&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'RequestableRole(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $RequestableRoleCopyWith<$Res>  {
  factory $RequestableRoleCopyWith(RequestableRole value, $Res Function(RequestableRole) _then) = _$RequestableRoleCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$RequestableRoleCopyWithImpl<$Res>
    implements $RequestableRoleCopyWith<$Res> {
  _$RequestableRoleCopyWithImpl(this._self, this._then);

  final RequestableRole _self;
  final $Res Function(RequestableRole) _then;

/// Create a copy of RequestableRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestableRole].
extension RequestableRolePatterns on RequestableRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestableRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestableRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestableRole value)  $default,){
final _that = this;
switch (_that) {
case _RequestableRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestableRole value)?  $default,){
final _that = this;
switch (_that) {
case _RequestableRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestableRole() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _RequestableRole():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _RequestableRole() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _RequestableRole implements RequestableRole {
  const _RequestableRole({required this.id, required this.name});
  

@override final  int id;
@override final  String name;

/// Create a copy of RequestableRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestableRoleCopyWith<_RequestableRole> get copyWith => __$RequestableRoleCopyWithImpl<_RequestableRole>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestableRole&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'RequestableRole(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$RequestableRoleCopyWith<$Res> implements $RequestableRoleCopyWith<$Res> {
  factory _$RequestableRoleCopyWith(_RequestableRole value, $Res Function(_RequestableRole) _then) = __$RequestableRoleCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$RequestableRoleCopyWithImpl<$Res>
    implements _$RequestableRoleCopyWith<$Res> {
  __$RequestableRoleCopyWithImpl(this._self, this._then);

  final _RequestableRole _self;
  final $Res Function(_RequestableRole) _then;

/// Create a copy of RequestableRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_RequestableRole(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AccessRequest {

 String get email; String get code; String get name; int get roleId; String get password;
/// Create a copy of AccessRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessRequestCopyWith<AccessRequest> get copyWith => _$AccessRequestCopyWithImpl<AccessRequest>(this as AccessRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,code,name,roleId,password);



}

/// @nodoc
abstract mixin class $AccessRequestCopyWith<$Res>  {
  factory $AccessRequestCopyWith(AccessRequest value, $Res Function(AccessRequest) _then) = _$AccessRequestCopyWithImpl;
@useResult
$Res call({
 String email, String code, String name, int roleId, String password
});




}
/// @nodoc
class _$AccessRequestCopyWithImpl<$Res>
    implements $AccessRequestCopyWith<$Res> {
  _$AccessRequestCopyWithImpl(this._self, this._then);

  final AccessRequest _self;
  final $Res Function(AccessRequest) _then;

/// Create a copy of AccessRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? code = null,Object? name = null,Object? roleId = null,Object? password = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as int,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccessRequest].
extension AccessRequestPatterns on AccessRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccessRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccessRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccessRequest value)  $default,){
final _that = this;
switch (_that) {
case _AccessRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccessRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AccessRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String code,  String name,  int roleId,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccessRequest() when $default != null:
return $default(_that.email,_that.code,_that.name,_that.roleId,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String code,  String name,  int roleId,  String password)  $default,) {final _that = this;
switch (_that) {
case _AccessRequest():
return $default(_that.email,_that.code,_that.name,_that.roleId,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String code,  String name,  int roleId,  String password)?  $default,) {final _that = this;
switch (_that) {
case _AccessRequest() when $default != null:
return $default(_that.email,_that.code,_that.name,_that.roleId,_that.password);case _:
  return null;

}
}

}

/// @nodoc


class _AccessRequest extends AccessRequest {
  const _AccessRequest({required this.email, required this.code, required this.name, required this.roleId, required this.password}): super._();
  

@override final  String email;
@override final  String code;
@override final  String name;
@override final  int roleId;
@override final  String password;

/// Create a copy of AccessRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessRequestCopyWith<_AccessRequest> get copyWith => __$AccessRequestCopyWithImpl<_AccessRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessRequest&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode => Object.hash(runtimeType,email,code,name,roleId,password);



}

/// @nodoc
abstract mixin class _$AccessRequestCopyWith<$Res> implements $AccessRequestCopyWith<$Res> {
  factory _$AccessRequestCopyWith(_AccessRequest value, $Res Function(_AccessRequest) _then) = __$AccessRequestCopyWithImpl;
@override @useResult
$Res call({
 String email, String code, String name, int roleId, String password
});




}
/// @nodoc
class __$AccessRequestCopyWithImpl<$Res>
    implements _$AccessRequestCopyWith<$Res> {
  __$AccessRequestCopyWithImpl(this._self, this._then);

  final _AccessRequest _self;
  final $Res Function(_AccessRequest) _then;

/// Create a copy of AccessRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? code = null,Object? name = null,Object? roleId = null,Object? password = null,}) {
  return _then(_AccessRequest(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as int,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
