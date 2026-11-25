import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/network/api_dates.dart';
import 'package:ziska_verify/core/services/device/secure_phone_id_service.dart';
import 'package:ziska_verify/core/services/scanner/active_scan_store.dart';
import 'package:ziska_verify/core/utils/secure_random.dart';
import 'package:ziska_verify/core/utils/waits_until.dart';
import 'package:ziska_verify/features/verification/data/mappers/verification_mappers.dart';
import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';

import 'layer_rules.dart';

/// TC-ARCH-065 … -067 (docs/test-cases/18-architecture.md): the small
/// duplicates, each written once (production audit P-42): the API's days
/// and times, the 429 wait, secure random, and a sessions query's copies.
void main() {
  final now = DateTime.utc(2026, 11, 25, 10);

  /// A lookup answer as the backend writes it, with [count] and [batch].
  LookupResult lookup({Object? lastAt, Map<String, Object?>? batch}) =>
      LookupResultDto.fromJson({
        'ref': 'CHK-1',
        'result': 'valid',
        'count': {'this_check': 2, 'last_at': lastAt},
        'item': {
          'serial': '123',
          'code': '*****abc',
          'product': {'name': 'Napa'},
          'batch': batch ?? {'number': 'B-1', 'made': null, 'expires': null},
        },
      }).toEntity();

  group('TC-ARCH-065 normal: one way each', () {
    test('a day for a query, and the days and times of an answer', () {
      expect(ApiDates.dayText(DateTime(2026, 11, 5)), '2026-11-05');
      // As the test server writes them: five or six fraction digits.
      expect(
        ApiDates.instant('2026-11-22T06:30:49.67778+00:00'),
        DateTime.utc(2026, 11, 22, 6, 30, 49, 677, 780),
      );
      expect(ApiDates.instant('2026-10-12T09:14:00Z').isUtc, isTrue);
      expect(ApiDates.day('2025-09-18'), DateTime(2025, 9, 18));
    });

    test('a lookup reads its last check and its batch days', () {
      final result = lookup(
        lastAt: '2026-11-22T09:40:44.957958+00:00',
        batch: {'number': 'B-1', 'made': '2025-09-18', 'expires': '2027-09-18'},
      );
      expect(
        result.count!.lastAt,
        DateTime.utc(2026, 11, 22, 9, 40, 44, 957, 958),
      );
      expect(result.item!.batch.made, DateTime(2025, 9, 18));
      expect(result.item!.batch.expires, DateTime(2027, 9, 18));
    });

    test('a wait is running until its time', () {
      withClock(Clock.fixed(now), () {
        expect(waitsUntil(now.add(const Duration(seconds: 30))), isTrue);
        expect(waitsUntil(null), isFalse);
      });
      // A bloc's own clock, when it takes one.
      expect(
        waitsUntil(now, now: now.subtract(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('IDs from one secure source, seeded in tests', () {
      expect(secureBytes(16), hasLength(16));
      expect(
        secureBytes(16, random: Random(7)),
        secureBytes(16, random: Random(7)),
      );
      final id = ActiveScanStore.newId(random: Random(7));
      expect(id, ActiveScanStore.newId(random: Random(7)));
      expect(
        id,
        matches(
          RegExp(
            '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-'
            r'[0-9a-f]{12}$',
          ),
        ),
      );
      expect(ActiveScanStore.newId(), isNot(ActiveScanStore.newId()));
      expect(SecurePhoneIdService.generate(Random(7)), hasLength(43));
    });

    test('a sessions query is copied, and equal by value', () {
      final query = SessionQuery(
        status: ScanStatus.open,
        from: DateTime(2026, 11),
        to: DateTime(2026, 11, 5),
      );
      expect(query.copyWith(status: ScanStatus.ended).from, query.from);
      expect(
        query.copyWith(from: null, to: null),
        const SessionQuery(status: ScanStatus.open),
      );
      expect(query, query.copyWith());
    });
  });

  group('TC-ARCH-066 edge: at the limits', () {
    test('a day before year 1000, and a time of day dropped', () {
      expect(ApiDates.dayText(DateTime(999, 1, 2)), '0999-01-02');
      expect(ApiDates.dayText(DateTime(2026, 12, 31, 23, 59)), '2026-12-31');
      expect(ApiDates.day('2024-02-29'), DateTime(2024, 2, 29));
    });

    test('a time in another offset, without a fraction, to nanoseconds', () {
      expect(
        ApiDates.instant('2026-11-22T12:30:00+06:00'),
        DateTime.utc(2026, 11, 22, 6, 30),
      );
      expect(
        ApiDates.instant('2026-11-22T06:30:00.123456789Z'),
        DateTime.utc(2026, 11, 22, 6, 30, 0, 123, 456),
      );
    });

    test('a first check has no last check; no batch days', () {
      final result = lookup();
      expect(result.count!.lastAt, isNull);
      expect(result.item!.batch.made, isNull);
    });

    test('a wait ends exactly at its time', () {
      withClock(Clock.fixed(now), () {
        expect(waitsUntil(now), isFalse);
        expect(waitsUntil(now.subtract(const Duration(seconds: 1))), isFalse);
      });
    });
  });

  group('TC-ARCH-067 worst: never read wrong, never written twice', () {
    test('a time without its offset, or not a time', () {
      for (final bad in ['2026-11-22T06:30:49', '2026-11-22', 'soon', '']) {
        expect(() => ApiDates.instant(bad), throwsFormatException, reason: bad);
      }
    });

    test('a day that is not a calendar day of the documented form', () {
      for (final bad in [
        '2026-02-30',
        '2026-13-01',
        '2026-1-5',
        '2026-01-10T00:00:00Z',
        '১৪৩২-০১-০১',
        '',
      ]) {
        expect(() => ApiDates.day(bad), throwsFormatException, reason: bad);
      }
    });

    test('a lookup with a bad last check or batch day is a wrong answer', () {
      // Under `guard`, a FormatException is `CoreReason.answerShape`, as for
      // every other field (final.md §6): never a check shown without its
      // time.
      expect(() => lookup(lastAt: 'yesterday'), throwsFormatException);
      expect(
        () => lookup(
          batch: {'number': 'B-1', 'made': '18/09/2025', 'expires': null},
        ),
        throwsFormatException,
      );
    });

    test('each is written in one place', () {
      final lib = readLib('lib');
      Iterable<String> using(Pattern p) =>
          lib.entries.where((e) => e.value.contains(p)).map((e) => e.key);
      expect(using('Random.secure('), ['core/utils/secure_random.dart']);
      expect(using("padLeft(2, '0')}-"), isEmpty);
      expect(
        using(RegExp(r'DateTime\.(try)?[pP]arse\(')),
        ['core/network/api_dates.dart'],
      );
      expect(
        using(
          RegExp(r'!= null &&\s*(clock\.now\(\)|_now\(\)|now)\.isBefore\('),
        ),
        isEmpty,
      );
      expect(using('SessionQuery(status: query.status'), isEmpty);
    });
  });
}
