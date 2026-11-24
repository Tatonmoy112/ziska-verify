import 'package:flutter/widgets.dart';

/// Why the camera could not scan.
enum ScannerProblem { permissionDenied, unsupported, other }

/// One scanning session: a camera preview that reports QR codes only
/// (final.md §1, §5). Barcodes are never read.
abstract interface class ScannerSession {
  /// The camera preview. [onCode] receives the raw text of each QR code.
  Widget preview({
    required void Function(String raw) onCode,
    required Widget Function(BuildContext context, ScannerProblem problem)
    errorBuilder,
  });

  Future<void> start();
  Future<void> stop();
  Future<void> toggleTorch();
  Future<void> dispose();
}

/// Creates scanning sessions; features never import the scanner plugin.
abstract interface class ScannerService {
  ScannerSession createSession();
}
