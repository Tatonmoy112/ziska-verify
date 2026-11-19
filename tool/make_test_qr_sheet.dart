// Makes docs/test-qr-sheet.pdf: QR codes for the manual camera tests
// (docs/manual-test-checklist.md). Run: dart run tool/make_test_qr_sheet.dart
import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// (label, QR content, what the app must do)
const codes = <(String, String, String)>[
  (
    'Q1 Product QR',
    'https://www.ziskaverify.com/q/Q8F2KD91XA7M',
    'Looked up; only Q8F2KD91XA7M is sent',
  ),
  (
    'Q2 Product QR, another host',
    'https://other-client.example/q/A1B2C3D4E5F6',
    'Looked up (any host is accepted)',
  ),
  (
    'Q3 Product QR',
    'https://www.ziskaverify.com/q/Z9Y8X7W6V5U4',
    'Looked up',
  ),
  (
    'Q4 Not a product QR',
    'https://www.google.com',
    '"This QR code is not a product code..."; no browser opens',
  ),
  (
    'Q5 Malformed product QR',
    'https://www.ziskaverify.com/q/abc',
    '"This QR code is not a product code..."; nothing sent',
  ),
];

/// Scanner mode on the mock build: 8 products, read one after another.
/// The mock gives each QR the result of its last character (1 genuine,
/// 2 needs attention, 3 not found, 4 not in a batch;
/// docs/postman-mock-setup.md).
const scannerCodes = <(String, String)>[
  ('S1', 'K7M2PX4Q9AB1'),
  ('S2', 'R3T8WZ5N2CD2'),
  ('S3', 'H6J9LV1B4EF3'),
  ('S4', 'P2Q7XM8S5GH4'),
  ('S5', 'D4F1NC6T7JK1'),
  ('S6', 'W8Y3RB2V9LM1'),
  ('S7', 'T5G9KQ4X3NP2'),
  ('S8', 'B9C6HM1Z8QR1'),
];

String _mockResult(String code) => switch (code[code.length - 1]) {
  '2' => 'Genuine, needs attention',
  '3' => 'Not found',
  '4' => 'Not in a batch',
  _ => 'Genuine product',
};

pw.Widget _scannerCode((String, String) entry) {
  final (label, code) = entry;
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
    ),
    child: pw.Column(
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: 'https://www.ziskaverify.com/q/$code',
          width: 130,
          height: 130,
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '$label  $code',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Mock: ${_mockResult(code)}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    ),
  );
}

Future<void> main() async {
  final doc = pw.Document(title: 'Track & Trace test QR codes')
    ..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'Track & Trace: test QR codes',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'For docs/manual-test-checklist.md. Show on a screen or print. '
            'Test data only: these are not real products.',
          ),
          pw.SizedBox(height: 16),
          for (final (label, data, expected) in codes)
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Row(
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: data,
                    width: 120,
                    height: 120,
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          label,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(data, style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('Expected: $expected'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    )
    ..addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Scanner mode: 8 products',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Mock build. Check tab -> Scanner mode. Scan S1 to S8 one after '
              'another without waiting: each result shows on the camera as it '
              'comes and joins the list below. Then scan S1 again: "Already '
              'scanned". Tap Finish: "8 products scanned", every product with '
              'its result.',
            ),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [for (final entry in scannerCodes) _scannerCode(entry)],
            ),
          ],
        ),
      ),
    );
  final file = File('docs/test-qr-sheet.pdf');
  await file.writeAsBytes(await doc.save());
  stdout.writeln('Wrote ${file.path}');
}
