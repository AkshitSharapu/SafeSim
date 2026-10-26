import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/worker.dart';
import '../models/worker_identity.dart';

Future<void> showWorkerBadge(BuildContext context, Worker worker) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Offline Worker QR'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(worker.name, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text('${worker.role}\n${worker.department}', textAlign: TextAlign.center),
      const SizedBox(height: 12),
      QrImageView(data: WorkerIdentity.encode(worker.id), size: 200,
        backgroundColor: Colors.white, padding: const EdgeInsets.all(16)),
      SelectableText(worker.id),
      const SizedBox(height: 12),
      const Text('Scan inside SafeSim to open this worker’s profile on a device where they are registered.',
        textAlign: TextAlign.center),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
      FilledButton.icon(icon: const Icon(Icons.save_alt), label: const Text('Export badge PDF'),
        onPressed: () async {
          try {
            final pdf = pw.Document();
            pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a5, build: (_) =>
              pw.Center(child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
                pw.Text('SAFESIM - WORKER ID', style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 20), pw.Text(worker.name),
                pw.Text(worker.role), pw.Text(worker.department), pw.SizedBox(height: 20),
                pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: WorkerIdentity.encode(worker.id),
                  width: 180, height: 180),
                pw.SizedBox(height: 16), pw.Text(worker.id),
                pw.Text('Scan inside SafeSim. Local profile must be registered.'),
              ]))));
            await Printing.sharePdf(bytes: await pdf.save(), filename: '${worker.id}_Worker_Badge.pdf');
          } catch (_) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not export badge. Your on-screen QR is still available.')));
          }
        }),
    ],
  ),
);
