import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/certificate.dart';
import '../models/worker.dart';
import '../database/app_database.dart';
import '../utils/id_generator.dart';

class CertificateService {
  static final CertificateService instance = CertificateService._();
  CertificateService._();

  /// Creates and issues a new certificate for a worker
  Future<Certificate> issueCertificate({
    required Worker worker,
    required String moduleName,
    required int score,
  }) async {
    final certId = IdGenerator.generateCertificateId(moduleTag: 'FIRE', year: 2026);
    final nowFormatted = DateFormat('dd MMMM yyyy').format(DateTime.now());

    final certificate = Certificate(
      certificateId: certId,
      workerId: worker.id,
      module: moduleName,
      score: score,
      issuedAt: nowFormatted,
      qrCode: certId, // Contains strictly SAFE-FIRE-2026-XXXXXXXX with no web links
      workerName: worker.name,
    );

    // Save in local SQLite DB
    await AppDatabase.instance.saveCertificate(certificate);

    return certificate;
  }

  /// Builds the high-resolution vector PDF document
  Future<Uint8List> generatePdfDocument(Certificate cert) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('1565C0'), width: 4),
              color: PdfColors.white,
            ),
            padding: const pw.EdgeInsets.all(24),
            child: pw.Stack(
              children: [
                // Decorative inner border
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('E2E8F0'), width: 1.5),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Header Branding
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'SAFESIM INDUSTRIAL SAFETY DIRECTORATE',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('1565C0'),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              pw.Text(
                                'OFFLINE CERTIFIED SAFETY COMPLIANCE',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColor.fromHex('64748B'),
                                ),
                              ),
                            ],
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('E3F2FD'),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                            ),
                            child: pw.Text(
                              'OFFICIAL ACCREDITATION',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('1565C0'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 16),

                      // Certificate Title
                      pw.Text(
                        'CERTIFICATE OF INDUSTRIAL COMPETENCY',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('1E293B'),
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'This document officially certifies that',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColor.fromHex('64748B'),
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      // Worker Name
                      pw.Text(
                        (cert.workerName ?? cert.workerId).toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('1565C0'),
                        ),
                      ),
                      pw.Text(
                        'Worker Identification Code: ${cert.workerId}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('475569'),
                        ),
                      ),
                      pw.SizedBox(height: 14),

                      // Certification Body Text
                      pw.Container(
                        width: 500,
                        child: pw.Text(
                          'Has successfully completed the standardized industrial safety training and live interactive simulation curriculum for:',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.black,
                            lineSpacing: 1.3,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),

                      // Module Name
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('F1F5F9'),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Text(
                          cert.module.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('0D47A1'),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 16),

                      // Footer Row: Date & Score, QR Code, Signature
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          // Left Details: Date, Score, Cert ID
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Issue Date: ${cert.issuedAt}',
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                              ),
                              pw.Text(
                                'Assessment Score: ${cert.score}% (PASSED)',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('2E7D32'),
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Cert ID: ${cert.certificateId}',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('1E293B'),
                                ),
                              ),
                            ],
                          ),

                          // Center: Offline QR Code
                          pw.Column(
                            children: [
                              pw.Container(
                                width: 68,
                                height: 68,
                                child: pw.BarcodeWidget(
                                  barcode: pw.Barcode.qrCode(),
                                  data: cert.qrCode, // Strictly SAFE-FIRE-2026-XXXXXXXX
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'OFFLINE VERIFY',
                                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                              ),
                            ],
                          ),

                          // Right: Signature
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(
                                width: 140,
                                height: 1,
                                color: PdfColor.fromHex('64748B'),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Dr. Rajesh Vardhan',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('1E293B'),
                                ),
                              ),
                              pw.Text(
                                'Chief Industrial Safety Officer',
                                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Saves the PDF file locally to the device storage
  Future<File> savePdfLocally(Certificate cert) async {
    final pdfBytes = await generatePdfDocument(cert);
    final dir = await getApplicationDocumentsDirectory();
    final certsDir = Directory('${dir.path}/certificates');
    if (!await certsDir.exists()) {
      await certsDir.create(recursive: true);
    }

    final file = File('${certsDir.path}/${cert.certificateId}.pdf');
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  /// Views or prints the PDF using system printing sheet
  Future<void> viewOrPrintPdf(Certificate cert) async {
    final pdfBytes = await generatePdfDocument(cert);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: cert.certificateId,
    );
  }

  /// Shares the PDF via standard OS share dialog
  Future<void> sharePdf(Certificate cert) async {
    final pdfBytes = await generatePdfDocument(cert);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${cert.certificateId}.pdf',
    );
  }
}
