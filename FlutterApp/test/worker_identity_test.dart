import 'package:flutter_test/flutter_test.dart';
import 'package:safesim/models/worker_identity.dart';

void main() {
  test('each worker has a stable, distinct QR identity', () {
    expect(WorkerIdentity.encode('wk001'), 'SAFESIM:WK001');
    expect(WorkerIdentity.encode('WK002'), isNot(WorkerIdentity.encode('WK001')));
  });
  test('new QR, original badges, and original JSON badges resolve to an ID', () {
    for (final input in ['SAFESIM:WK001', 'wk001', ' WK001 ', '{"id":"WK001"}']) {
      expect(WorkerIdentity.decode(input), 'WK001');
    }
  });
  test('arbitrary links, names and incomplete payloads cannot identify workers', () {
    for (final value in ['https://example.com/WK001', 'Sharapu Akshit', 'SAFESIM:',
      'SAFESIM:WK001:WK002', '{}', '{"id":3}', '']) {
      expect(() => WorkerIdentity.decode(value), throwsFormatException);
    }
  });
  test('registration requires a bounded, nonempty identifier', () {
    for (final value in ['A', 'A B', List.filled(41, 'A').join()]) {
      expect(() => WorkerIdentity.normalize(value), throwsFormatException);
    }
  });
}
