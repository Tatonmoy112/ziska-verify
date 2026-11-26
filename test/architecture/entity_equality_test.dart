import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/authentication/domain/entities/access_request.dart';
import 'package:ziska_verify/features/authentication/domain/entities/login_outcome.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';
import 'package:ziska_verify/features/history/domain/usecases/check_usecases.dart';
import 'package:ziska_verify/features/history/presentation/bloc/history_bloc.dart';
import 'package:ziska_verify/features/incidents/domain/entities/report.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/prepared_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';

class _History extends Mock implements HistoryRepository {}

/// [value] at run time: an entity made with it is a new object, not a
/// shared constant.
T _v<T>(T value) => value;

/// TC-ARCH-071 … -073 (docs/test-cases/18-architecture.md): entities are
/// equal by value, with lists that cannot be changed (production audit
/// P-44).
void main() {
  setUpAll(() {
    registerFallbackValue(const CheckQuery());
    registerFallbackValue(const PageRequest());
  });

  final at = DateTime.utc(2026, 11, 25, 9);
  CheckRecord check({List<CheckReason> reasons = const []}) => CheckRecord(
    ref: 'CHK-1',
    at: at,
    way: CheckWay.qr,
    result: CheckResult.warning,
    reasons: [...reasons],
    official: 'Rahim',
    serial: '123',
  );
  LookupResult lookup({List<LookupReason> reasons = const []}) => LookupResult(
    ref: 'CHK-2',
    outcome: LookupOutcome.valid,
    reasons: [...reasons],
    count: CheckCount(thisCheck: 2, lastAt: at),
    item: ItemDetails(
      serial: '123',
      maskedCode: '*****abc',
      product: const Product(name: 'Napa', shortName: 'N'),
      batch: Batch(number: 'B-1', made: DateTime(2025, 9, 18)),
    ),
  );
  const totals = SessionTotals(
    id: 's-1',
    scanned: 3,
    valid: 1,
    warning: 1,
    notFound: 1,
    unassigned: 0,
  );

  /// Each entity, made twice from the same values.
  final makers = <String, Object Function()>{
    'CursorPage': () => CursorPage(items: [check()], nextCursor: 'c'),
    'RequestableRole': () => RequestableRole(id: _v(1), name: 'Seller'),
    'AccessRequest': () => AccessRequest(
      email: _v('a@example.com'),
      code: '123456',
      name: 'A',
      roleId: 1,
      password: 'x',
    ),
    'LoggedIn': () => LoggedIn(mustChangePassword: _v(true)),
    'CodeSent': () => CodeSent(_v('challenge')),
    'CheckRecord': () => check(reasons: [CheckReason.checkedBefore]),
    'CheckTotals': () => CheckTotals(
      total: _v(3),
      valid: 1,
      warning: 1,
      notFound: 1,
      unassigned: 0,
    ),
    'CheckPage': () => CheckPage(page: CursorPage(items: [check()])),
    'Report': () => Report(id: 1, at: at, note: 'n', photos: 2, checkRef: 'r'),
    'RetailUser': () =>
        RetailUser(id: _v('u'), name: 'Shop', maskedEmail: 'ra***@x.com'),
    'CheckedInput': () =>
        CheckedInput(way: LookupWay.serial, shown: '0012', at: at),
    'InputFormats': () => InputFormats(
      serialMaxDigits: _v(20),
      qr: const CodeFormat(length: 12, characters: 'A-Z'),
    ),
    'LookupResult': () => lookup(reasons: [LookupReason.checkedBefore]),
    'ReadyInput': () => ReadyInput(_v(LookupWay.qr), 'abc'),
    'RefusedInput': () =>
        RefusedInput(_v(LookupWay.serial), InputProblem.empty),
    // Not the shared const: a new value each time.
    'SessionTotals': () => SessionTotals(
      id: totals.id,
      scanned: 3,
      valid: 1,
      warning: 1,
      notFound: 1,
      unassigned: 0,
    ),
    'ScanResult': () =>
        ScanResult(result: lookup(), repeat: false, session: totals),
    'ScanSessionSummary': () => ScanSessionSummary(
      totals: totals,
      kind: SessionKind.qr,
      status: ScanStatus.open,
      startedAt: at,
      lastScanAt: at,
    ),
    'RecoveredScan': () => RecoveredScan(
      ref: _v('r'),
      outcome: LookupOutcome.valid,
      serial: '1',
    ),
    'SerialStackRow': () => SerialStackRow(serial: '1', result: lookup()),
    'SerialStackResult': () => SerialStackResult(
      session: totals,
      items: [SerialStackRow(serial: '1', result: lookup())],
    ),
    'ParsedStack': () => ParsedStack(serials: _v(['1', '2']), typed: 3),
  };

  group('TC-ARCH-071 normal: equal by value', () {
    for (final MapEntry(key: name, value: make) in makers.entries) {
      test(name, () {
        final a = make();
        final b = make();
        expect(identical(a, b), isFalse);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });
    }

    test('a field changed is another value', () {
      expect(check(), isNot(check(reasons: [CheckReason.checkedBefore])));
      expect(
        const LoggedIn(mustChangePassword: true),
        isNot(const LoggedIn(mustChangePassword: false)),
      );
      expect(const CodeSent('a'), isNot(const CodeSent('b')));
    });
  });

  group('TC-ARCH-072 edge: lists by value, and fixed', () {
    test('equal lists are equal; another order is not', () {
      expect(
        lookup(reasons: [LookupReason.checkedBefore, LookupReason.expired]),
        isNot(
          lookup(reasons: [LookupReason.expired, LookupReason.checkedBefore]),
        ),
      );
      expect(
        CursorPage(items: [1, 2].toList()),
        CursorPage(items: [1, 2].toList()),
      );
    });

    test('an entity list cannot be changed', () {
      expect(
        () => check().reasons.add(CheckReason.expired),
        throwsUnsupportedError,
      );
      expect(
        () => lookup().reasons.add(LookupReason.expired),
        throwsUnsupportedError,
      );
      // Lists made at run time, as a mapper makes them (a const list is
      // fixed anyway).
      final ints = [1];
      final rows = <SerialStackRow>[];
      final serials = ['1'];
      expect(
        () => CursorPage(items: ints).items.add(2),
        throwsUnsupportedError,
      );
      expect(
        () => SerialStackResult(session: totals, items: rows).items.clear(),
        throwsUnsupportedError,
      );
      expect(
        () => ParsedStack(serials: serials, typed: 1).serials.add('2'),
        throwsUnsupportedError,
      );
    });

    test('what the entities work out stays', () {
      expect(const CursorPage(items: <int>[], nextCursor: 'c').hasMore, isTrue);
      expect(const ParsedStack(serials: ['1'], typed: 3).repeats, 2);
      expect(AccessRequest.nameMaxLength, 100);
    });
  });

  group('TC-ARCH-073 worst: an equal reload, and no entity left plain', () {
    test('a refresh that brings equal checks still ends', () async {
      final repo = _History();
      when(() => repo.getChecks(any(), any())).thenAnswer(
        // A new, equal page each time, as a reload brings.
        (_) async => Success(CheckPage(page: CursorPage(items: [check()]))),
      );
      final bloc = HistoryBloc(GetChecks(repo))..add(const HistoryRefreshed());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final before = bloc.state;

      final done = Completer<void>();
      bloc.add(HistoryRefreshed(done: done));
      await done.future.timeout(const Duration(seconds: 2));
      expect(bloc.state, before);
      verify(() => repo.getChecks(any(), any())).called(2);
      await bloc.close();
    });

    test('no value prints a secret (AGENTS.md; final.md §12)', () {
      const request = AccessRequest(
        email: 'someone@example.com',
        code: '483920',
        name: 'Karim',
        roleId: 2,
        password: 'Not-a-real-1',
      );
      for (final text in [
        '$request',
        '${const CodeSent('challenge-7f3a')}',
        '${const LoggedIn(mustChangePassword: true)}',
      ]) {
        for (final secret in [
          '483920',
          'Not-a-real-1',
          'challenge-7f3a',
          'someone@example.com',
        ]) {
          expect(text, isNot(contains(secret)), reason: text);
        }
      }
      expect('$request', contains('roleId: 2'));

      // No generated `toString` in `lib/` prints a password, a pass, a
      // login code or its challenge.
      final printed = RegExp(
        r"return '[^']*\b(password|oldPassword|newPassword|token|"
        r'accessToken|refreshToken|challengeId|code|phoneId): \$',
      );
      final leaks = [
        for (final f in Directory('lib').listSync(recursive: true))
          if (f is File && f.path.endsWith('.freezed.dart'))
            for (final line in f.readAsLinesSync())
              if (printed.hasMatch(line)) '${f.path}: ${line.trim()}',
      ];
      expect(leaks, isEmpty);
    });

    test('every entity class is Freezed', () {
      final files = [
        File('lib/core/pagination/cursor_page.dart'),
        ...Directory('lib/features')
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.replaceAll(r'\', '/').contains('/domain/entities/') &&
                  f.path.endsWith('.dart') &&
                  !f.path.endsWith('.freezed.dart') &&
                  !f.path.endsWith('.g.dart'),
            ),
      ];
      final plain = <String>[];
      final declaration = RegExp(
        r'^(?:abstract |sealed |final )*class (\w+)',
        multiLine: true,
      );
      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (final (i, line) in lines.indexed) {
          final m = declaration.firstMatch(line);
          // Rules with only static members are not values.
          if (m == null || line.startsWith('abstract final class')) continue;
          if (i == 0 || lines[i - 1].trim() != '@freezed') {
            plain.add('${file.path}: ${m.group(1)}');
          }
        }
      }
      expect(plain, isEmpty);
    });
  });
}
