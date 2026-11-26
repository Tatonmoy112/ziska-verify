import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ziska_verify/core/errors/result.dart';
import 'package:ziska_verify/core/services/session/session_service.dart';
import 'package:ziska_verify/core/services/session/session_state.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';
import 'package:ziska_verify/features/profile/domain/usecases/profile_usecases.dart';

part 'profile_cubit.freezed.dart';

enum ProfileStatus { initial, loading, loaded, failure }

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    Profile? profile,
    Failure? failure,
  }) = _ProfileState;

  const ProfileState._();

  Set<Permission> get permissions => profile?.permissions ?? const {};
}

/// App-scoped profile (final.md §11). Loads when the official is
/// logged in, clears on logout. Read by the router (its guard and the
/// route builders), the shell's tabs, and the screens that show what the
/// role may do.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._getProfile,
    SessionService session, {
    Stream<void>? forbidden,
  }) : super(const ProfileState()) {
    _subscription = session.states.listen(_onSession);
    _forbidden = forbidden?.listen((_) => unawaited(refresh()));
    final current = session.current;
    if (current != null) _onSession(current);
  }

  final GetProfile _getProfile;
  late final StreamSubscription<SessionState> _subscription;
  StreamSubscription<void>? _forbidden;
  bool _refreshing = false;

  void _onSession(SessionState state) {
    switch (state) {
      case SessionAuthenticated():
        if (this.state.status != ProfileStatus.loading) unawaited(load());
      case SessionUnauthenticated():
      case SessionAwaitingCode():
        emit(const ProfileState());
      case SessionPasswordChangeRequired():
        break;
    }
  }

  /// Loads at start, after login, and after any `403 forbidden`
  /// (final.md §7).
  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading, failure: null));
    final result = await _getProfile();
    if (isClosed) return;
    result.when(
      onSuccess: (profile) => emit(
        ProfileState(status: ProfileStatus.loaded, profile: profile),
      ),
      onFailure: (failure) => emit(
        state.copyWith(status: ProfileStatus.failure, failure: failure),
      ),
    );
  }

  /// After a `403 forbidden` (final.md §7): the profile is loaded
  /// again in the background. The current one stays until the new one
  /// arrives, so the official is moved only when a permission is gone
  /// (§9). One reload at a time; a failure keeps the current one.
  Future<void> refresh() async {
    if (_refreshing || state.status != ProfileStatus.loaded) return;
    _refreshing = true;
    final result = await _getProfile();
    _refreshing = false;
    if (isClosed) return;
    result.when(
      onSuccess: (profile) => emit(
        ProfileState(status: ProfileStatus.loaded, profile: profile),
      ),
      onFailure: (_) {},
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _forbidden?.cancel();
    return super.close();
  }
}
