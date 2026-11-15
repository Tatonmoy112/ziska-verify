import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

/// [SecureStorageService] on `flutter_secure_storage`.
class FlutterSecureStorageService implements SecureStorageService {
  FlutterSecureStorageService([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
