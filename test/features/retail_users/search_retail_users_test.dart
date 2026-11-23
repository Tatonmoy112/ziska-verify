import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/retail_users/domain/entities/retail_user.dart';
import 'package:ziska_verify/features/retail_users/domain/repositories/retail_user_repository.dart';
import 'package:ziska_verify/features/retail_users/domain/usecases/search_retail_users.dart';

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

  // TC-REP-063: a search is up to 100 characters (guide §7.1), and every
  // length counts code points: an emoji counts as one (backend DEC-429).
  // A longer search is cut after 100, at a whole character.
  test('TC-REP-063 a search is cut at 100 code points, at a whole '
      'character', () async {
    expect(await sent('${'a' * 99}🙂'), '${'a' * 99}🙂');
    expect(await sent('${'a' * 100}🙂'), 'a' * 100);

    final emoji = await sent('🙂' * 101);
    expect(emoji, '🙂' * 100);
    expect(whole(emoji!), isTrue);

    expect(await sent('é' * 120), 'é' * 100);
    expect(await sent('ক' * 100), 'ক' * 100);
  });
}
