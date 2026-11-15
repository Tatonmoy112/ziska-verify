import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/usecases/get_checks.dart';

enum CheckTotalsStatus { loading, ready, failed }

class CheckTotalsState {
  const CheckTotalsState({required this.status, this.totals});

  final CheckTotalsStatus status;

  /// The last counts; kept while they are asked for again.
  final CheckTotals? totals;
}

/// The official's own check counts for the Profile cards (final.md Section
/// 13.8): the first page of `GET checks` with no filters and `limit=1`,
/// whose `totals` count every own check. No new endpoint.
class CheckTotalsCubit extends Cubit<CheckTotalsState> {
  CheckTotalsCubit(this._getChecks)
    : super(const CheckTotalsState(status: CheckTotalsStatus.loading));

  final GetChecks _getChecks;
  bool _loading = false;

  /// Asks for the counts; a second call while one runs is ignored.
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    emit(
      CheckTotalsState(status: CheckTotalsStatus.loading, totals: state.totals),
    );
    final result = await _getChecks(
      const CheckQuery(),
      const PageRequest(limit: 1),
    );
    _loading = false;
    if (isClosed) return;
    switch (result) {
      // A first page always carries `totals`; without them the counts are
      // unknown, as when the request fails.
      case Success(value: CheckPage(:final totals?)):
        emit(CheckTotalsState(status: CheckTotalsStatus.ready, totals: totals));
      case _:
        emit(
          CheckTotalsState(
            status: CheckTotalsStatus.failed,
            totals: state.totals,
          ),
        );
    }
  }
}
