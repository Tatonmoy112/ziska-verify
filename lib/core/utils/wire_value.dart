/// An enum value as the API writes it (production audit P-32).
abstract interface class WireValue {
  /// The value exactly as the API sends or receives it.
  String get wire;
}

/// The one of [values] the API writes as [wire], else [unknown]: a value
/// this app does not know, or not written exactly as documented, is never
/// taken for one it does (final.md §13.1).
T fromWireValue<T extends WireValue>(List<T> values, String? wire, T unknown) {
  for (final value in values) {
    if (value != unknown && value.wire == wire) return value;
  }
  return unknown;
}
