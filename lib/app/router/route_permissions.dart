import 'package:ziska_verify/app/router/route_paths.dart';
import 'package:ziska_verify/features/profile/domain/entities/profile.dart';

/// Whether a role's [permissions] allow a page.
typedef PermissionCheck = bool Function(Set<Permission> permissions);

/// The permission each guarded path needs (final.md §9), for the router's
/// guard and the History tab. Fixed: nothing can add or change a path at
/// run time (production audit P-43).
final Map<String, PermissionCheck> routePermissions = Map.unmodifiable(
  <String, PermissionCheck>{
    RoutePaths.history: _history,
    RoutePaths.lookupResult: (p) => _lookup(p) || _bulkLookup(p),
    RoutePaths.scannerMode: _bulkLookup,
    RoutePaths.serialStack: _bulkLookup,
    RoutePaths.sessions: _history,
    RoutePaths.myReports: _report,
    RoutePaths.reportIncident: _report,
  },
);

bool _history(Set<Permission> p) => p.contains(Permission.ownHistory);

bool _report(Set<Permission> p) => p.contains(Permission.report);

bool _lookup(Set<Permission> p) => p.contains(Permission.lookup);

bool _bulkLookup(Set<Permission> p) => p.contains(Permission.bulkLookup);
