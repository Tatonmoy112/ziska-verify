import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';

class _Repo extends Mock implements VerificationRepository {}

const _stack = SerialStackResult(
  session: SessionTotals(
    id: 'S-1',
    scanned: 1,
    valid: 1,
    warning: 0,
    notFound: 0,
    unassigned: 0,
  ),
  items: [],
);

List<String> _serials(int n) => [for (var i = 1; i <= n; i++) '${1000000 + i}'];

/// TC-MIG-080 … -082 (docs/test-cases/16-mobile-migration.md): the serial
/// stack's rule, 1 to 50 items each counted once, is the use case's, in one
/// place (guide §4.7; production audit P-29).
void main() {
  setUpAll(() => registerFallbackValue(<String>[]));

  late _Repo repo;
  late List<List<String>> sent;
  setUp(() {
    repo = _Repo();
    sent = [];
    when(() => repo.serials(any())).thenAnswer((inv) async {
      sent.add(inv.positionalArguments.single as List<String>);
      return const Success(_stack);
    });
  });

  group('TC-MIG-080 normal: 1 to 50 serials are sent as typed', () {
    for (final n in [1, 50]) {
      test('$n', () async {
        final serials = _serials(n);
        expect(CheckSerials.refusal(serials), isNull);
        await CheckSerials(repo)(serials);
        expect(sent.single, serials, reason: 'the order typed');
      });
    }
  });

  group('TC-MIG-081 edge: each item counted once', () {
    test('repeats by the serial key are sent once, the first kept', () async {
      await CheckSerials(repo)(['0001', '1', '1000002', '0001']);
      expect(sent.single, ['0001', '1000002']);
    });

    test('51 typed with a repeat are 50 items: sent', () async {
      final serials = [..._serials(50), '1000001'];
      expect(CheckSerials.refusal(serials), isNull);
      await CheckSerials(repo)(serials);
      expect(sent.single, hasLength(50));
    });
  });

  group('TC-MIG-082 worst: a stack that does not fit is never sent', () {
    for (final (label, serials) in [
      ('none', <String>[]),
      ('51', _serials(51)),
      ('zeros that are one item, then 50 more', ['0', '00', ..._serials(50)]),
    ]) {
      test(label, () async {
        final result = await CheckSerials(repo)(serials);
        final e = (result as Err).failure.exception;
        expect(e, isA<ValidationException>());
        expect(e.reason, VerificationReason.serialStackSize);
        expect(
          CheckSerials.refusal(serials)?.reason,
          VerificationReason.serialStackSize,
        );
        verifyNever(() => repo.serials(any()));
      });
    }

    test('the limit is read in one place', () {
      final found = <String>[];
      for (final file in Directory('lib').listSync(recursive: true)) {
        final path = file.path.replaceAll(r'\', '/');
        if (file is! File ||
            !path.endsWith('.dart') ||
            path.contains('/l10n/') ||
            path.endsWith('domain/entities/serial_stack.dart') ||
            path.endsWith('domain/usecases/verification_usecases.dart')) {
          continue;
        }
        // The screen's text of the same name is a translation, not the rule.
        final rule = RegExp(r'(?<![.\w])serialStackLimit\b');
        final code = file
            .readAsLinesSync()
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        if (rule.hasMatch(code)) found.add(path);
      }
      expect(found, isEmpty);
    });
  });
}
