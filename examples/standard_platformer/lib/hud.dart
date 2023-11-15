import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:leap_standard_platformer/main.dart';

class Hud extends PositionComponent with HasGameRef<ExamplePlatformerLeapGame> {
  Hud() {
    final textPaint = TextPaint(style: textStyle);
    textComponent = TextComponent(textRenderer: textPaint);
    add(textComponent);

    x = 16;
    y = 4;
  }

  late final TextComponent textComponent;
  late final CameraComponent cameraComponent;

  static const textStyle = TextStyle(
    fontSize: 10,
    color: Colors.white,
    shadows: [Shadow(blurRadius: 4)],
  );

  @override
  void update(double dt) {
    super.update(dt);
    textComponent.text = 'Coins: ${gameRef.player?.coins ?? 0}';
  }
}
