/// Whether two serials name the same item: the backend compares serials as
/// numbers, so leading zeros do not count (`001` is `1`; seen on the test
/// server 2026-11-22, backend question B5). The first one typed is the one
/// sent, and the server answers its row with that serial.
bool sameSerial(String a, String b) => _serialKey(a) == _serialKey(b);

/// [serials] without the ones that name the same item as an earlier one,
/// in the order typed.
List<String> distinctSerials(Iterable<String> serials) {
  final keys = <String>{};
  return [
    for (final serial in serials)
      if (keys.add(_serialKey(serial))) serial,
  ];
}

String _serialKey(String serial) {
  final key = serial.replaceFirst(RegExp('^0+'), '');
  return key.isEmpty && serial.isNotEmpty ? '0' : key;
}
