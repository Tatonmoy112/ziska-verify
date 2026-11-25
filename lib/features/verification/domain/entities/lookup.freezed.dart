// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lookup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CodeFormat {

 int get length; String get characters;
/// Create a copy of CodeFormat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeFormatCopyWith<CodeFormat> get copyWith => _$CodeFormatCopyWithImpl<CodeFormat>(this as CodeFormat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeFormat&&(identical(other.length, length) || other.length == length)&&(identical(other.characters, characters) || other.characters == characters));
}


@override
int get hashCode => Object.hash(runtimeType,length,characters);

@override
String toString() {
  return 'CodeFormat(length: $length, characters: $characters)';
}


}

/// @nodoc
abstract mixin class $CodeFormatCopyWith<$Res>  {
  factory $CodeFormatCopyWith(CodeFormat value, $Res Function(CodeFormat) _then) = _$CodeFormatCopyWithImpl;
@useResult
$Res call({
 int length, String characters
});




}
/// @nodoc
class _$CodeFormatCopyWithImpl<$Res>
    implements $CodeFormatCopyWith<$Res> {
  _$CodeFormatCopyWithImpl(this._self, this._then);

  final CodeFormat _self;
  final $Res Function(CodeFormat) _then;

/// Create a copy of CodeFormat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? length = null,Object? characters = null,}) {
  return _then(_self.copyWith(
length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CodeFormat].
extension CodeFormatPatterns on CodeFormat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CodeFormat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CodeFormat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CodeFormat value)  $default,){
final _that = this;
switch (_that) {
case _CodeFormat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CodeFormat value)?  $default,){
final _that = this;
switch (_that) {
case _CodeFormat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int length,  String characters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CodeFormat() when $default != null:
return $default(_that.length,_that.characters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int length,  String characters)  $default,) {final _that = this;
switch (_that) {
case _CodeFormat():
return $default(_that.length,_that.characters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int length,  String characters)?  $default,) {final _that = this;
switch (_that) {
case _CodeFormat() when $default != null:
return $default(_that.length,_that.characters);case _:
  return null;

}
}

}

/// @nodoc


class _CodeFormat implements CodeFormat {
  const _CodeFormat({required this.length, required this.characters});
  

@override final  int length;
@override final  String characters;

/// Create a copy of CodeFormat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CodeFormatCopyWith<_CodeFormat> get copyWith => __$CodeFormatCopyWithImpl<_CodeFormat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CodeFormat&&(identical(other.length, length) || other.length == length)&&(identical(other.characters, characters) || other.characters == characters));
}


@override
int get hashCode => Object.hash(runtimeType,length,characters);

@override
String toString() {
  return 'CodeFormat(length: $length, characters: $characters)';
}


}

/// @nodoc
abstract mixin class _$CodeFormatCopyWith<$Res> implements $CodeFormatCopyWith<$Res> {
  factory _$CodeFormatCopyWith(_CodeFormat value, $Res Function(_CodeFormat) _then) = __$CodeFormatCopyWithImpl;
@override @useResult
$Res call({
 int length, String characters
});




}
/// @nodoc
class __$CodeFormatCopyWithImpl<$Res>
    implements _$CodeFormatCopyWith<$Res> {
  __$CodeFormatCopyWithImpl(this._self, this._then);

  final _CodeFormat _self;
  final $Res Function(_CodeFormat) _then;

/// Create a copy of CodeFormat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? length = null,Object? characters = null,}) {
  return _then(_CodeFormat(
length: null == length ? _self.length : length // ignore: cast_nullable_to_non_nullable
as int,characters: null == characters ? _self.characters : characters // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$InputFormats {

 int get serialMaxDigits; CodeFormat get qr;
/// Create a copy of InputFormats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InputFormatsCopyWith<InputFormats> get copyWith => _$InputFormatsCopyWithImpl<InputFormats>(this as InputFormats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InputFormats&&(identical(other.serialMaxDigits, serialMaxDigits) || other.serialMaxDigits == serialMaxDigits)&&(identical(other.qr, qr) || other.qr == qr));
}


@override
int get hashCode => Object.hash(runtimeType,serialMaxDigits,qr);

@override
String toString() {
  return 'InputFormats(serialMaxDigits: $serialMaxDigits, qr: $qr)';
}


}

/// @nodoc
abstract mixin class $InputFormatsCopyWith<$Res>  {
  factory $InputFormatsCopyWith(InputFormats value, $Res Function(InputFormats) _then) = _$InputFormatsCopyWithImpl;
@useResult
$Res call({
 int serialMaxDigits, CodeFormat qr
});


$CodeFormatCopyWith<$Res> get qr;

}
/// @nodoc
class _$InputFormatsCopyWithImpl<$Res>
    implements $InputFormatsCopyWith<$Res> {
  _$InputFormatsCopyWithImpl(this._self, this._then);

  final InputFormats _self;
  final $Res Function(InputFormats) _then;

/// Create a copy of InputFormats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serialMaxDigits = null,Object? qr = null,}) {
  return _then(_self.copyWith(
serialMaxDigits: null == serialMaxDigits ? _self.serialMaxDigits : serialMaxDigits // ignore: cast_nullable_to_non_nullable
as int,qr: null == qr ? _self.qr : qr // ignore: cast_nullable_to_non_nullable
as CodeFormat,
  ));
}
/// Create a copy of InputFormats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CodeFormatCopyWith<$Res> get qr {
  
  return $CodeFormatCopyWith<$Res>(_self.qr, (value) {
    return _then(_self.copyWith(qr: value));
  });
}
}


