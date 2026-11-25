import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/services/device/secure_phone_id_service.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

import '../../../fakes/fake_secure_storage_service.dart';

void main() {
  group('SecurePhoneIdService', () {
    test('makes a 43-character base64url ID', () async {
      final service = SecurePhoneIdService(FakeSecureStorageService());
      final id = await service.getOrCreate();
      expect(id, hasLength(43));
      expect(RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(id), isTrue);
    });

    test('TC-SESS-025 a storage that cannot be read never gets a new '
        'phone ID', () async {
      final storage = _UnreadableStorage();
      await expectLater(
        SecurePhoneIdService(storage).getOrCreate(),
        throwsA(isA<StateError>()),
      );
      expect(storage.writes, isEmpty);
    });

    test('makes it once and stores it', () async {
      final storage = FakeSecureStorageService();
      final first = await SecurePhoneIdService(storage).getOrCreate();
      // A new service instance stands in for an app restart.
      final second = await SecurePhoneIdService(storage).getOrCreate();
      expect(second, first);
      expect(storage.values[SecureKeys.phoneId], first);
    });

    test('concurrent first calls share one ID', () async {
      final storage = FakeSecureStorageService();
      final service = SecurePhoneIdService(storage);
      final ids = await Future.wait([
        service.getOrCreate(),
        service.getOrCreate(),
      ]);
      expect(ids.toSet(), hasLength(1));
    });
  });
}

/// Secure storage that fails every read, as a broken Keystore would.
class _UnreadableStorage implements SecureStorageService {
  final writes = <String>[];

  @override
  Future<String?> read(String key) async => throw StateError('unreadable');

  @override
  Future<void> write(String key, String value) async => writes.add(key);

  @override
  Future<void> delete(String key) async {}
}
