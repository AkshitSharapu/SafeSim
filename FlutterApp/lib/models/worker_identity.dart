import 'dart:convert';

/// QR codes identify a local record; they contain no scores or personal data.
class WorkerIdentity {
  static final _pattern = RegExp(r'^[A-Z0-9][A-Z0-9_-]{2,39}$');
  static String normalize(String input) {
    final id = input.trim().toUpperCase();
    if (!_pattern.hasMatch(id)) {
      throw const FormatException('Use 3–40 letters, numbers, underscores or hyphens for the Worker ID.');
    }
    return id;
  }
  static String encode(String id) => 'SAFESIM:${normalize(id)}';
  static String decode(String input) {
    var code = input.trim();
    if (code.startsWith('{')) {
      final value = jsonDecode(code);
      if (value is! Map) throw const FormatException('Invalid worker QR');
      final id = value['id'] ?? value['workerCode'];
      if (id is! String) throw const FormatException('QR contains no Worker ID');
      code = id;
    }
    if (code.toUpperCase().startsWith('SAFESIM:')) code = code.substring(8);
    return normalize(code);
  }
}
