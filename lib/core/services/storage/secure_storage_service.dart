/// Keychain / Keystore storage for the phone ID and the two passes
/// (final.md §5, §12). Never plain storage, never logs.
abstract interface class SecureStorageService {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Keys used in secure storage.
abstract final class SecureKeys {
  static const phoneId = 'phone_id';
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
}
