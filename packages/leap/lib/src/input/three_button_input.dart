import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:leap/leap.dart';
import 'package:leap/src/mixins/mixins.dart';

/// Combines touch screen and keyboard input into one API.
class ThreeButtonInput extends Component
    with HasGameRef<LeapGame>, AppLifecycleAware {
  late final ThreeButtonTapInput _tapInput;
  late final ThreeButtonKeyboardInput _keyboardInput;
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

  bool get isPressedCenter =>
      _appFocused &&
      (_tapInput.isPressedCenter || _keyboardInput.isPressedCenter);

  ThreeButtonInput({
    ThreeButtonKeyboardInput? keyboardInput,
  }) {
    _tapInput = ThreeButtonTapInput();
    _keyboardInput = keyboardInput ?? ThreeButtonKeyboardInput();
    add(_tapInput);
    add(_keyboardInput);
  }

  ThreeButtonKeyboardInput get keyboardInput => _keyboardInput;
  ThreeButtonTapInput get tapInput => _tapInput;

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

class ThreeButtonTapInput extends PositionComponent
    with TapCallbacks, HasGameRef<LeapGame> {
  ThreeButtonTapInput({
    this.upEvent,
    this.downEvent,
  });

  TapUpEvent? upEvent;
  TapDownEvent? downEvent;

  @override
  bool get debugMode => true;

  bool get isPressed => downEvent != null && upEvent == null;

  bool get isPressedLeft {
    if (downEvent != null) {
      return isPressed && downEvent!.devicePosition.x < game.canvasSize.x / 3;
    }
    return false;
  }

  bool get isPressedCenter {
    if (downEvent != null) {
      return isPressed && _eventInCenterThird(downEvent!);
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

  bool _eventInCenterThird(TapDownEvent downEvent) {
    final x = downEvent.devicePosition.x;
    return x >= (_screenWidth / 3) && x < (_screenWidth * 2.0 / 3);
  }

  @override
  Future<void> onLoad() async {
    size = game.leapMap.size;
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

class ThreeButtonKeyboardInput extends Component with KeyboardHandler {
  ThreeButtonKeyboardInput({
    Set<PhysicalKeyboardKey>? leftKeys,
    Set<PhysicalKeyboardKey>? rightKeys,
    Set<PhysicalKeyboardKey>? centerKeys,
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

    this.centerKeys = centerKeys ??
        {
          PhysicalKeyboardKey.arrowUp,
          PhysicalKeyboardKey.keyW,
          PhysicalKeyboardKey.keyK,
          PhysicalKeyboardKey.arrowDown,
          PhysicalKeyboardKey.keyS,
          PhysicalKeyboardKey.keyJ,
        };

    relevantKeys = this.leftKeys.union(this.rightKeys).union(this.centerKeys);
  }

  late final Set<PhysicalKeyboardKey> leftKeys;

  late final Set<PhysicalKeyboardKey> rightKeys;

  late final Set<PhysicalKeyboardKey> centerKeys;

  late final Set<PhysicalKeyboardKey> relevantKeys;

  final Set<PhysicalKeyboardKey> keysDown = {};

  bool get isPressed => keysDown.isNotEmpty;

  bool get isPressedLeft =>
      isPressed && keysDown.intersection(leftKeys).isNotEmpty;

  bool get isPressedRight =>
      isPressed && keysDown.intersection(rightKeys).isNotEmpty;

  bool get isPressedCenter =>
      isPressed && keysDown.intersection(centerKeys).isNotEmpty;

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
