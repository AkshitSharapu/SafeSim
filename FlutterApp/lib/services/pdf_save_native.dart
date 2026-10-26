import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String> savePdf(Uint8List bytes, String name) async {
  final root = await getApplicationDocumentsDirectory();
  final dir = Directory('${root.path}/certificates');
  await dir.create(recursive: true);
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes, flush: true);
  return 'Certificate PDF saved locally: $name';
}
