// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_outcome.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginOutcome {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginOutcome);
}


@override
int get hashCode => runtimeType.hashCode;



}

/// @nodoc
class $LoginOutcomeCopyWith<$Res>  {
$LoginOutcomeCopyWith(LoginOutcome _, $Res Function(LoginOutcome) __);
}


/// Adds pattern-matching-related methods to [LoginOutcome].
extension LoginOutcomePatterns on LoginOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoggedIn value)?  loggedIn,TResult Function( CodeSent value)?  codeSent,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoggedIn() when loggedIn != null:
return loggedIn(_that);case CodeSent() when codeSent != null:
return codeSent(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoggedIn value)  loggedIn,required TResult Function( CodeSent value)  codeSent,}){
final _that = this;
switch (_that) {
case LoggedIn():
return loggedIn(_that);case CodeSent():
return codeSent(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoggedIn value)?  loggedIn,TResult? Function( CodeSent value)?  codeSent,}){
final _that = this;
switch (_that) {
case LoggedIn() when loggedIn != null:
return loggedIn(_that);case CodeSent() when codeSent != null:
return codeSent(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bool mustChangePassword)?  loggedIn,TResult Function( String challengeId)?  codeSent,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoggedIn() when loggedIn != null:
return loggedIn(_that.mustChangePassword);case CodeSent() when codeSent != null:
return codeSent(_that.challengeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bool mustChangePassword)  loggedIn,required TResult Function( String challengeId)  codeSent,}) {final _that = this;
switch (_that) {
case LoggedIn():
return loggedIn(_that.mustChangePassword);case CodeSent():
return codeSent(_that.challengeId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bool mustChangePassword)?  loggedIn,TResult? Function( String challengeId)?  codeSent,}) {final _that = this;
switch (_that) {
case LoggedIn() when loggedIn != null:
return loggedIn(_that.mustChangePassword);case CodeSent() when codeSent != null:
return codeSent(_that.challengeId);case _:
  return null;

}
}

}

/// @nodoc


class LoggedIn extends LoginOutcome {
  const LoggedIn({required this.mustChangePassword}): super._();
  

 final  bool mustChangePassword;

/// Create a copy of LoginOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoggedInCopyWith<LoggedIn> get copyWith => _$LoggedInCopyWithImpl<LoggedIn>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoggedIn&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword));
}


@override
int get hashCode => Object.hash(runtimeType,mustChangePassword);



}

/// @nodoc
abstract mixin class $LoggedInCopyWith<$Res> implements $LoginOutcomeCopyWith<$Res> {
  factory $LoggedInCopyWith(LoggedIn value, $Res Function(LoggedIn) _then) = _$LoggedInCopyWithImpl;
@useResult
$Res call({
 bool mustChangePassword
});




}
/// @nodoc
class _$LoggedInCopyWithImpl<$Res>
    implements $LoggedInCopyWith<$Res> {
  _$LoggedInCopyWithImpl(this._self, this._then);

  final LoggedIn _self;
  final $Res Function(LoggedIn) _then;

/// Create a copy of LoginOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mustChangePassword = null,}) {
  return _then(LoggedIn(
mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class CodeSent extends LoginOutcome {
  const CodeSent(this.challengeId): super._();
  

 final  String challengeId;

/// Create a copy of LoginOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CodeSentCopyWith<CodeSent> get copyWith => _$CodeSentCopyWithImpl<CodeSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CodeSent&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId));
}


@override
int get hashCode => Object.hash(runtimeType,challengeId);



}

/// @nodoc
abstract mixin class $CodeSentCopyWith<$Res> implements $LoginOutcomeCopyWith<$Res> {
  factory $CodeSentCopyWith(CodeSent value, $Res Function(CodeSent) _then) = _$CodeSentCopyWithImpl;
@useResult
$Res call({
 String challengeId
});




}
/// @nodoc
class _$CodeSentCopyWithImpl<$Res>
    implements $CodeSentCopyWith<$Res> {
  _$CodeSentCopyWithImpl(this._self, this._then);

  final CodeSent _self;
  final $Res Function(CodeSent) _then;

/// Create a copy of LoginOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? challengeId = null,}) {
  return _then(CodeSent(
null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
