import 'package:freezed_annotation/freezed_annotation.dart';

part 'retail_user.freezed.dart';

/// A retail user in the picker (final.md §13.6).
@freezed
abstract class RetailUser with _$RetailUser {
  const factory RetailUser({
    required String id,
    required String name,

    /// Masked by the API (`ra***@gmail.com`) and shown as received.
    required String maskedEmail,
  }) = _RetailUser;
}
