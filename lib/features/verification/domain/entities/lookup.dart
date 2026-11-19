/// The ways to look an item up: serial or QR (final.md Section 13.1;
/// backend D62: never the hidden code).
enum LookupWay {
  serial('serial'),
  qr('qr')
  ;

  const LookupWay(this.wire);

  /// The value sent as `way`.
  final String wire;
}

/// `data.result` (final.md Section 13.1.4). [unknown] is any value this app
/// does not know yet: it is never shown as valid (Section 13.1.5).
enum LookupOutcome { valid, warning, notFound, unassigned, unknown }

/// `data.reasons` entries. [unknown] is shown as a generic "Needs attention".
enum LookupReason {
  checkedBefore,
  recalled,
  expired,
  damaged,
  switchedOff,
  unknown,
}

/// One input format of the client (`GET formats`, final.md Section 13.1.3).
class CodeFormat {
  const CodeFormat({required this.length, required this.characters});

  final int length;
  final String characters;
}

class InputFormats {
  const InputFormats({
    required this.serialMaxDigits,
    required this.qr,
  });

  final int serialMaxDigits;
  final CodeFormat qr;
}

class Product {
  const Product({
    required this.name,
    this.genericName,
    this.shortName,
    this.pictureUrl,
  });

  final String name;
  final String? genericName;
  final String? shortName;
  final String? pictureUrl;
}

class Batch {
  const Batch({required this.number, this.made, this.expires});

  final String number;

  /// `YYYY-MM-DD` dates, either can be `null`.
  final DateTime? made;
  final DateTime? expires;
}

class ItemDetails {
  const ItemDetails({
    required this.serial,
    required this.maskedCode,
    required this.product,
    required this.batch,
  });

  final String serial;

  /// The hidden code as the API sends it (`*****7K2`), shown as received.
  final String maskedCode;
  final Product product;
  final Batch batch;
}

class CheckCount {
  const CheckCount({required this.thisCheck, this.lastAt});

  /// This check's number for the item (1 for a first check).
  final int thisCheck;

  /// The check before, `null` on a first check.
  final DateTime? lastAt;
}

/// A lookup's answer (`POST lookups`).
class LookupResult {
  const LookupResult({
    required this.ref,
    required this.outcome,
    required this.reasons,
    this.count,
    this.item,
  });

  /// The check's reference number, on every result.
  final String ref;
  final LookupOutcome outcome;
  final List<LookupReason> reasons;

  /// Present for `valid` and `warning`.
  final CheckCount? count;
  final ItemDetails? item;
}
