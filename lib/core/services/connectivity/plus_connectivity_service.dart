import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ziska_verify/core/services/connectivity/connectivity_service.dart';

class PlusConnectivityService implements ConnectivityService {
  PlusConnectivityService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// No link at all, or only "none".
  static bool _hasLink(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Future<bool> isOnline() async =>
      _hasLink(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get online =>
      _connectivity.onConnectivityChanged.map(_hasLink).distinct();
}
