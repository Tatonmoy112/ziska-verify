import 'dart:collection';
import 'dart:convert';
import 'dart:io';

/// The layer rules of final.md §3, §4 and §11, checked on the imports of
/// `lib/` (docs/production-audit.md, P-1).
enum Rule {
  coreImportsFeature('R1', 'core imports a feature or app'),
  sharedImportsFeature('R2', 'shared imports a feature or app'),
  featureImportsApp('R3', 'a feature imports app'),
  crossFeature('R4', 'a feature imports another feature'),
  presentationImportsData('R5', 'presentation imports data'),
  domainImportsOuterLayer('R6', 'domain imports data or presentation'),
  dataImportsPresentation('R7', 'data imports presentation'),
  domainReachesFlutter('R8', 'domain reaches Flutter'),
  domainReachesImpure('R9', 'domain reaches a package that is not pure Dart'),
  pluginOutsideCore('R10', 'a plugin is used outside core'),
  getItOutsideApp('R11', 'get_it is used outside app'),
  dioOutsideNetwork('R12', 'dio is used outside core, data and app'),
  outsideLayers('R13', 'a feature file is outside data, domain, presentation'),
  presentationImportsRepository(
    'R14',
    'presentation imports a repository, not a use case',
  ),
  pluginReachedOutsideCore(
    'R15',
    'a file outside core and app reaches a plugin through its imports',
  ),
  interfaceWithPlugin('R16', 'an interface file in core also uses a plugin'),
  coreFolderCycle('R17', 'core folders depend on each other in a circle'),
  foreignRoute('R18', "a feature opens another feature's route itself"),
  apiServiceWithoutInterface(
    'R19',
    'an API service is not an interface with a Dio implementation',
  ),
  routeOutsideApiRoutes(
    'R20',
    'a route is made outside core/network/api_routes.dart',
  )
  ;

  const Rule(this.id, this.text);

  final String id;
  final String text;
}

/// One break of a [Rule]: [file] (relative to `lib/`) and what it imports,
/// or the chain of files through which it reaches a package.
class Violation {
  const Violation(this.rule, this.file, this.detail);

  final Rule rule;
  final String file;
  final String detail;

  /// Stable text for the list of known breaks.
  String get key => '${rule.id} $file -> $detail';

  @override
  String toString() => '${rule.id} (${rule.text}): $file -> $detail';
}

/// Checks a set of sources, keyed by their path relative to `lib/`.
class LayerRules {
  const LayerRules({required this.plugins, this.routeOwners = const {}});

  /// Packages with platform code (`flutter: plugin:` in their pubspec).
  final Set<String> plugins;

  /// The feature that owns each name of `RouteNames` (R18). Empty: the rule
  /// is not checked.
  final Map<String, String> routeOwners;

  /// Routes every screen may open: Home, the app's root.
  static const openToAll = {'home'};

  /// Every feature may import the app-wide profile entity and Cubit
  /// (final.md §4).
  static const sharedProfile = {
    'features/profile/domain/entities/profile.dart',
    'features/profile/presentation/bloc/profile_cubit.dart',
  };

  /// Packages the domain may use: pure Dart, no platform.
  static const purePackages = {
    'clock',
    'collection',
    'freezed_annotation',
    'intl',
    'json_annotation',
    'meta',
    'timezone',
  };

  /// Dart libraries that tie code to a platform.
  static const _impureDart = {
    'dart:ffi',
    'dart:html',
    'dart:io',
    'dart:isolate',
    'dart:js',
    'dart:js_interop',
    'dart:js_util',
    'dart:mirrors',
  };

  static const _flutter = {'package:flutter', 'dart:ui'};

