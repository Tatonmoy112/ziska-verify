import 'dart:math';

/// [length] random bytes from [random], or from the platform's secure
/// generator: the app's one source of IDs (production audit P-42). Tests
/// pass a seeded [random].
List<int> secureBytes(int length, {Random? random}) {
  final source = random ?? Random.secure();
  return List<int>.generate(length, (_) => source.nextInt(256));
}
