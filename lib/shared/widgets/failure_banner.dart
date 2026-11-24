import 'package:flutter/material.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/widgets/error_banner.dart';
import 'package:ziska_verify/shared/widgets/retry_countdown.dart';

/// A failed request under a form: [message] with the reference, or for a
/// `429` a countdown to [retryAt] that goes away at 0 (final.md
/// §14.1, §15).
class FailureBanner extends StatelessWidget {
  const FailureBanner({
    required this.failure,
    required this.message,
    this.retryAt,
    super.key,
  });

  final Failure failure;

  /// The text for any failure other than a `429`.
  final String message;

  final DateTime? retryAt;

  @override
  Widget build(BuildContext context) {
    if (failure.exception is! RateLimitedException || retryAt == null) {
      return ErrorBanner(message: message, requestId: failure.requestId);
    }
    final l10n = AppLocalizations.of(context);
    return RetryCountdown(
      until: retryAt,
      builder: (context, seconds) => seconds == 0
          ? const SizedBox.shrink()
          : ErrorBanner(
              message: l10n.errorRateLimited(seconds),
              requestId: failure.requestId,
            ),
    );
  }
}