/// Adds pattern-matching-related methods to [InputFormats].
extension InputFormatsPatterns on InputFormats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InputFormats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InputFormats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InputFormats value)  $default,){
final _that = this;
switch (_that) {
case _InputFormats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InputFormats value)?  $default,){
final _that = this;
switch (_that) {
case _InputFormats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int serialMaxDigits,  CodeFormat qr)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InputFormats() when $default != null:
return $default(_that.serialMaxDigits,_that.qr);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int serialMaxDigits,  CodeFormat qr)  $default,) {final _that = this;
switch (_that) {
case _InputFormats():
return $default(_that.serialMaxDigits,_that.qr);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int serialMaxDigits,  CodeFormat qr)?  $default,) {final _that = this;
switch (_that) {
case _InputFormats() when $default != null:
return $default(_that.serialMaxDigits,_that.qr);case _:
  return null;

}
}

}

/// @nodoc


class _InputFormats implements InputFormats {
  const _InputFormats({required this.serialMaxDigits, required this.qr});
  

@override final  int serialMaxDigits;
@override final  CodeFormat qr;

/// Create a copy of InputFormats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InputFormatsCopyWith<_InputFormats> get copyWith => __$InputFormatsCopyWithImpl<_InputFormats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InputFormats&&(identical(other.serialMaxDigits, serialMaxDigits) || other.serialMaxDigits == serialMaxDigits)&&(identical(other.qr, qr) || other.qr == qr));
}


@override
int get hashCode => Object.hash(runtimeType,serialMaxDigits,qr);

@override
String toString() {
  return 'InputFormats(serialMaxDigits: $serialMaxDigits, qr: $qr)';
}


}

/// @nodoc
abstract mixin class _$InputFormatsCopyWith<$Res> implements $InputFormatsCopyWith<$Res> {
  factory _$InputFormatsCopyWith(_InputFormats value, $Res Function(_InputFormats) _then) = __$InputFormatsCopyWithImpl;
@override @useResult
$Res call({
 int serialMaxDigits, CodeFormat qr
});


@override $CodeFormatCopyWith<$Res> get qr;

}
/// @nodoc
class __$InputFormatsCopyWithImpl<$Res>
    implements _$InputFormatsCopyWith<$Res> {
  __$InputFormatsCopyWithImpl(this._self, this._then);

  final _InputFormats _self;
  final $Res Function(_InputFormats) _then;

/// Create a copy of InputFormats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serialMaxDigits = null,Object? qr = null,}) {
  return _then(_InputFormats(
serialMaxDigits: null == serialMaxDigits ? _self.serialMaxDigits : serialMaxDigits // ignore: cast_nullable_to_non_nullable
as int,qr: null == qr ? _self.qr : qr // ignore: cast_nullable_to_non_nullable
as CodeFormat,
  ));
}

/// Create a copy of InputFormats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CodeFormatCopyWith<$Res> get qr {
  
  return $CodeFormatCopyWith<$Res>(_self.qr, (value) {
    return _then(_self.copyWith(qr: value));
  });
}
}

