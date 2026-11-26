/// Which packages of `pubspec.yaml` nothing uses (production audit P-46).
///
/// A runtime package is used when `lib/` imports it. A dev package is used
/// when `test/` or `tool/` imports it, or when its own trace is there: the
/// generated parts of `build_runner`, `freezed` and `json_serializable`,
/// the `include:` of an analysis package, or a tool's top-level section in
/// `pubspec.yaml` (the icon and splash generators). Names alone excuse
/// nothing.
///
/// [sources] are keyed by their path from the project root, with `/`.
List<String> unusedPackages({
  required String pubspec,
  required String analysisOptions,
  required Map<String, String> sources,
}) {
  final (:runtime, :dev, :sections) = _read(pubspec);
  bool imports(String package, bool Function(String path) where) =>
      sources.entries.any(
        (e) => where(e.key) && e.value.contains("'package:$package/"),
      );
  bool inLib(String path) => path.startsWith('lib/');
  bool inDev(String path) =>
      path.startsWith('test/') || path.startsWith('tool/');
  bool hasPart(String suffix) => sources.values.any(
    (s) => RegExp("^part '[^']+$suffix';", multiLine: true).hasMatch(s),
  );

  bool traced(String package) => switch (package) {
    'build_runner' => hasPart(r'\.(g|freezed)\.dart'),
    'freezed' => hasPart(r'\.freezed\.dart'),
    'json_serializable' => hasPart(r'\.g\.dart'),
    _ =>
      analysisOptions.contains('include: package:$package/') ||
          sections.contains(package),
  };

  return [
    for (final p in runtime)
      if (!imports(p, inLib)) p,
    for (final p in dev)
      if (!imports(p, inDev) && !traced(p)) p,
  ];
}

/// The package names under `dependencies:` and `dev_dependencies:`, and
/// the other top-level sections.
({List<String> runtime, List<String> dev, Set<String> sections}) _read(
  String pubspec,
) {
  final runtime = <String>[];
  final dev = <String>[];
  final sections = <String>{};
  List<String>? into;
  final top = RegExp(r'^([A-Za-z_][\w-]*):');
  final entry = RegExp('^  ([a-z_][a-z0-9_]*):');
  for (final line in pubspec.split('\n')) {
    final t = top.firstMatch(line);
    if (t != null) {
      final name = t.group(1)!;
      into = switch (name) {
        'dependencies' => runtime,
        'dev_dependencies' => dev,
        _ => null,
      };
      if (into == null) sections.add(name);
      continue;
    }
    final e = entry.firstMatch(line);
    if (into != null && e != null) into.add(e.group(1)!);
  }
  return (runtime: runtime, dev: dev, sections: sections);
}
