import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether the phone has a network (final.md Section 14.2). It knows the
/// phone's link only: Wi-Fi without internet still counts as online, and a
/// request that fails then says so itself.
abstract interface class ConnectivityService {
  Future<bool> isOnline();

  /// Each change of [isOnline].
  Stream<bool> get online;
}

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