/// @nodoc
mixin _$Product {

 String get name; String? get genericName; String? get shortName; String? get pictureUrl;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.name, name) || other.name == name)&&(identical(other.genericName, genericName) || other.genericName == genericName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.pictureUrl, pictureUrl) || other.pictureUrl == pictureUrl));
}


@override
int get hashCode => Object.hash(runtimeType,name,genericName,shortName,pictureUrl);

@override
String toString() {
  return 'Product(name: $name, genericName: $genericName, shortName: $shortName, pictureUrl: $pictureUrl)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String name, String? genericName, String? shortName, String? pictureUrl
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? genericName = freezed,Object? shortName = freezed,Object? pictureUrl = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,genericName: freezed == genericName ? _self.genericName : genericName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,pictureUrl: freezed == pictureUrl ? _self.pictureUrl : pictureUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? genericName,  String? shortName,  String? pictureUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.name,_that.genericName,_that.shortName,_that.pictureUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? genericName,  String? shortName,  String? pictureUrl)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.name,_that.genericName,_that.shortName,_that.pictureUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? genericName,  String? shortName,  String? pictureUrl)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.name,_that.genericName,_that.shortName,_that.pictureUrl);case _:
  return null;

}
}

}

/// @nodoc


class _Product implements Product {
  const _Product({required this.name, this.genericName, this.shortName, this.pictureUrl});
  

@override final  String name;
@override final  String? genericName;
@override final  String? shortName;
@override final  String? pictureUrl;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.name, name) || other.name == name)&&(identical(other.genericName, genericName) || other.genericName == genericName)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.pictureUrl, pictureUrl) || other.pictureUrl == pictureUrl));
}


@override
int get hashCode => Object.hash(runtimeType,name,genericName,shortName,pictureUrl);

@override
String toString() {
  return 'Product(name: $name, genericName: $genericName, shortName: $shortName, pictureUrl: $pictureUrl)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String name, String? genericName, String? shortName, String? pictureUrl
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? genericName = freezed,Object? shortName = freezed,Object? pictureUrl = freezed,}) {
  return _then(_Product(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,genericName: freezed == genericName ? _self.genericName : genericName // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,pictureUrl: freezed == pictureUrl ? _self.pictureUrl : pictureUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Batch {

 String get number;/// `YYYY-MM-DD` dates, either can be `null`.
 DateTime? get made; DateTime? get expires;
/// Create a copy of Batch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatchCopyWith<Batch> get copyWith => _$BatchCopyWithImpl<Batch>(this as Batch, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Batch&&(identical(other.number, number) || other.number == number)&&(identical(other.made, made) || other.made == made)&&(identical(other.expires, expires) || other.expires == expires));
}


@override
int get hashCode => Object.hash(runtimeType,number,made,expires);

@override
String toString() {
  return 'Batch(number: $number, made: $made, expires: $expires)';
}


}

/// @nodoc
abstract mixin class $BatchCopyWith<$Res>  {
  factory $BatchCopyWith(Batch value, $Res Function(Batch) _then) = _$BatchCopyWithImpl;
@useResult
$Res call({
 String number, DateTime? made, DateTime? expires
});




}
/// @nodoc
class _$BatchCopyWithImpl<$Res>
    implements $BatchCopyWith<$Res> {
  _$BatchCopyWithImpl(this._self, this._then);

  final Batch _self;
  final $Res Function(Batch) _then;

/// Create a copy of Batch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? made = freezed,Object? expires = freezed,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,made: freezed == made ? _self.made : made // ignore: cast_nullable_to_non_nullable
as DateTime?,expires: freezed == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Batch].
extension BatchPatterns on Batch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Batch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Batch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Batch value)  $default,){
final _that = this;
switch (_that) {
case _Batch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Batch value)?  $default,){
final _that = this;
switch (_that) {
case _Batch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String number,  DateTime? made,  DateTime? expires)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Batch() when $default != null:
return $default(_that.number,_that.made,_that.expires);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String number,  DateTime? made,  DateTime? expires)  $default,) {final _that = this;
switch (_that) {
case _Batch():
return $default(_that.number,_that.made,_that.expires);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String number,  DateTime? made,  DateTime? expires)?  $default,) {final _that = this;
switch (_that) {
case _Batch() when $default != null:
return $default(_that.number,_that.made,_that.expires);case _:
  return null;

}
}

}

