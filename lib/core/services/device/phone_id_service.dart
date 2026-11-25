/// The phone ID sent with every login and code (final.md §6).
abstract interface class PhoneIdService {
  /// Returns the stored phone ID, making it on the very first call only.
  Future<String> getOrCreate();
}
