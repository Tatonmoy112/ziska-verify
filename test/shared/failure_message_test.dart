import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/l10n/generated/app_localizations.dart';
import 'package:ziska_verify/shared/extensions/failure_message.dart';

/// TC-ERR-051: the general message for a failure. The guide's error table
/// (§1): a 409 `conflict` "conflicts with the current state … Show the
/// message". Other known codes show the app's own text; an unknown code
/// shows the server's message.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  String text(AppException e) => Failure(e).message(l10n);

  test('a 409 conflict shows the server message', () {
    expect(
      text(
        const ConflictException(
          statusCode: 409,
          code: 'conflict',
          message: 'The report has 3 photos already.',
        ),
      ),
      'The report has 3 photos already.',
    );
  });

  test('a 409 conflict without a message falls back to the general text', () {
    expect(
      text(
        const ConflictException(
          statusCode: 409,
          code: 'conflict',
          message: ' ',
        ),
      ),
      l10n.errorGeneral,
    );
    expect(text(const ConflictException(statusCode: 409)), l10n.errorGeneral);
  });

  test("another known code keeps the app's own text", () {
    expect(
      text(
        const ForbiddenException(
          statusCode: 403,
          code: 'forbidden',
          message: 'Forbidden.',
        ),
      ),
      l10n.errorGeneral,
    );
  });

  test("an unknown code shows the server's message, as before", () {
    expect(
      text(
        const InternalErrorException(
          statusCode: 400,
          code: 'something_new',
          message: 'A new reason.',
        ),
      ),
      'A new reason.',
    );
  });
}
