import 'package:flutter_test/flutter_test.dart';

import 'package:leap/leap.dart';

void main() {
  test('runner', () {
    final character = JumperCharacter();
    expect(character.isAlive, true, reason: 'starts alive');
    expect(character.walking, false, reason: 'starts standing');
  });
}
