import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/utils/wire_value.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

/// Every enum the API sends, with the values its guide documents, and how
/// to read one (production audit P-32).
final _enums =
    <
      String,
      ({
        List<WireValue> values,
        WireValue Function(String?) read,
        WireValue unknown,
        Set<String> documented,
      })
    >{
      // A check's result, and a lookup's (guide §4.1, §5).
      'CheckResult': (
        values: CheckResult.values,
        read: CheckResult.fromWire,
        unknown: CheckResult.unknown,
        documented: {'valid', 'warning', 'not_found', 'unassigned'},
      ),
      'LookupOutcome': (
        values: LookupOutcome.values,
        read: LookupOutcome.fromWire,
        unknown: LookupOutcome.unknown,
        documented: {'valid', 'warning', 'not_found', 'unassigned'},
      ),
      // A warning's reasons (guide §4.1, §5).
      'CheckReason': (
        values: CheckReason.values,
        read: CheckReason.fromWire,
        unknown: CheckReason.unknown,
        documented: {
          'checked_before',
          'recalled',
          'expired',
          'damaged',
          'switched_off',
        },
      ),
      'LookupReason': (
        values: LookupReason.values,
        read: LookupReason.fromWire,
        unknown: LookupReason.unknown,
        documented: {
          'checked_before',
          'recalled',
          'expired',
          'damaged',
          'switched_off',
        },
      ),
      // How a check was made (guide §5).
      'CheckWay': (
        values: CheckWay.values,
        read: CheckWay.fromWire,
        unknown: CheckWay.unknown,
        documented: {'serial', 'qr', 'hidden_code'},
      ),
      // A session's kind and status (guide §4.5).
      'SessionKind': (
        values: SessionKind.values,
        read: SessionKind.fromWire,
        unknown: SessionKind.unknown,
        documented: {'qr', 'serial'},
      ),
      'ScanStatus': (
        values: ScanStatus.values,
        read: ScanStatus.fromWire,
        unknown: ScanStatus.unknown,
        documented: {'open', 'ended'},
      ),
    };

/// TC-ARCH-041 … -043 (docs/test-cases/18-architecture.md): one pattern
/// for every value the API sends: `wire`, and `fromWire` falling back to
/// `unknown` (production audit P-32).
void main() {
  group('TC-ARCH-041 normal: the documented values, both ways', () {
    for (final MapEntry(key: name, value: e) in _enums.entries) {
      test(name, () {
        final known = e.values.where((v) => v != e.unknown);
        expect(known.map((v) => v.wire).toSet(), e.documented);
        for (final v in known) {
          expect(e.read(v.wire), same(v), reason: v.wire);
        }
      });
    }
  });

  group('TC-ARCH-042 edge: a value not written exactly as documented', () {
    for (final MapEntry(key: name, value: e) in _enums.entries) {
      test(name, () {
        final some = e.documented.first;
        for (final other in [some.toUpperCase(), ' $some', '$some ', null]) {
          expect(e.read(other), same(e.unknown), reason: '"$other"');
        }
      });
    }
  });

  group('TC-ARCH-043 worst: never a known value by mistake', () {
    for (final MapEntry(key: name, value: e) in _enums.entries) {
      test('$name: an empty or new value is unknown', () {
        for (final other in ['', 'unknown', 'stolen', 'valid_soon']) {
          expect(e.read(other), same(e.unknown), reason: '"$other"');
        }
      });
    }

    test('no mapper, service or screen reads an API string by itself', () {
      // A switch on an API string anywhere; and, where requests are built,
      // an enum's Dart name sent as its value (`.wire` is the API's).
      final switched = RegExp(r"^\s*'[a-z_]+' =>", multiLine: true);
      final sentByName = RegExp(r'\?\.name,');
      final found = <String>[];
      for (final file in Directory('lib/features').listSync(recursive: true)) {
        final path = file.path.replaceAll(r'\', '/');
        if (file is! File ||
            !path.endsWith('.dart') ||
            path.endsWith('.g.dart') ||
            path.endsWith('.freezed.dart') ||
            !(path.contains('/data/') || path.contains('/presentation/'))) {
          continue;
        }
        final source = file.readAsStringSync();
        if (switched.hasMatch(source) ||
            (path.contains('/data/services/') && sentByName.hasMatch(source))) {
          found.add(path);
        }
      }
      expect(found, isEmpty);
    });
  });
}
