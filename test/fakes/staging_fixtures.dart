import 'dart:convert';
import 'dart:io';

import 'scripted_adapter.dart';

/// A real answer of the backend's test server, saved by
/// `tool/staging_check` with passes, emails and references removed
/// (`test/fixtures/staging/`). Tests replay it offline.
Map<String, dynamic> stagingAnswer(String name) =>
    jsonDecode(File('test/fixtures/staging/$name').readAsStringSync())
        as Map<String, dynamic>;

/// [stagingAnswer] as the fake network's answer: its status and body.
ScriptedAnswer stagingScripted(String name) {
  final answer = stagingAnswer(name);
  return ScriptedAnswer(
    answer['status'] as int,
    answer['body'] as Map<String, Object?>,
  );
}
