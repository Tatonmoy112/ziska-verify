import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/services/logging/log_redactor.dart';

/// What crash reporting receives for an error (final.md §12; production
/// audit P-10). An error's own text can hold anything (a `FormatException`
/// quotes the answer it could not read, a layout error the text on screen),
/// so only its type is sent, with an app error's code, status and request
/// reference. The stack trace is sent beside it, as it holds code places
/// only.
class ReportedError {
  /// The error as its type.
  factory ReportedError.of(Object error) {
    final type = error.runtimeType.toString();
    if (error is AppException) {
      final parts = [
        if (error.code != null) 'code: ${error.code}',
        if (error.statusCode != null) 'status: ${error.statusCode}',
        if (error.requestId != null) 'request: ${error.requestId}',
      ];
      return ReportedError._(
        parts.isEmpty ? type : '$type(${parts.join(', ')})',
      );
    }
    return ReportedError._(type);
  }

  /// An app-written line, redacted, when there is no error object.
  factory ReportedError.line(String line) =>
      ReportedError._(LogRedactor.redact(line));

  const ReportedError._(this._text);

  final String _text;

  @override
  String toString() => _text;
}
