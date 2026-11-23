import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/features/history/domain/services/history_search.dart';

/// TC-HIST-056 (emulator run, finding F-4): History's `search` is "a serial
/// or a reference number"; any other value answers 400 (guide §5). A serial
/// is read as everywhere (guide §4, "Reading a serial"): digits, zeros kept,
/// up to 64 characters before the 400. A reference is `MA-<year>-<6+ digits>`
/// (phase 4). Other digits read as 0–9, as the app does elsewhere.
void main() {
  group('TC-HIST-056 what a History search sends', () {
    void sends(String typed, String sent) {
      final search = HistorySearch.read(typed);
      expect(search.status, SearchStatus.ok, reason: typed);
      expect(search.value, sent, reason: typed);
    }

    void refuses(String typed) => expect(
      HistorySearch.read(typed).status,
      SearchStatus.refused,
      reason: typed,
    );

    test('nothing typed: no search', () {
      for (final typed in ['', '   ', '\n']) {
        expect(HistorySearch.read(typed).status, SearchStatus.empty);
      }
    });

    test('a serial: digits, zeros kept, trimmed', () {
      sends('1', '1');
      sends('1000001', '1000001');
      sends(' 0001000001 ', '0001000001');
      sends('9' * 64, '9' * 64);
    });

    test('Bangla and other digits read as 0-9', () {
      sends('১০০০০০১', '1000001');
      sends('١٠٠٠٠٠١', '1000001');
    });

    test('a whole reference number, in any case', () {
      sends('MA-2026-000123', 'MA-2026-000123');
      sends('ma-2026-000046', 'MA-2026-000046');
      sends('MA-2026-1000000', 'MA-2026-1000000');
      sends('MA-২০২৬-০০০১২৩', 'MA-2026-000123');
    });

    test('anything else is refused', () {
      [
        'MA-2026',
        'MA-2026-',
        'MA-2026-00012',
        'MA-26-000123',
        'XY-2026-000123',
        'MA 2026 000123',
        '1000 001',
        '1000-001',
        '12AB',
        'abc',
        '9' * 65,
        '1000&scope=all',
      ].forEach(refuses);
    });
  });
}
