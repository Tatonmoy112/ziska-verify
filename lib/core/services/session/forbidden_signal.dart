import 'dart:async';

/// Raised when a request answers `403 forbidden`: the official's role may
/// have lost a permission, so the profile is loaded again and the router
/// hides what the role no longer allows (final.md Sections 7.2, 9.4).
class ForbiddenSignal {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void raise() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}