/// @nodoc


class _Batch implements Batch {
  const _Batch({required this.number, this.made, this.expires});
  

@override final  String number;
/// `YYYY-MM-DD` dates, either can be `null`.
@override final  DateTime? made;
@override final  DateTime? expires;

/// Create a copy of Batch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatchCopyWith<_Batch> get copyWith => __$BatchCopyWithImpl<_Batch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Batch&&(identical(other.number, number) || other.number == number)&&(identical(other.made, made) || other.made == made)&&(identical(other.expires, expires) || other.expires == expires));
}


@override
int get hashCode => Object.hash(runtimeType,number,made,expires);

@override
String toString() {
  return 'Batch(number: $number, made: $made, expires: $expires)';
}


}

/// @nodoc
abstract mixin class _$BatchCopyWith<$Res> implements $BatchCopyWith<$Res> {
  factory _$BatchCopyWith(_Batch value, $Res Function(_Batch) _then) = __$BatchCopyWithImpl;
@override @useResult
$Res call({
 String number, DateTime? made, DateTime? expires
});




}
/// @nodoc
class __$BatchCopyWithImpl<$Res>
    implements _$BatchCopyWith<$Res> {
  __$BatchCopyWithImpl(this._self, this._then);

  final _Batch _self;
  final $Res Function(_Batch) _then;

/// Create a copy of Batch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? made = freezed,Object? expires = freezed,}) {
  return _then(_Batch(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,made: freezed == made ? _self.made : made // ignore: cast_nullable_to_non_nullable
as DateTime?,expires: freezed == expires ? _self.expires : expires // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$ItemDetails {

 String get serial;/// The hidden code as the API sends it (`*****7K2`), shown as received.
 String get maskedCode; Product get product; Batch get batch;
/// Create a copy of ItemDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemDetailsCopyWith<ItemDetails> get copyWith => _$ItemDetailsCopyWithImpl<ItemDetails>(this as ItemDetails, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemDetails&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.maskedCode, maskedCode) || other.maskedCode == maskedCode)&&(identical(other.product, product) || other.product == product)&&(identical(other.batch, batch) || other.batch == batch));
}


@override
int get hashCode => Object.hash(runtimeType,serial,maskedCode,product,batch);

@override
String toString() {
  return 'ItemDetails(serial: $serial, maskedCode: $maskedCode, product: $product, batch: $batch)';
}


}

/// @nodoc
abstract mixin class $ItemDetailsCopyWith<$Res>  {
  factory $ItemDetailsCopyWith(ItemDetails value, $Res Function(ItemDetails) _then) = _$ItemDetailsCopyWithImpl;
@useResult
$Res call({
 String serial, String maskedCode, Product product, Batch batch
});


$ProductCopyWith<$Res> get product;$BatchCopyWith<$Res> get batch;

}
/// @nodoc
class _$ItemDetailsCopyWithImpl<$Res>
    implements $ItemDetailsCopyWith<$Res> {
  _$ItemDetailsCopyWithImpl(this._self, this._then);

  final ItemDetails _self;
  final $Res Function(ItemDetails) _then;

/// Create a copy of ItemDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serial = null,Object? maskedCode = null,Object? product = null,Object? batch = null,}) {
  return _then(_self.copyWith(
serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,maskedCode: null == maskedCode ? _self.maskedCode : maskedCode // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,batch: null == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as Batch,
  ));
}
/// Create a copy of ItemDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of ItemDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchCopyWith<$Res> get batch {
  
  return $BatchCopyWith<$Res>(_self.batch, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}


/// Adds pattern-matching-related methods to [ItemDetails].
extension ItemDetailsPatterns on ItemDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemDetails value)  $default,){
final _that = this;
switch (_that) {
case _ItemDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemDetails value)?  $default,){
final _that = this;
switch (_that) {
case _ItemDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serial,  String maskedCode,  Product product,  Batch batch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemDetails() when $default != null:
return $default(_that.serial,_that.maskedCode,_that.product,_that.batch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serial,  String maskedCode,  Product product,  Batch batch)  $default,) {final _that = this;
switch (_that) {
case _ItemDetails():
return $default(_that.serial,_that.maskedCode,_that.product,_that.batch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serial,  String maskedCode,  Product product,  Batch batch)?  $default,) {final _that = this;
switch (_that) {
case _ItemDetails() when $default != null:
return $default(_that.serial,_that.maskedCode,_that.product,_that.batch);case _:
  return null;

}
}

}

/// @nodoc


class _ItemDetails implements ItemDetails {
  const _ItemDetails({required this.serial, required this.maskedCode, required this.product, required this.batch});
  

@override final  String serial;
/// The hidden code as the API sends it (`*****7K2`), shown as received.
@override final  String maskedCode;
@override final  Product product;
@override final  Batch batch;

/// Create a copy of ItemDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemDetailsCopyWith<_ItemDetails> get copyWith => __$ItemDetailsCopyWithImpl<_ItemDetails>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemDetails&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.maskedCode, maskedCode) || other.maskedCode == maskedCode)&&(identical(other.product, product) || other.product == product)&&(identical(other.batch, batch) || other.batch == batch));
}


@override
int get hashCode => Object.hash(runtimeType,serial,maskedCode,product,batch);

@override
String toString() {
  return 'ItemDetails(serial: $serial, maskedCode: $maskedCode, product: $product, batch: $batch)';
}


}

