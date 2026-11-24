import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/services/code_normalizer.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';
import 'package:ziska_verify/features/verification/domain/services/qr_link_parser.dart';

class GetFormats {
  const GetFormats(this._repository);
  final VerificationRepository _repository;

  Future<Result<InputFormats>> call() => _repository.getFormats();
}

/// The checked input, ready to send, or the reason it was refused.
sealed class PreparedInput {
  const PreparedInput();
}

final class ReadyInput extends PreparedInput {
  const ReadyInput(this.way, this.value);
  final LookupWay way;
  final String value;
}

final class RefusedInput extends PreparedInput {
  const RefusedInput(this.way, this.problem);
  final LookupWay way;
  final InputProblem problem;

  /// A scanned QR that is not a product QR link.
  bool get notProductQr => way == LookupWay.qr;
}

/// Steps 2 to 4 of the lookup flow (final.md §13.1): parse a QR
/// link, normalize, and check against the client's formats.
class PrepareInput {
  const PrepareInput({
    this.parser = const QrLinkParser(),
    this.normalizer = const CodeNormalizer(),
    this.validator = const InputFormatValidator(),
  });

  final QrLinkParser parser;
  final CodeNormalizer normalizer;
  final InputFormatValidator validator;

  PreparedInput call(LookupWay way, String raw, InputFormats formats) {
    final String value;
    if (way == LookupWay.qr) {
      final parsed = parser.parse(raw);
      if (parsed == null) {
        return const RefusedInput(LookupWay.qr, InputProblem.wrongFormat);
      }
      // The QR value is sent as read (guide section 4): only the spaces
      // around it go; the formats' characters decide whether it is valid.
      value = parsed.trim();
    } else {
      value = normalizer.normalize(raw);
    }
    final problem = validator.validate(way, value, formats);
    return problem == null
        ? ReadyInput(way, value)
        : RefusedInput(way, problem);
  }
}

/// A stack of serials as typed: split by commas, spaces or new lines, each
/// prepared like one serial, repeats kept once (app API guide §4.7).
class ParsedStack {
  const ParsedStack({
    required this.serials,
    required this.typed,
    this.bad,
  });

  /// The serials sent, each once, in the order typed.
  final List<String> serials;

  /// How many values were typed, repeats included.
  final int typed;

  /// The first value that is not a serial, by its place (from 1).
  final ({int position, String value})? bad;

  /// Values typed more than once, counted after preparing them, so
  /// "1000-001" and "1000001" are one serial.
  int get repeats => bad == null ? typed - serials.length : 0;
}

class ParseStack {
  const ParseStack([this._prepare = const PrepareInput()]);
  final PrepareInput _prepare;

  ParsedStack call(String text, InputFormats formats) {
    final serials = <String>[];
    final tokens = text
        .split(RegExp(r'[,\s]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    for (final (index, token) in tokens.indexed) {
      final input = _prepare(LookupWay.serial, token, formats);
      if (input is! ReadyInput) {
        return ParsedStack(
          serials: serials,
          typed: tokens.length,
          bad: (position: index + 1, value: token),
        );
      }
      if (!serials.any((s) => sameSerial(s, input.value))) {
        serials.add(input.value);
      }
    }
    return ParsedStack(serials: serials, typed: tokens.length);
  }
}

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

class LookupItem {
  const LookupItem(this._repository);
  final VerificationRepository _repository;

  /// Sends a value [PrepareInput] accepted.
  Future<Result<LookupResult>> call(ReadyInput input) =>
      _repository.lookup(input.way, input.value);
}

/// One session of the official (`GET lookups/sessions/{id}`,
/// app API guide §4.5): the header of its checks.
class GetSession {
  const GetSession(this._repository);
  final VerificationRepository _repository;

  Future<Result<ScanSessionSummary>> call(String id) => _repository.session(id);
}

/// One read of scanner mode, inside its session (`POST lookups` with
/// `session_id`, app API guide §4.3). The value is sent as read.
class ScanItem {
  const ScanItem(this._repository);
  final VerificationRepository _repository;

  Future<Result<ScanResult>> call(String value, {required String sessionId}) =>
      _repository.scan(value, sessionId);
}

/// A serial stack, sent as one request (`POST lookups/serials`, app API
/// guide §4.7). [ParseStack] prepares the list; it is sent unchanged.
class CheckSerials {
  const CheckSerials(this._repository);
  final VerificationRepository _repository;

  Future<Result<SerialStackResult>> call(List<String> serials) =>
      _repository.serials(serials);
}

/// Ends a scanner session (`POST lookups/sessions/{id}/end`,
/// app API guide §4.4).
class EndSession {
  const EndSession(this._repository);
  final VerificationRepository _repository;

  Future<Result<void>> call(String id) => _repository.endSession(id);
}

/// One page of the official's sessions (`GET lookups/sessions`, app API
/// guide §4.5).
class GetSessions {
  const GetSessions(this._repository);
  final VerificationRepository _repository;

  Future<Result<CursorPage<ScanSessionSummary>>> call(
    SessionQuery query,
    PageRequest page,
  ) => _repository.sessions(query, page);
}
