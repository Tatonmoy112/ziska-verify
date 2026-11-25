import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/retail_user_usecases.dart';

class _Recording implements RetailUserRepository {
  final searches = <String?>[];

  @override
  Future<Result<CursorPage<RetailUser>>> search(
    String? search,
    PageRequest page,
  ) async {
    searches.add(search);
    return const Success(CursorPage<RetailUser>(items: []));
  }
}

/// `GET retail-users?search=` takes "up to 100 characters" (guide
/// section 7.1); the backend counts characters as code points (§3.6).
void main() {
  late _Recording repository;
  late SearchRetailUsers search;
  setUp(() {
    repository = _Recording();
    search = SearchRetailUsers(repository);
  });

  Future<String?> sent(String? typed) async {
    await search(typed, const PageRequest());
    return repository.searches.last;
  }

  /// Whether [text] is whole UTF-16: no half of a character.
  bool whole(String text) {
    for (var i = 0; i < text.length; i++) {
      final unit = text.codeUnitAt(i);
      if (unit >= 0xD800 && unit <= 0xDBFF) {
        if (i + 1 >= text.length) return false;
        final next = text.codeUnitAt(i + 1);
        if (next < 0xDC00 || next > 0xDFFF) return false;
        i++;
      } else if (unit >= 0xDC00 && unit <= 0xDFFF) {
        return false;
      }
    }
    return true;
  }

  test('nothing typed, or spaces only: no search', () async {
    expect(await sent(null), isNull);
    expect(await sent(''), isNull);
    expect(await sent('   '), isNull);
  });

  test('the spaces around a search are removed', () async {
    expect(await sent('  rahim store '), 'rahim store');
  });

  test('100 characters go whole; more are cut to 100', () async {
    expect(await sent('a' * 100), 'a' * 100);
    expect(await sent('a' * 150), 'a' * 100);
  });

  // TC-REP-063 (test-server integration, step 8): the server counts a
  // search in UTF-16 units: 98 letters and an emoji (100 units) pass; 99
  // letters and an emoji (100 code points, 101 units) answer 400 (backend
  // question B5). The app keeps a search within 100 units, cut at a whole
  // character, so it passes whichever way the server counts.
  test('TC-REP-063 a search is cut at a whole character, within 100 '
      'UTF-16 units', () async {
    expect(await sent('${'a' * 98}🙂'), '${'a' * 98}🙂');
    expect(await sent('${'a' * 99}🙂'), 'a' * 99);
    expect(await sent('${'a' * 100}🙂'), 'a' * 100);

    final emoji = await sent('🙂' * 101);
    expect(emoji, '🙂' * 50);
    expect(emoji!.length, 100);
    expect(whole(emoji), isTrue);

    // Letters outside ASCII are one unit each: 100 of them go whole.
    expect(await sent('é' * 120), 'é' * 100);
    expect(await sent('ক' * 100), 'ক' * 100);
  });
}
