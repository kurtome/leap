import 'package:flutter_test/flutter_test.dart';

import 'package:leap/src/characters/jumper_character.dart';

void main() {
  test('runner', () {
    final character = JumperCharacter();
    expect(character.isAlive, isTrue, reason: 'starts alive');
    expect(character.walking, isFalse, reason: 'starts standing');
  });
}