  List<Violation> check(Map<String, String> sources) {
    final imports = {
      for (final MapEntry(:key, :value) in sources.entries)
        key: _imports(key, value),
    };
    final found = <String, Violation>{};
    void add(Rule rule, String file, String detail) {
      final v = Violation(rule, file, detail);
      found.putIfAbsent(v.key, () => v);
    }

    for (final file in sources.keys) {
      if (isGenerated(file)) continue;
      final from = _Place.of(file);
      if (from.area == _Area.feature && routeOwners.isNotEmpty) {
        final code = sources[file]!.replaceAll(_comment, '');
        for (final m in _routeName.allMatches(code)) {
          final name = m.group(1)!;
          if (openToAll.contains(name)) continue;
          final owner = routeOwners[name];
          if (owner != from.feature) {
            add(
              Rule.foreignRoute,
              file,
              'RouteNames.$name (${owner ?? 'no owner'})',
            );
          }
        }
      }
      // Every route of the API is made in one file (P-17).
      if (file != 'core/network/api_routes.dart' &&
          _newRoute.hasMatch(sources[file]!.replaceAll(_comment, ''))) {
        add(Rule.routeOutsideApiRoutes, file, 'ApiRoute(…)');
      }
      if (from.layer == _Layer.data && _apiServiceFile.hasMatch(file)) {
        _checkApiService(file, sources[file]!, add);
      }
      if (from.area == _Area.feature && from.layer == null) {
        add(Rule.outsideLayers, file, 'not in a layer');
      }
      for (final target in imports[file]!) {
        if (target.startsWith('package:') || target.startsWith('dart:')) {
          _checkPackage(from, file, target, add);
        } else {
          _checkLink(from, file, target, add);
        }
      }
      if (from.layer == _Layer.domain) {
        _checkReach(file, imports, add);
      }
      // The domain is R9's; main and app compose the app (P-7).
      if (from.area == _Area.shared ||
          from.layer == _Layer.presentation ||
          from.layer == _Layer.data) {
        _checkPluginReach(file, imports, add);
      }
      if (from.area == _Area.core &&
          _interface.hasMatch(sources[file]!.replaceAll(_comment, ''))) {
        for (final target in imports[file]!) {
          if (target.startsWith('package:') &&
              plugins.contains(target.substring(8))) {
            add(Rule.interfaceWithPlugin, file, target);
          }
        }
      }
    }
    _checkFolderCycles(sources.keys, imports, add);
    return found.values.toList()..sort(_order);
  }

  void _checkLink(
    _Place from,
    String file,
    String target,
    void Function(Rule, String, String) add,
  ) {
    final to = _Place.of(target);
    final outward = to.area == _Area.feature || to.area == _Area.app;
    if (from.area == _Area.core && outward) {
      add(Rule.coreImportsFeature, file, target);
    }
    if (from.area == _Area.shared && outward) {
      add(Rule.sharedImportsFeature, file, target);
    }
    if (from.area != _Area.feature) return;
    if (to.area == _Area.app) add(Rule.featureImportsApp, file, target);
    if (to.area == _Area.feature &&
        to.feature != from.feature &&
        !sharedProfile.contains(target)) {
      add(Rule.crossFeature, file, target);
    }
    if (to.area != _Area.feature) return;
    if (from.layer == _Layer.presentation && to.layer == _Layer.data) {
      add(Rule.presentationImportsData, file, target);
    }
    // Blocs reach data through use cases only (production audit P-3).
    if (from.layer == _Layer.presentation &&
        to.layer == _Layer.domain &&
        target.contains('/domain/repositories/')) {
      add(Rule.presentationImportsRepository, file, target);
    }
    if (from.layer == _Layer.domain &&
        (to.layer == _Layer.data || to.layer == _Layer.presentation)) {
      add(Rule.domainImportsOuterLayer, file, target);
    }
    if (from.layer == _Layer.data && to.layer == _Layer.presentation) {
      add(Rule.dataImportsPresentation, file, target);
    }
  }

  void _checkPackage(
    _Place from,
    String file,
    String package,
    void Function(Rule, String, String) add,
  ) {
    final name = package.startsWith('package:') ? package.substring(8) : null;
    if (name == null) return;
    if (plugins.contains(name) && from.area != _Area.core) {
      add(Rule.pluginOutsideCore, file, package);
    }
    if (name == 'get_it' && from.area != _Area.app) {
      add(Rule.getItOutsideApp, file, package);
    }
    final dioAllowed =
        from.area == _Area.core ||
        from.area == _Area.app ||
        from.layer == _Layer.data;
    if (name == 'dio' && !dioAllowed) {
      add(Rule.dioOutsideNetwork, file, package);
    }
  }

