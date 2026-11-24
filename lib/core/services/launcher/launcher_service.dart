/// Opens the mail app or the dialler, and nothing else: QR links and other
/// links are never opened (final.md §12).
abstract interface class LauncherService {
  /// Returns `false` when no app can handle it.
  Future<bool> email({
    required String to,
    required String subject,
    required String body,
  });

  /// Returns `false` when no app can handle it.
  Future<bool> call(String phone);
}
