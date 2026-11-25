import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ziska_verify/core/navigation/route_names.dart';
import 'package:ziska_verify/features/verification/domain/entities/checked_input.dart';
import 'package:ziska_verify/features/verification/domain/entities/lookup.dart';

/// Where a lookup started: where **Try again** returns (final.md
/// §13.1).
enum ResultOrigin { verify, scanner, manyItems }

/// Everything the result screen shows, passed as the route's `extra`
/// (final.md §9, §13.1). Contains serial/QR input and server results.
class ResultView {
  const ResultView({
    required this.result,
    required this.input,
    required this.origin,
    this.formats,
  });

  final LookupResult result;
  final CheckedInput input;
  final ResultOrigin origin;

  /// The client's formats, for the hints of a `not_found` result.
  final InputFormats? formats;
}

/// Opens the result page for [view]. The result is the check feature's own
/// route, so its screens open it themselves (final.md §9; production audit
/// P-41); it ends when the page closes.
Future<void> openResult(BuildContext context, ResultView view) =>
    context.pushNamed<void>(RouteNames.lookupResult, extra: view);
