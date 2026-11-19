import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/cursor_page.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/scan_session.dart';
import 'package:ziska_verify/features/verification/domain/entities/serial_stack.dart';

abstract interface class VerificationRepository {
  Future<Result<InputFormats>> getFormats();
  Future<Result<LookupResult>> lookup(LookupWay way, String value);
  Future<Result<ScanResult>> scan(String value, String sessionId);
  Future<Result<SerialStackResult>> serials(List<String> values);
  Future<Result<void>> endSession(String id);
  Future<Result<ScanSessionSummary>> session(String id);
  Future<Result<CursorPage<ScanSessionSummary>>> sessions(
    SessionQuery query,
    PageRequest page,
  );
}
