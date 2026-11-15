import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';
import 'package:ziska_verify/features/verification/domain/services/input_format_validator.dart';
import 'package:ziska_verify/features/verification/domain/usecases/verification_usecases.dart';
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
    LookupWay.hiddenCode => l10n.inputWrongHiddenCode,
    LookupWay.qr => l10n.notProductQr,
  };
}

/// Lookup errors (final.md Section 13.1.6).
String lookupFailureMessage(AppLocalizations l10n, Failure failure) =>
    switch (failure.exception) {
      NetworkException() => l10n.lookupNetworkError,
      _ => failure.message(l10n),
    };
