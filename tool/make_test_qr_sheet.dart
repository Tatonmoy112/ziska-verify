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
    );
  final file = File('docs/test-qr-sheet.pdf');
  await file.writeAsBytes(await doc.save());
  stdout.writeln('Wrote ${file.path}');
}
