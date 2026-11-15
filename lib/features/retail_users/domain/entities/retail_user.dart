/// A retail user in the picker (final.md Section 13.6).
class RetailUser {
  const RetailUser({
    required this.id,
    required this.name,
    required this.maskedEmail,
  });

  final String id;
  final String name;

  /// Masked by the API (`ra***@gmail.com`) and shown as received.
  final String maskedEmail;
}
