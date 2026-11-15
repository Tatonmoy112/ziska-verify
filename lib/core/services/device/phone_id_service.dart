import 'dart:convert';
import 'dart:math';

import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';

/// The phone ID sent with every login and code (final.md Section 6.1).
abstract interface class PhoneIdService {
  /// Returns the stored phone ID, making it on the very first call only.
  Future<String> getOrCreate();
}

/// Makes the phone ID once: 32 bytes from a secure random source, base64url
/// without padding (43 characters of `A–Z a–z 0–9 _ -`). Never made again on
/// logout, update, or error: a new phone ID is a new phone.
class SecurePhoneIdService implements PhoneIdService {
  SecurePhoneIdService(this._storage, {Random? random})
    : _random = random ?? Random.secure();

  final SecureStorageService _storage;
  final Random _random;
  Future<String>? _pending;

  @override
  Future<String> getOrCreate() => _pending ??= _load();

  Future<String> _load() async {
    final stored = await _storage.read(SecureKeys.phoneId);
    if (stored != null && stored.isNotEmpty) return stored;
    final id = generate(_random);
    await _storage.write(SecureKeys.phoneId, id);
    return id;
  }

  /// 32 random bytes, base64url, no `=` padding.
  static String generate(Random random) {
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
