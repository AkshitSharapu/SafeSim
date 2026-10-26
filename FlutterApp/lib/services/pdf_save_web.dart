import 'dart:typed_data';
import 'package:printing/printing.dart';

Future<String> savePdf(Uint8List bytes, String name) async {
  final success = await Printing.sharePdf(bytes: bytes, filename: name);
  if (!success) throw StateError('Browser download was not started');
  return 'PDF download requested: $name. Check your browser downloads.';
}
