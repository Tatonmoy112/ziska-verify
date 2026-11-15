import 'package:ziska_verify/core/errors/app_exception.dart';
import 'package:ziska_verify/core/network/api_client.dart';
import 'package:ziska_verify/features/verification/data/models/verification_dtos.dart';

/// `GET formats`, `POST lookups`, `POST lookups/bulk` (final.md 5.7).
abstract interface class VerificationApiService {
  Future<FormatsDto> getFormats();

  Future<LookupResultDto> lookup({required String way, required String value});

  /// [items] are `{way, value}` pairs, 1 to 500, in the order to match.
  Future<BulkResponseDto> lookupBulk(List<Map<String, String>> items);
}

class DioVerificationApiService implements VerificationApiService {
  DioVerificationApiService(this._api);

  final ApiClient _api;

  @override
  Future<FormatsDto> getFormats() async =>
      FormatsDto.fromJson(_map(await _api.get('formats')));

  @override
  Future<LookupResultDto> lookup({
    required String way,
    required String value,
  }) async => LookupResultDto.fromJson(
    _map(await _api.post('lookups', body: {'way': way, 'value': value})),
  );

  @override
  Future<BulkResponseDto> lookupBulk(List<Map<String, String>> items) async =>
      BulkResponseDto.fromJson(
        _map(await _api.post('lookups/bulk', body: {'items': items})),
      );

  static Map<String, dynamic> _map(Object? data) {
    if (data is Map<String, dynamic>) return data;
    throw const InternalErrorException(message: 'verification_shape');
  }
}
