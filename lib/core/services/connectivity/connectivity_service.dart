/// Whether the phone has a network (final.md §14.2). It knows the
/// phone's link only: Wi-Fi without internet still counts as online, and a
/// request that fails then says so itself.
abstract interface class ConnectivityService {
  Future<bool> isOnline();

  /// Each change of [isOnline].
  Stream<bool> get online;
}