  /// Follows the imports of a domain file through `lib/` and reports the
  /// shortest chain to Flutter, and to each package that is not pure Dart.
  void _checkReach(
    String file,
    Map<String, List<String>> imports,
    void Function(Rule, String, String) add,
  ) {
    final path = <String, List<String>>{file: const []};
    final queue = Queue.of([file]);
    var flutterSeen = false;
    final impureSeen = <String>{};
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final via = path[current]!;
      for (final target in imports[current] ?? const <String>[]) {
        final external =
            target.startsWith('package:') || target.startsWith('dart:');
        if (!external) {
          if (!path.containsKey(target)) {
            path[target] = [...via, target];
            queue.add(target);
          }
          continue;
        }
        final chain = [...via, target].join(' -> ');
        if (_flutter.contains(target)) {
          if (!flutterSeen) add(Rule.domainReachesFlutter, file, chain);
          flutterSeen = true;
        } else if (_isImpure(target) && impureSeen.add(target)) {
          add(Rule.domainReachesImpure, file, chain);
        }
      }
    }
  }

  /// An API service is an `abstract interface class …ApiService` and a
  /// `Dio…` class implementing it (P-14): repositories and tests depend on
  /// the interface, only the composition root on Dio.
  void _checkApiService(
    String file,
    String source,
    void Function(Rule, String, String) add,
  ) {
    final code = source.replaceAll(_comment, '');
    final interface = _apiInterface.firstMatch(code)?.group(1);
    if (interface == null) {
      add(
        Rule.apiServiceWithoutInterface,
        file,
        'no abstract interface class …ApiService',
      );
      return;
    }
    final implementation = RegExp(
      '\\bclass Dio$interface\\s+implements\\s+$interface\\b',
    );
    if (!implementation.hasMatch(code)) {
      add(
        Rule.apiServiceWithoutInterface,
        file,
        'no Dio$interface implementing $interface',
      );
    }
  }

  /// Reports each circle of `core` folders once (P-8): the first file of
  /// the first folder that starts it, then the folders that lead back. A
  /// subfolder is a folder of its own.
  void _checkFolderCycles(
    Iterable<String> files,
    Map<String, List<String>> imports,
    void Function(Rule, String, String) add,
  ) {
    String folderOf(String path) => path.substring(0, path.lastIndexOf('/'));
    // Folder → next folder → the files that import into it, all sorted.
    final edges =
        SplayTreeMap<String, SplayTreeMap<String, SplayTreeSet<String>>>();
    for (final file in files) {
      if (isGenerated(file) || !file.startsWith('core/')) continue;
      for (final target in imports[file]!) {
        if (!target.startsWith('core/')) continue;
        final from = folderOf(file);
        final to = folderOf(target);
        if (from == to) continue;
        edges
            .putIfAbsent(from, SplayTreeMap.new)
            .putIfAbsent(to, SplayTreeSet.new)
            .add(file);
      }
    }
    final inCircle = <String>{};
    for (final start in edges.keys) {
      if (inCircle.contains(start)) continue;
      // The shortest way from [start] back to itself.
      final previous = <String, String>{};
      final queue = Queue.of([start]);
      List<String>? circle;
      while (queue.isNotEmpty && circle == null) {
        final current = queue.removeFirst();
        for (final next in edges[current]?.keys ?? const <String>[]) {
          if (next == start) {
            final way = [current];
            while (way.last != start) {
              way.add(previous[way.last]!);
            }
            circle = [...way.reversed, start];
            break;
          }
          if (next != start && !previous.containsKey(next)) {
            previous[next] = current;
            queue.add(next);
          }
        }
      }
      if (circle == null) continue;
      inCircle.addAll(circle);
      add(
        Rule.coreFolderCycle,
        edges[start]![circle[1]]!.first,
        circle.skip(1).join(' -> '),
      );
    }
  }

  /// Reports each plugin [file] reaches through at least one file of
  /// `lib/` (a direct import is R10's), with the shortest chain.
  void _checkPluginReach(
    String file,
    Map<String, List<String>> imports,
    void Function(Rule, String, String) add,
  ) {
    final path = <String, List<String>>{file: const []};
    final queue = Queue.of([file]);
    final seen = <String>{};
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final via = path[current]!;
      for (final target in imports[current] ?? const <String>[]) {
        if (target.startsWith('dart:')) continue;
        if (!target.startsWith('package:')) {
          if (!path.containsKey(target)) {
            path[target] = [...via, target];
            queue.add(target);
          }
          continue;
        }
        if (via.isNotEmpty &&
            plugins.contains(target.substring(8)) &&
            seen.add(target)) {
          add(
            Rule.pluginReachedOutsideCore,
            file,
            [...via, target].join(' -> '),
          );
        }
      }
    }
  }

  bool _isImpure(String target) => target.startsWith('dart:')
      ? _impureDart.contains(target)
      : !purePackages.contains(target.substring(8));

  static int _order(Violation a, Violation b) {
    final byFile = a.file.compareTo(b.file);
    if (byFile != 0) return byFile;
    final byRule = a.rule.index.compareTo(b.rule.index);
    return byRule != 0 ? byRule : a.detail.compareTo(b.detail);
  }
}

