import 'dart:io';

/// Static scans of `lib/` for the UI rules (docs/test-cases/15-ui.md,
/// sections A and D).

/// The hand-written Dart files of `lib/`, with `//` comments removed.
Map<String, String> sources() => {
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>())
    if (f.path.endsWith('.dart') &&
        !f.path.endsWith('.g.dart') &&
        !f.path.endsWith('.freezed.dart') &&
        !sourcePath(f.path).startsWith('lib/l10n/generated/'))
      sourcePath(f.path): f
          .readAsLinesSync()
          .map((l) => l.replaceFirst(RegExp(r'//.*$'), ''))
          .join('\n'),
};

String sourcePath(String p) => p.replaceAll(r'\', '/');

/// Each `file:line: text` of [pattern] outside the [except] files.
List<String> scan(RegExp pattern, {Set<String> except = const {}}) => [
  for (final MapEntry(key: path, value: text) in sources().entries)
    if (!except.contains(path))
      for (final (i, line) in text.split('\n').indexed)
        if (pattern.hasMatch(line)) '$path:${i + 1}: ${line.trim()}',
];

/// Each call of [callee] whose arguments hold a number (not a token), over
/// as many lines as the call takes.
List<String> scanCalls(String callee, {Set<String> except = const {}}) {
  // A number other than 0 (no gap on that side).
  final number = RegExp(r'(?<![\w.])(?!0\b)\d+(\.\d+)?\b');
  final found = <String>[];
  for (final MapEntry(key: path, value: text) in sources().entries) {
    if (except.contains(path)) continue;
    var from = 0;
    while (true) {
      final at = text.indexOf(callee, from);
      if (at < 0) break;
      final open = text.indexOf('(', at);
      from = at + callee.length;
      // `EdgeInsets.zero` and the like have no arguments.
      if (open < 0 || RegExp(r'[^\w]').hasMatch(text.substring(from, open))) {
        continue;
      }
      var depth = 0;
      var close = open;
      for (; close < text.length; close++) {
        if (text[close] == '(') depth++;
        if (text[close] == ')' && --depth == 0) break;
      }
      final args = text.substring(open + 1, close);
      if (number.hasMatch(args)) {
        final line = '\n'.allMatches(text.substring(0, at)).length + 1;
        found.add(
          '$path:$line: $callee${args.replaceAll(RegExp(r'\s+'), ' ')}',
        );
      }
    }
  }
  return found;
}

/// The argument text of each call of [callee] (`IconButton(` and
/// `IconButton.filledTonal(` for `IconButton`), with its `file:line`.
List<(String, String)> callArguments(
  String callee, {
  Set<String> except = const {},
}) {
  final found = <(String, String)>[];
  final start = RegExp(
    r'\b'
    '$callee'
    r'(\.[a-zA-Z]+)?\(',
  );
  for (final MapEntry(key: path, value: text) in sources().entries) {
    if (except.contains(path)) continue;
    for (final m in start.allMatches(text)) {
      var depth = 0;
      var close = m.end - 1;
      for (; close < text.length; close++) {
        if (text[close] == '(') depth++;
        if (text[close] == ')' && --depth == 0) break;
      }
      final line = '\n'.allMatches(text.substring(0, m.start)).length + 1;
      found.add(('$path:$line', text.substring(m.end, close)));
    }
  }
  return found;
}
