import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leap/leap.dart';

void main() {
  group('input', () {
    group('SimpleCombinedInput', () {
      test('has the correct default keys', () {
        final input = SimpleCombinedInput();
        expect(
          input.keyboardInput.leftKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowLeft,
              PhysicalKeyboardKey.keyA,
              PhysicalKeyboardKey.keyH,
            },
          ),
        );
        expect(
          input.keyboardInput.rightKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowRight,
              PhysicalKeyboardKey.keyD,
              PhysicalKeyboardKey.keyL,
            },
          ),
        );
        expect(
          input.keyboardInput.relevantKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowLeft,
              PhysicalKeyboardKey.keyA,
              PhysicalKeyboardKey.keyH,
              PhysicalKeyboardKey.arrowRight,
              PhysicalKeyboardKey.keyD,
              PhysicalKeyboardKey.keyL,
            },
          ),
        );
      });

      test('can have custom keys', () {
        final input = SimpleCombinedInput(
          keyboardInput: SimpleKeyboardInput(
            leftKeys: {
              PhysicalKeyboardKey.arrowUp,
            },
            rightKeys: {
              PhysicalKeyboardKey.arrowDown,
            },
          ),
        );
        expect(
          input.keyboardInput.leftKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowUp,
            },
          ),
        );
        expect(
          input.keyboardInput.rightKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowDown,
            },
          ),
        );
        expect(
          input.keyboardInput.relevantKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowUp,
              PhysicalKeyboardKey.arrowDown,
            },
          ),
        );
      });
    });

    group('SimpleKeyboardInput', () {
      test('has the correct default keys', () {
        final input = SimpleKeyboardInput();
        expect(
          input.leftKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowLeft,
              PhysicalKeyboardKey.keyA,
              PhysicalKeyboardKey.keyH,
            },
          ),
        );
        expect(
          input.rightKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowRight,
              PhysicalKeyboardKey.keyD,
              PhysicalKeyboardKey.keyL,
            },
          ),
        );
        expect(
          input.relevantKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowLeft,
              PhysicalKeyboardKey.keyA,
              PhysicalKeyboardKey.keyH,
              PhysicalKeyboardKey.arrowRight,
              PhysicalKeyboardKey.keyD,
              PhysicalKeyboardKey.keyL,
            },
          ),
        );
      });

      test('can have custom keys', () {
        final input = SimpleKeyboardInput(
          leftKeys: {
            PhysicalKeyboardKey.arrowUp,
          },
          rightKeys: {
            PhysicalKeyboardKey.arrowDown,
          },
        );
        expect(
          input.leftKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowUp,
            },
          ),
        );
        expect(
          input.rightKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowDown,
            },
          ),
        );
        expect(
          input.relevantKeys,
          equals(
            {
              PhysicalKeyboardKey.arrowUp,
              PhysicalKeyboardKey.arrowDown,
            },
          ),
        );
      });
    });
  });
}
