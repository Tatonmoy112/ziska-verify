import 'dart:convert';
import 'dart:io';

/// Reads a saved example answer from the backend's Postman collection
/// (`docs/protectb-api/`), the app's contract (final.md §15).
Map<String, dynamic> postmanExample({
  required String request,
  required String example,
}) {
  final file = File(
    'docs/protectb-api/ProtectB-mobile-app.postman_collection.json',
  );
  final collection =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  Map<String, dynamic>? find(List<dynamic> items) {
    for (final item in items.cast<Map<String, dynamic>>()) {
      final children = item['item'] as List<dynamic>?;
      if (children != null) {
        final found = find(children);
        if (found != null) return found;
      } else if (item['name'] == request) {
        for (final r
            in (item['response'] as List<dynamic>)
                .cast<Map<String, dynamic>>()) {
          if (r['name'] == example) {
            return jsonDecode(r['body'] as String) as Map<String, dynamic>;
          }
        }
      }
    }
    return null;
  }

  final body = find(collection['item'] as List<dynamic>);
  if (body == null) {
    throw StateError('No Postman example "$example" for "$request".');
  }
  return body;
}
