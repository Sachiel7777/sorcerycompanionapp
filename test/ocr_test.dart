import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorcery_companion/data/ocr.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('readTextLines turns the native answer into scanned lines', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('sorcery_companion/ocr'),
      (call) async {
        received = call;
        return [
          {'text': 'Apprentice Wizard', 'height': 54.0},
          {'text': 'Minion', 'height': 21},
        ];
      },
    );

    final lines = await readTextLines('/tmp/card.jpg');

    expect(received?.method, 'recognize');
    expect(received?.arguments, {'path': '/tmp/card.jpg'});
    expect(lines.map((l) => l.text), ['Apprentice Wizard', 'Minion']);
    expect(lines.map((l) => l.height), [54.0, 21.0]);
  });
}
