import 'package:flutter/painting.dart';

/// Corner radius tokens.
abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;

  static const input = BorderRadius.all(Radius.circular(md));
  static const button = BorderRadius.all(Radius.circular(md));
  static const card = BorderRadius.all(Radius.circular(lg));
}
