import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/entities/prepared_input.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';

/// Why an input was not sent.
String refusedMessage(
  AppLocalizations l10n,
  RefusedInput refused,
  InputFormats formats,
) {
  if (refused.problem == InputProblem.empty) return l10n.inputEmpty;
  return switch (refused.way) {
    LookupWay.serial => l10n.inputWrongSerial(formats.serialMaxDigits),
    LookupWay.qr => l10n.notProductQr,
  };
}

/// Lookup errors (final.md §13.1). A request that never left the
/// phone recorded nothing; an answer lost after sending may have been
/// recorded, and checking again counts as another check
/// (UI audit 2026-11-22, 4.2).
String lookupFailureMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure.exception) {
      NetworkException(:final wasNotSent) =>
        wasNotSent ? l10n.lookupNetworkError : l10n.lookupAnswerLost,
      _ => failure.message(l10n),
    };