/// @nodoc
abstract mixin class _$ItemDetailsCopyWith<$Res> implements $ItemDetailsCopyWith<$Res> {
  factory _$ItemDetailsCopyWith(_ItemDetails value, $Res Function(_ItemDetails) _then) = __$ItemDetailsCopyWithImpl;
@override @useResult
$Res call({
 String serial, String maskedCode, Product product, Batch batch
});


@override $ProductCopyWith<$Res> get product;@override $BatchCopyWith<$Res> get batch;

}
/// @nodoc
class __$ItemDetailsCopyWithImpl<$Res>
    implements _$ItemDetailsCopyWith<$Res> {
  __$ItemDetailsCopyWithImpl(this._self, this._then);

  final _ItemDetails _self;
  final $Res Function(_ItemDetails) _then;

/// Create a copy of ItemDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serial = null,Object? maskedCode = null,Object? product = null,Object? batch = null,}) {
  return _then(_ItemDetails(
serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,maskedCode: null == maskedCode ? _self.maskedCode : maskedCode // ignore: cast_nullable_to_non_nullable
as String,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,batch: null == batch ? _self.batch : batch // ignore: cast_nullable_to_non_nullable
as Batch,
  ));
}

/// Create a copy of ItemDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductCopyWith<$Res> get product {
  
  return $ProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of ItemDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BatchCopyWith<$Res> get batch {
  
  return $BatchCopyWith<$Res>(_self.batch, (value) {
    return _then(_self.copyWith(batch: value));
  });
}
}

/// @nodoc
mixin _$CheckCount {

/// This check's number for the item (1 for a first check).
 int get thisCheck;/// The check before, `null` on a first check.
 DateTime? get lastAt;
/// Create a copy of CheckCount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckCountCopyWith<CheckCount> get copyWith => _$CheckCountCopyWithImpl<CheckCount>(this as CheckCount, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckCount&&(identical(other.thisCheck, thisCheck) || other.thisCheck == thisCheck)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt));
}


@override
int get hashCode => Object.hash(runtimeType,thisCheck,lastAt);

@override
String toString() {
  return 'CheckCount(thisCheck: $thisCheck, lastAt: $lastAt)';
}


}

