import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ziska_verify/core/services/scanner/scanner_service.dart';

class MobileScannerService implements ScannerService {
  const MobileScannerService();

  @override
  ScannerSession createSession() => _MobileScannerSession();
}

class _MobileScannerSession implements ScannerSession {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  Widget preview({
    required void Function(String raw) onCode,
    required Widget Function(BuildContext context, ScannerProblem problem)
    errorBuilder,
  }) => MobileScanner(
    controller: _controller,
    onDetect: (capture) {
      for (final code in capture.barcodes) {
        final raw = code.rawValue;
        if (code.format == BarcodeFormat.qrCode && raw != null) {
          onCode(raw);
          return;
        }
      }
    },
    errorBuilder: (context, error) => errorBuilder(
      context,
      switch (error.errorCode) {
        MobileScannerErrorCode.permissionDenied =>
          ScannerProblem.permissionDenied,
        MobileScannerErrorCode.unsupported => ScannerProblem.unsupported,
        _ => ScannerProblem.other,
      },
    ),
  );

  @override
  Future<void> start() => _controller.start();

  @override
  Future<void> stop() => _controller.stop();

  @override
  Future<void> toggleTorch() => _controller.toggleTorch();

  @override
  Future<void> dispose() => _controller.dispose();
}
