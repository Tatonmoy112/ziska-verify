/// Keychain / Keystore storage for the phone ID, the two passes and a
/// scanner session's ID (final.md §5, §12). Never plain storage, never
/// logs.
abstract interface class SecureStorageService {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// The keys of the phone ID and the passes. A scanner session's key is
/// made per client and official by `ActiveScanStore`.
abstract final class SecureKeys {
  static const phoneId = 'phone_id';
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
}