/// @nodoc
abstract mixin class $CheckCountCopyWith<$Res>  {
  factory $CheckCountCopyWith(CheckCount value, $Res Function(CheckCount) _then) = _$CheckCountCopyWithImpl;
@useResult
$Res call({
 int thisCheck, DateTime? lastAt
});




}
/// @nodoc
class _$CheckCountCopyWithImpl<$Res>
    implements $CheckCountCopyWith<$Res> {
  _$CheckCountCopyWithImpl(this._self, this._then);

  final CheckCount _self;
  final $Res Function(CheckCount) _then;

/// Create a copy of CheckCount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? thisCheck = null,Object? lastAt = freezed,}) {
  return _then(_self.copyWith(
thisCheck: null == thisCheck ? _self.thisCheck : thisCheck // ignore: cast_nullable_to_non_nullable
as int,lastAt: freezed == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckCount].
extension CheckCountPatterns on CheckCount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckCount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckCount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckCount value)  $default,){
final _that = this;
switch (_that) {
case _CheckCount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckCount value)?  $default,){
final _that = this;
switch (_that) {
case _CheckCount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int thisCheck,  DateTime? lastAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckCount() when $default != null:
return $default(_that.thisCheck,_that.lastAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int thisCheck,  DateTime? lastAt)  $default,) {final _that = this;
switch (_that) {
case _CheckCount():
return $default(_that.thisCheck,_that.lastAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int thisCheck,  DateTime? lastAt)?  $default,) {final _that = this;
switch (_that) {
case _CheckCount() when $default != null:
return $default(_that.thisCheck,_that.lastAt);case _:
  return null;

}
}

}

/// @nodoc


class _CheckCount implements CheckCount {
  const _CheckCount({required this.thisCheck, this.lastAt});
  

/// This check's number for the item (1 for a first check).
@override final  int thisCheck;
/// The check before, `null` on a first check.
@override final  DateTime? lastAt;

/// Create a copy of CheckCount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckCountCopyWith<_CheckCount> get copyWith => __$CheckCountCopyWithImpl<_CheckCount>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckCount&&(identical(other.thisCheck, thisCheck) || other.thisCheck == thisCheck)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt));
}


@override
int get hashCode => Object.hash(runtimeType,thisCheck,lastAt);

@override
String toString() {
  return 'CheckCount(thisCheck: $thisCheck, lastAt: $lastAt)';
}


}

/// @nodoc
abstract mixin class _$CheckCountCopyWith<$Res> implements $CheckCountCopyWith<$Res> {
  factory _$CheckCountCopyWith(_CheckCount value, $Res Function(_CheckCount) _then) = __$CheckCountCopyWithImpl;
@override @useResult
$Res call({
 int thisCheck, DateTime? lastAt
});




}
/// @nodoc
class __$CheckCountCopyWithImpl<$Res>
    implements _$CheckCountCopyWith<$Res> {
  __$CheckCountCopyWithImpl(this._self, this._then);

  final _CheckCount _self;
  final $Res Function(_CheckCount) _then;

/// Create a copy of CheckCount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? thisCheck = null,Object? lastAt = freezed,}) {
  return _then(_CheckCount(
thisCheck: null == thisCheck ? _self.thisCheck : thisCheck // ignore: cast_nullable_to_non_nullable
as int,lastAt: freezed == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$LookupResult {

/// The check's reference number, on every result.
 String get ref; LookupOutcome get outcome; List<LookupReason> get reasons;/// Present for `valid` and `warning`.
 CheckCount? get count; ItemDetails? get item;
/// Create a copy of LookupResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LookupResultCopyWith<LookupResult> get copyWith => _$LookupResultCopyWithImpl<LookupResult>(this as LookupResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupResult&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&const DeepCollectionEquality().equals(other.reasons, reasons)&&(identical(other.count, count) || other.count == count)&&(identical(other.item, item) || other.item == item));
}


@override
int get hashCode => Object.hash(runtimeType,ref,outcome,const DeepCollectionEquality().hash(reasons),count,item);

@override
String toString() {
  return 'LookupResult(ref: $ref, outcome: $outcome, reasons: $reasons, count: $count, item: $item)';
}


}

/// @nodoc
abstract mixin class $LookupResultCopyWith<$Res>  {
  factory $LookupResultCopyWith(LookupResult value, $Res Function(LookupResult) _then) = _$LookupResultCopyWithImpl;
@useResult
$Res call({
 String ref, LookupOutcome outcome, List<LookupReason> reasons, CheckCount? count, ItemDetails? item
});


$CheckCountCopyWith<$Res>? get count;$ItemDetailsCopyWith<$Res>? get item;

}
/// @nodoc
class _$LookupResultCopyWithImpl<$Res>
    implements $LookupResultCopyWith<$Res> {
  _$LookupResultCopyWithImpl(this._self, this._then);

  final LookupResult _self;
  final $Res Function(LookupResult) _then;

/// Create a copy of LookupResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ref = null,Object? outcome = null,Object? reasons = null,Object? count = freezed,Object? item = freezed,}) {
  return _then(_self.copyWith(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as LookupOutcome,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<LookupReason>,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as CheckCount?,item: freezed == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as ItemDetails?,
  ));
}
/// Create a copy of LookupResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckCountCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $CheckCountCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}/// Create a copy of LookupResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemDetailsCopyWith<$Res>? get item {
    if (_self.item == null) {
    return null;
  }

  return $ItemDetailsCopyWith<$Res>(_self.item!, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [LookupResult].
extension LookupResultPatterns on LookupResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LookupResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LookupResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LookupResult value)  $default,){
final _that = this;
switch (_that) {
case _LookupResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LookupResult value)?  $default,){
final _that = this;
switch (_that) {
case _LookupResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ref,  LookupOutcome outcome,  List<LookupReason> reasons,  CheckCount? count,  ItemDetails? item)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LookupResult() when $default != null:
return $default(_that.ref,_that.outcome,_that.reasons,_that.count,_that.item);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ref,  LookupOutcome outcome,  List<LookupReason> reasons,  CheckCount? count,  ItemDetails? item)  $default,) {final _that = this;
switch (_that) {
case _LookupResult():
return $default(_that.ref,_that.outcome,_that.reasons,_that.count,_that.item);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ref,  LookupOutcome outcome,  List<LookupReason> reasons,  CheckCount? count,  ItemDetails? item)?  $default,) {final _that = this;
switch (_that) {
case _LookupResult() when $default != null:
return $default(_that.ref,_that.outcome,_that.reasons,_that.count,_that.item);case _:
  return null;

}
}

}

