import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';

/// The general message for a failure (final.md Section 16). Screens handle
/// their own cases first (for example `401` on Login) and fall back to this.
extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => switch (exception) {
    NetworkException() => l10n.errorNetwork,
    RateLimitedException(:final retryAfter) => l10n.errorRateLimited(
      retryAfter?.inSeconds ?? 60,
    ),
    AppPreparingException() => l10n.errorPreparing,
    ServiceUnavailableException() => l10n.errorUnavailable,
    NotFoundException() => l10n.errorNotAvailable,
    _ => _serverFallback ?? l10n.errorGeneral,
  };

  /// The server's message is used only for an `error.code` this app does
  /// not know (final.md Section 16); known codes always show the app's text.
  String? get _serverFallback {
    final code = exception.code;
    final text = exception.message?.trim();
    if (code == null || _knownCodes.contains(code)) return null;
    return (text == null || text.isEmpty) ? null : text;
  }
}

/// The `error.code` values of the API guide §1.
const _knownCodes = {
  'validation_failed',
  'token_expired',
  'unauthenticated',
  'password_change_required',
  'policy_denied',
  'forbidden',
  'not_found',
  'conflict',
  'rate_limited',
  'app_preparing',
  'service_unavailable',
  'internal_error',
};
