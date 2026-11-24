import 'package:ziska_verify/core/errors/app_exception.dart';

/// Logging that never carries passes, passwords, emailed codes, hidden
/// codes, or the phone ID (final.md Section 12.2). Callers log the route,
/// the status, and `request_id` instead.
abstract interface class LoggerService {
  void debug(String message);
  void info(String message);
  void warning(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Removes anything that looks like a secret before a line is written:
/// bearer passes, JSON fields holding secrets, and 6-digit codes.
abstract final class LogRedactor {
  static final _patterns = <RegExp>[
    RegExp(r'Bearer\s+[A-Za-z0-9\-_.~+/]+=*', caseSensitive: false),
    RegExp(
      '"(access_token|refresh_token|password|old_password|new_password|'
      r'code|phone_id|value)"\s*:\s*"[^"]*"',
      caseSensitive: false,
    ),
    RegExp(r'\b\d{6}\b'),
  ];

  static String redact(String input) {
    var out = input;
    for (final p in _patterns) {
      out = out.replaceAllMapped(p, (m) {
        final text = m.group(0)!;
        if (text.toLowerCase().startsWith('bearer')) return 'Bearer ***';
        final key = m.groupCount >= 1 ? m.group(1) : null;
        return key == null ? '***' : '"$key":"***"';
      });
    }
    return out;
  }
}

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
