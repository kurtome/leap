import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:leap/leap.dart';

/// Combines touch screen and keyboard input into one API.
class FourButtonInput extends Component
    with HasGameReference<LeapGame>, AppLifecycleAware {
  late final FourButtonTapInput _tapInput;
  late final FourButtonKeyboardInput _keyboardInput;
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
      game.appState == AppLifecycleState.resumed ||
      game.appState == AppLifecycleState.detached;

  bool get isPressed =>
      _appFocused && (_tapInput.isPressed || _keyboardInput.isPressed);

  bool get isPressedLeft =>
      _appFocused && (_tapInput.isPressedLeft || _keyboardInput.isPressedLeft);

  bool get isPressedRight =>
      _appFocused &&
      (_tapInput.isPressedRight || _keyboardInput.isPressedRight);

  bool get isPressedUp =>
      _appFocused && (_tapInput.isPressedUp || _keyboardInput.isPressedUp);

  bool get isPressedDown =>
      _appFocused && (_tapInput.isPressedDown || _keyboardInput.isPressedDown);

  FourButtonInput({
    FourButtonKeyboardInput? keyboardInput,
  }) {
    _tapInput = FourButtonTapInput();
    _keyboardInput = keyboardInput ?? FourButtonKeyboardInput();
    add(_tapInput);
    add(_keyboardInput);
  }

  FourButtonKeyboardInput get keyboardInput => _keyboardInput;
  FourButtonTapInput get tapInput => _tapInput;

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

class FourButtonTapInput extends PositionComponent
    with TapCallbacks, HasGameReference<LeapGame> {
  FourButtonTapInput({
    this.upEvent,
    this.downEvent,
  });

  TapUpEvent? upEvent;
  TapDownEvent? downEvent;

  bool get isPressed => downEvent != null && upEvent == null;

  bool get isPressedLeft {
    if (downEvent != null) {
      return isPressed && downEvent!.devicePosition.x < game.canvasSize.x / 3;
    }
    return false;
  }

  bool get isPressedUp {
    if (downEvent != null) {
      return isPressed &&
          _eventInCenterThird(downEvent!) &&
          downEvent!.devicePosition.y < _screenHeight / 2;
    }
    return false;
  }

  bool get isPressedDown {
    if (downEvent != null) {
      return isPressed &&
          _eventInCenterThird(downEvent!) &&
          downEvent!.devicePosition.y >= _screenHeight / 2;
    }
    return false;
  }

  bool get isPressedRight {
    if (downEvent != null) {
      return isPressed && downEvent!.devicePosition.x >= _screenWidth * 2.0 / 3;
    }
    return false;
  }

  double get _screenWidth => game.canvasSize.x;
  double get _screenHeight => game.canvasSize.y;

  bool _eventInCenterThird(TapDownEvent downEvent) {
    final x = downEvent.devicePosition.x;
    return x >= (_screenWidth / 3) && x < (_screenWidth * 2.0 / 3);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size.setFrom(size);
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

class FourButtonKeyboardInput extends Component with KeyboardHandler {
  FourButtonKeyboardInput({
    Set<PhysicalKeyboardKey>? leftKeys,
    Set<PhysicalKeyboardKey>? rightKeys,
    Set<PhysicalKeyboardKey>? upKeys,
    Set<PhysicalKeyboardKey>? downKeys,
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

    this.upKeys = upKeys ??
        {
          PhysicalKeyboardKey.arrowUp,
          PhysicalKeyboardKey.keyW,
          PhysicalKeyboardKey.keyK,
        };

    this.downKeys = downKeys ??
        {
          PhysicalKeyboardKey.arrowDown,
          PhysicalKeyboardKey.keyS,
          PhysicalKeyboardKey.keyJ,
        };

    relevantKeys = this
        .leftKeys
        .union(this.rightKeys)
        .union(this.upKeys)
        .union(this.downKeys);
  }

  late final Set<PhysicalKeyboardKey> leftKeys;

  late final Set<PhysicalKeyboardKey> rightKeys;

  late final Set<PhysicalKeyboardKey> upKeys;

  late final Set<PhysicalKeyboardKey> downKeys;

  late final Set<PhysicalKeyboardKey> relevantKeys;

  final Set<PhysicalKeyboardKey> keysDown = {};

  bool get isPressed => keysDown.isNotEmpty;

  bool get isPressedLeft =>
      isPressed && keysDown.intersection(leftKeys).isNotEmpty;

  bool get isPressedRight =>
      isPressed && keysDown.intersection(rightKeys).isNotEmpty;

  bool get isPressedUp => isPressed && keysDown.intersection(upKeys).isNotEmpty;

  bool get isPressedDown =>
      isPressed && keysDown.intersection(downKeys).isNotEmpty;

  @override
  bool onKeyEvent(KeyEvent keyEvent, Set<LogicalKeyboardKey> keysPressed) {
    // Ignore irrelevant keys.
    if (relevantKeys.contains(keyEvent.physicalKey)) {
      if (keyEvent is KeyDownEvent) {
        keysDown.add(keyEvent.physicalKey);
      } else if (keyEvent is KeyUpEvent) {
        keysDown.remove(keyEvent.physicalKey);
      }
    }
    return true;
  }
}