/// @nodoc


class _LookupResult implements LookupResult {
  const _LookupResult({required this.ref, required this.outcome, required final  List<LookupReason> reasons, this.count, this.item}): _reasons = reasons;
  

/// The check's reference number, on every result.
@override final  String ref;
@override final  LookupOutcome outcome;
 final  List<LookupReason> _reasons;
@override List<LookupReason> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

/// Present for `valid` and `warning`.
@override final  CheckCount? count;
@override final  ItemDetails? item;

/// Create a copy of LookupResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LookupResultCopyWith<_LookupResult> get copyWith => __$LookupResultCopyWithImpl<_LookupResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LookupResult&&(identical(other.ref, ref) || other.ref == ref)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&const DeepCollectionEquality().equals(other._reasons, _reasons)&&(identical(other.count, count) || other.count == count)&&(identical(other.item, item) || other.item == item));
}


@override
int get hashCode => Object.hash(runtimeType,ref,outcome,const DeepCollectionEquality().hash(_reasons),count,item);

@override
String toString() {
  return 'LookupResult(ref: $ref, outcome: $outcome, reasons: $reasons, count: $count, item: $item)';
}


}

/// @nodoc
abstract mixin class _$LookupResultCopyWith<$Res> implements $LookupResultCopyWith<$Res> {
  factory _$LookupResultCopyWith(_LookupResult value, $Res Function(_LookupResult) _then) = __$LookupResultCopyWithImpl;
@override @useResult
$Res call({
 String ref, LookupOutcome outcome, List<LookupReason> reasons, CheckCount? count, ItemDetails? item
});


@override $CheckCountCopyWith<$Res>? get count;@override $ItemDetailsCopyWith<$Res>? get item;

}
/// @nodoc
class __$LookupResultCopyWithImpl<$Res>
    implements _$LookupResultCopyWith<$Res> {
  __$LookupResultCopyWithImpl(this._self, this._then);

  final _LookupResult _self;
  final $Res Function(_LookupResult) _then;

/// Create a copy of LookupResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ref = null,Object? outcome = null,Object? reasons = null,Object? count = freezed,Object? item = freezed,}) {
  return _then(_LookupResult(
ref: null == ref ? _self.ref : ref // ignore: cast_nullable_to_non_nullable
as String,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as LookupOutcome,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<LookupReason>,count: freezed == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as CheckCount?,item: freezed == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as ItemDetails?,
  ));
}

/// Create a copy of LookupResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckCountCopyWith<$Res>? get count {
    if (_self.count == null) {
    return null;
  }

  return $CheckCountCopyWith<$Res>(_self.count!, (value) {
    return _then(_self.copyWith(count: value));
  });
}/// Create a copy of LookupResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemDetailsCopyWith<$Res>? get item {
    if (_self.item == null) {
    return null;
  }

  return $ItemDetailsCopyWith<$Res>(_self.item!, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}

// dart format on
