import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:leap/src/leap_game.dart';
import 'package:leap/src/mixins/mixins.dart';

/// Combines touch screen and keyboard input into one API.
class SimpleCombinedInput extends Component
    with HasGameRef<LeapGame>, AppLifecycleAware {
  late final SimpleTapInput _tapInput;
  late final SimpleKeyboardInput _keyboardInput;
  double pressedTime = 0;
  bool justPressed = false;

  @override
  void appLifecycleStateChanged(
    AppLifecycleState previous,
    AppLifecycleState current,
  ) {
    // When the app is backgrounded or foregrounded, reset inputs to avoid
    // any weirdness with tap/key state getting out of sync.
    _tapInput.reset();
    _keyboardInput.keysDown.clear();
    pressedTime = 0;
    justPressed = false;
  }

  bool get _appFocused =>
      gameRef.appState == AppLifecycleState.resumed ||
      gameRef.appState == AppLifecycleState.detached;

  bool get isPressed =>
      _appFocused && (_tapInput.isPressed || _keyboardInput.isPressed);

  bool get isPressedLeft =>
      _appFocused && (_tapInput.isPressedLeft || _keyboardInput.isPressedLeft);

  bool get isPressedRight =>
      _appFocused &&
      (_tapInput.isPressedRight || _keyboardInput.isPressedRight);

  SimpleCombinedInput() {
    _tapInput = SimpleTapInput();
    _keyboardInput = SimpleKeyboardInput();
    add(_tapInput);
    add(_keyboardInput);
  }

  @override
  void update(double dt) {
    if (isPressed) {
      justPressed = pressedTime == 0;
      pressedTime += dt;
    } else {
      pressedTime = 0;
    }
  }
}

class SimpleTapInput extends PositionComponent
    with TapCallbacks, HasGameRef<LeapGame> {
  SimpleTapInput({
    this.upEvent,
    this.downEvent,
  });

  TapUpEvent? upEvent;
  TapDownEvent? downEvent;

  @override
  bool get debugMode => true;

  bool get isPressed => downEvent != null && upEvent == null;

  bool get isPressedLeft {
    final upEventInfo = upEvent?.asInfo(game);
    if (upEventInfo != null) {
      return isPressed &&
          upEventInfo.eventPosition.global.x < gameRef.canvasSize.x / 2;
    }
    return false;
  }

  bool get isPressedRight => isPressed && !isPressedLeft;

  @override
  Future<void> onLoad() async {
    size = gameRef.leapWorld.map.size;
    return super.onLoad();
  }

  @override
  bool onTapUp(TapUpEvent event) {
    upEvent = event;
    return true;
  }

  @override
  bool onTapDown(TapDownEvent event) {
    downEvent = event;
    upEvent = null;
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    reset();
    return true;
  }

  void reset() {
    downEvent = null;
    upEvent = null;
  }
}

class SimpleKeyboardInput extends Component with KeyboardHandler {
  SimpleKeyboardInput() : relevantKeys = leftKeys.union(rightKeys);

  static final leftKeys = {
    PhysicalKeyboardKey.arrowLeft,
    PhysicalKeyboardKey.keyA,
    PhysicalKeyboardKey.keyH,
  };

  static final rightKeys = {
    PhysicalKeyboardKey.arrowRight,
    PhysicalKeyboardKey.keyD,
    PhysicalKeyboardKey.keyL,
  };

  late final Set<PhysicalKeyboardKey> relevantKeys;

  final Set<PhysicalKeyboardKey> keysDown = {};

  bool get isPressed => keysDown.isNotEmpty;

  bool get isPressedLeft =>
      isPressed && keysDown.intersection(leftKeys).isNotEmpty;

  bool get isPressedRight =>
      isPressed && keysDown.intersection(rightKeys).isNotEmpty;

  @override
  bool onKeyEvent(RawKeyEvent keyEvent, Set<LogicalKeyboardKey> keysPressed) {
    // Ignore irrelevant keys.
    if (relevantKeys.contains(keyEvent.physicalKey)) {
      if (keyEvent is RawKeyDownEvent) {
        keysDown.add(keyEvent.physicalKey);
      } else if (keyEvent is RawKeyUpEvent) {
        keysDown.remove(keyEvent.physicalKey);
      }
    }
    return true;
  }
}
