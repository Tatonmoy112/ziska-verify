import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

/// In-memory [SecureStorageService] for tests.
class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