/// Generated code: read for what it imports, never reported.
bool isGenerated(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.startsWith('l10n/generated/');

final _comment = RegExp(r'//[^\n]*|/\*[\s\S]*?\*/');

/// An `ApiRoute` being made (R20); `ApiRoutes.x` is not one.
final _newRoute = RegExp(r'\bApiRoute(?:\._)?\(');

/// A feature's API service file and its interface (R19).
final _apiServiceFile = RegExp(
  r'^features/\w+/data/services/\w+_api_service\.dart$',
);
final _apiInterface = RegExp(
  r'^abstract interface class (\w+ApiService)\b',
  multiLine: true,
);

/// A route a screen names (`RouteNames.scannerMode`).
final _routeName = RegExp(r'\bRouteNames\.(\w+)');

/// A file that declares an interface (the plugin wrappers of `core`).
final _interface = RegExp('^abstract interface class ', multiLine: true);
final _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);
const _self = 'package:ziska_verify/';

/// What [file] imports and exports: a path in `lib/` for the app's own
/// files, `package:<name>` or `dart:<name>` for the rest.
List<String> _imports(String file, String source) {
  final code = source.replaceAll(_comment, '');
  return [
    for (final m in _directive.allMatches(code)) _resolve(file, m.group(1)!),
  ];
}

String _resolve(String file, String uri) {
  if (uri.startsWith(_self)) return uri.substring(_self.length);
  if (uri.startsWith('package:')) return uri.substring(0, uri.indexOf('/'));
  if (uri.startsWith('dart:')) return uri;
  final parts = file.split('/')..removeLast();
  for (final segment in uri.split('/')) {
    if (segment == '..') {
      parts.removeLast();
    } else if (segment != '.') {
      parts.add(segment);
    }
  }
  return parts.join('/');
}

enum _Area { app, core, shared, feature, other }

enum _Layer { data, domain, presentation }

class _Place {
  const _Place(this.area, {this.feature, this.layer});

  factory _Place.of(String path) {
    final parts = path.split('/');
    switch (parts.first) {
      case 'app':
        return const _Place(_Area.app);
      case 'core':
        return const _Place(_Area.core);
      case 'shared':
        return const _Place(_Area.shared);
      case 'features' when parts.length >= 2:
        final layer = parts.length >= 4
            ? _Layer.values.where((l) => l.name == parts[2]).firstOrNull
            : null;
        return _Place(_Area.feature, feature: parts[1], layer: layer);
    }
    return const _Place(_Area.other);
  }

  final _Area area;
  final String? feature;
  final _Layer? layer;
}

/// Every `.dart` file under [dir] except the generated parts (`.g.dart`,
/// `.freezed.dart`), keyed by its path relative to [dir] with `/`.
Map<String, String> readLib(String dir) {
  final root = Directory(dir);
  if (!root.existsSync()) {
    throw StateError('The code folder "$dir" does not exist.');
  }
  final prefix = root.absolute.path.length + 1;
  return {
    for (final f in root.listSync(recursive: true).whereType<File>())
      if (f.path.endsWith('.dart') &&
          !f.path.endsWith('.g.dart') &&
          !f.path.endsWith('.freezed.dart'))
        f.absolute.path.substring(prefix).replaceAll(r'\', '/'): f
            .readAsStringSync(),
  };
}

/// The packages in [packageConfig] (`.dart_tool/package_config.json`) whose
/// pubspec declares `flutter: plugin:`: the ones with platform code.
Set<String> pluginPackages(String packageConfig) {
  final file = File(packageConfig);
  if (!file.existsSync()) {
    throw StateError(
      '"$packageConfig" does not exist: run `flutter pub get` first.',
    );
  }
  final config = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final base = file.absolute.uri;
  final plugins = <String>{};
  for (final p in (config['packages'] as List).cast<Map<String, dynamic>>()) {
    // `rootUri` names the package folder, with or without a final `/`.
    final rootUri = p['rootUri'] as String;
    final root = base.resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');
    final pubspec = File.fromUri(root.resolve('pubspec.yaml'));
    if (pubspec.existsSync() && _isPlugin(pubspec)) {
      plugins.add(p['name'] as String);
    }
  }
  return plugins;
}

/// Whether the top-level `flutter:` section of [pubspec] has a `plugin:`
/// key, read line by line (no YAML package needed).
bool _isPlugin(File pubspec) {
  var inFlutter = false;
  for (final line in const LineSplitter().convert(pubspec.readAsStringSync())) {
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    final indented = line.startsWith(' ') || line.startsWith('\t');
    if (!indented) {
      inFlutter = line.trimRight() == 'flutter:';
    } else if (inFlutter && line.trim().startsWith('plugin:')) {
      return true;
    }
  }
  return false;
}
