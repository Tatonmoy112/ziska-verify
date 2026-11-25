import 'dart:math';

import 'package:ziska_verify/core/services/logging/logger_service.dart';
import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/core/utils/secure_random.dart';

/// Makes each official's [ActiveScanStore] with this client's key: the one
/// recipe (production audit P-43).
class ActiveScanStores {
  const ActiveScanStores(
    this._storage, {
    required String client,
    required LoggerService logger,
  }) : _client = client,
       _logger = logger;

  final SecureStorageService _storage;
  final String _client;
  final LoggerService _logger;

  ActiveScanStore of(String official) =>
      ActiveScanStore(_storage, client: _client, official: official);

  /// Forgets [official]'s stored scan. A failure (a locked keychain) is
  /// logged, never thrown: a session left behind is ended by the server.
  Future<void> clear(String official) async {
    try {
      await of(official).clear();
    } on Exception catch (e, stack) {
      _logger.warning(
        'the stored scan session could not be cleared',
        error: e,
        stackTrace: stack,
      );
    }
  }
}

/// Only a UUID is persisted. The key isolates clients and officials.
class ActiveScanStore {
  ActiveScanStore(
    this._storage, {
    required String client,
    required String official,
  }) : _key = 'scan_session:$client:$official';
  final SecureStorageService _storage;
  final String _key;

  Future<String?> read() async {
    final id = await _storage.read(_key);
    if (id == null || _uuid.hasMatch(id)) return id;
    await clear();
    return null;
  }

  static final _uuid = RegExp(
    '^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-4[a-fA-F0-9]{3}-'
    r'[89abAB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$',
  );
  Future<void> save(String id) => _storage.write(_key, id);
  Future<void> clear() => _storage.delete(_key);

  /// A new session ID: a version 4 UUID. [random] only in tests.
  static String newId({Random? random}) {
    final bytes = secureBytes(16, random: random);
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
