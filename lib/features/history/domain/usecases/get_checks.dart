import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/pagination/page_request.dart';
import 'package:ziska_verify/features/history/domain/entities/check.dart';
import 'package:ziska_verify/features/history/domain/repositories/history_repository.dart';

class GetChecks {
  const GetChecks(this._repository);
  final HistoryRepository _repository;

  Future<Result<CheckPage>> call(CheckQuery query, PageRequest page) =>
      _repository.getChecks(query, page);
}
