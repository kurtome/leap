import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:leap/leap.dart';

/// Combines touch screen and keyboard input into one API.
class TwoButtonInput extends Component
    with HasGameRef<LeapGame>, AppLifecycleAware {
  late final TwoButtonTapInput _tapInput;
  late final TwoButtonKeyboardInput _keyboardInput;
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

  TwoButtonInput({
    TwoButtonKeyboardInput? keyboardInput,
  }) {
    _tapInput = TwoButtonTapInput();
    _keyboardInput = keyboardInput ?? TwoButtonKeyboardInput();
    add(_tapInput);
    add(_keyboardInput);
  }

  TwoButtonKeyboardInput get keyboardInput => _keyboardInput;
  TwoButtonTapInput get tapInput => _tapInput;

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

class TwoButtonTapInput extends PositionComponent
    with TapCallbacks, HasGameRef<LeapGame> {
  TwoButtonTapInput({
    this.upEvent,
    this.downEvent,
  });

  TapUpEvent? upEvent;
  TapDownEvent? downEvent;

  bool get isPressed => downEvent != null && upEvent == null;

  bool get isPressedLeft {
    if (downEvent != null) {
      return isPressed &&
          downEvent!.devicePosition.x < gameRef.canvasSize.x / 2;
    }
    return false;
  }

  bool get isPressedRight => isPressed && !isPressedLeft;

  @override
  Future<void> onLoad() async {
    size = game.world.map.size;
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

class TwoButtonKeyboardInput extends Component with KeyboardHandler {
  TwoButtonKeyboardInput({
    Set<PhysicalKeyboardKey>? leftKeys,
    Set<PhysicalKeyboardKey>? rightKeys,
  }) {
    this.leftKeys = leftKeys ??
        {
          PhysicalKeyboardKey.arrowLeft,
          PhysicalKeyboardKey.keyA,
          PhysicalKeyboardKey.keyH,
        };

    this.rightKeys = rightKeys ??
        {
          PhysicalKeyboardKey.arrowRight,
          PhysicalKeyboardKey.keyD,
          PhysicalKeyboardKey.keyL,
        };

    relevantKeys = this.leftKeys.union(this.rightKeys);
  }

  late final Set<PhysicalKeyboardKey> leftKeys;

  late final Set<PhysicalKeyboardKey> rightKeys;

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
