import 'dart:convert';
import 'dart:math';

import 'package:ziska_verify/core/services/storage/secure_storage_service.dart';
import 'package:ziska_verify/core/utils/secure_random.dart';

/// The phone ID sent with every login and code (final.md §6).
abstract interface class PhoneIdService {
  /// Returns the stored phone ID, making it on the very first call only.
  Future<String> getOrCreate();
}

/// Makes the phone ID once: 32 bytes from a secure random source, base64url
/// without padding (43 characters of `A–Z a–z 0–9 _ -`). Never made again on
/// logout, update, or error: a new phone ID is a new phone.
class SecurePhoneIdService implements PhoneIdService {
  /// [random] only in tests: the secure generator otherwise.
  SecurePhoneIdService(this._storage, {Random? random}) : _random = random;

  final SecureStorageService _storage;
  final Random? _random;
  Future<String>? _pending;

  @override
  Future<String> getOrCreate() {
    final pending = _pending ??= _load();
    // A failure (unreadable storage) is not kept: the next call tries again.
    return pending.catchError((Object e, StackTrace s) {
      if (identical(_pending, pending)) _pending = null;
      Error.throwWithStackTrace(e, s);
    });
  }

  Future<String> _load() async {
    final stored = await _storage.read(SecureKeys.phoneId);
    if (stored != null && stored.isNotEmpty) return stored;
    final id = generate(_random);
    await _storage.write(SecureKeys.phoneId, id);
    return id;
  }

  /// 32 random bytes, base64url, no `=` padding.
  static String generate([Random? random]) =>
      base64Url.encode(secureBytes(32, random: random)).replaceAll('=', '');
}
