/// Takes the QR value from a scanned QR link (final.md Section 13.1.2).
///
/// The QR holds the client's verification site address, then `/q/`, then
/// the value, for example `https://www.ziskaverify.com/q/Q8F2KD91XA7M`. Any
/// host is accepted; the link is never opened (Section 12.1).
class QrLinkParser {
  const QrLinkParser();

  static const _marker = '/q/';

  /// Returns the part after the last `/q/`, or `null` when the scanned text
  /// is not a product QR link.
  String? parse(String scanned) {
    final text = scanned.trim();
    final at = text.lastIndexOf(_marker);
    if (at < 0) return null;
    var value = text.substring(at + _marker.length);
    // A query, fragment, or trailing slash is not part of the value.
    final end = value.indexOf(RegExp('[?#/]'));
    if (end >= 0) value = value.substring(0, end);
    return value.isEmpty ? null : value;
  }
}
