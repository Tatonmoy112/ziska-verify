import 'package:flutter/widgets.dart';
import 'package:ziska_verify/core/services/logging/logger_service.dart';

/// Logs route names only, never parameters or `extra`
/// (final.md §9).
class AppNavigationObserver extends NavigatorObserver {
  AppNavigationObserver(this._logger);

  final LoggerService _logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _logger.debug('route → ${route.settings.name}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _logger.debug('route ⇄ ${newRoute?.settings.name}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _logger.debug('route ← ${route.settings.name}');
}
