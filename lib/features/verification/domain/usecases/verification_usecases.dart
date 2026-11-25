import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/verification/domain/entities/failure_reasons.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/prepared_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';
import 'package:ziska_verify/features/verification/domain/repositories/verification_repository.dart';
import 'package:ziska_verify/features/verification/domain/services/serial_key.dart';

class GetFormats {
  const GetFormats(this._repository);
  final VerificationRepository _repository;

  Future<Result<InputFormats>> call() => _repository.getFormats();
}

class LookupItem {
  const LookupItem(this._repository);
  final VerificationRepository _repository;

  /// Sends a value `PrepareInput` accepted.
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
/// guide §4.7). Its rule is here, in one place (production audit P-29):
/// 1 to [serialStackLimit] items, each counted once by the serial key.
class CheckSerials {
  const CheckSerials(this._repository);
  final VerificationRepository _repository;

  /// Why [serials] cannot be sent as one stack, or `null`. A screen may ask
  /// first, to say so without a request.
  static ValidationException? refusal(List<String> serials) {
    final items = distinctSerials(serials).length;
    return items == 0 || items > serialStackLimit
        ? const ValidationException(reason: VerificationReason.serialStackSize)
        : null;
  }

  /// Sends each item once, the first typed of each kept, in the order
  /// typed; a stack that does not fit is never sent.
  Future<Result<SerialStackResult>> call(List<String> serials) async {
    final refused = refusal(serials);
    if (refused != null) return Err(Failure(refused));
    return _repository.serials(List.unmodifiable(distinctSerials(serials)));
  }
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
