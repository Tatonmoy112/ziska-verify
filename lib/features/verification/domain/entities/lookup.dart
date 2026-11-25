import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/utils/wire_value.dart';

part 'lookup.freezed.dart';

/// The ways to look an item up: serial or QR (final.md §13.1;
/// backend D62: never the hidden code).
enum LookupWay {
  serial('serial'),
  qr('qr')
  ;

  const LookupWay(this.wire);

  /// The value sent as `way`.
  final String wire;
}

/// `data.result` (final.md §13.1). [unknown] is any value this app
/// does not know yet: it is never shown as valid (§13.1).
enum LookupOutcome implements WireValue {
  valid('valid'),
  warning('warning'),
  notFound('not_found'),
  unassigned('unassigned'),
  unknown('')
  ;

  const LookupOutcome(this.wire);
  @override
  final String wire;

  static LookupOutcome fromWire(String? wire) =>
      fromWireValue(values, wire, unknown);
}

/// `data.reasons` entries. [unknown] is shown as a generic "Needs attention".
enum LookupReason implements WireValue {
  checkedBefore('checked_before'),
  recalled('recalled'),
  expired('expired'),
  damaged('damaged'),
  switchedOff('switched_off'),
  unknown('')
  ;

  const LookupReason(this.wire);
  @override
  final String wire;

  static LookupReason fromWire(String? wire) =>
      fromWireValue(values, wire, unknown);
}

/// One input format of the client (`GET formats`, final.md §13.1).
@freezed
abstract class CodeFormat with _$CodeFormat {
  const factory CodeFormat({required int length, required String characters}) =
      _CodeFormat;
}

@freezed
abstract class InputFormats with _$InputFormats {
  const factory InputFormats({
    required int serialMaxDigits,
    required CodeFormat qr,
  }) = _InputFormats;
}

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String name,
    String? genericName,
    String? shortName,
    String? pictureUrl,
  }) = _Product;
}

@freezed
abstract class Batch with _$Batch {
  const factory Batch({
    required String number,

    /// `YYYY-MM-DD` dates, either can be `null`.
    DateTime? made,
    DateTime? expires,
  }) = _Batch;
}

@freezed
abstract class ItemDetails with _$ItemDetails {
  const factory ItemDetails({
    required String serial,

    /// The hidden code as the API sends it (`*****7K2`), shown as received.
    required String maskedCode,
    required Product product,
    required Batch batch,
  }) = _ItemDetails;
}

@freezed
abstract class CheckCount with _$CheckCount {
  const factory CheckCount({
    /// This check's number for the item (1 for a first check).
    required int thisCheck,

    /// The check before, `null` on a first check.
    DateTime? lastAt,
  }) = _CheckCount;
}

/// A lookup's answer (`POST lookups`).
@freezed
abstract class LookupResult with _$LookupResult {
  const factory LookupResult({
    /// The check's reference number, on every result.
    required String ref,
    required LookupOutcome outcome,
    required List<LookupReason> reasons,

    /// Present for `valid` and `warning`.
    CheckCount? count,
    ItemDetails? item,
  }) = _LookupResult;
}
