import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class WelcomeDialog extends TextBoxComponent {
  late Rect rect;

  static const textStyle = TextStyle(
    fontSize: 10,
    color: Colors.white,
    shadows: [
      Shadow(
        blurRadius: 4,
      ),
    ],
  );

  WelcomeDialog(CameraComponent camera)
      : super(
          text: 'Welcome to Leap! '
              'To control your character, either tap left/right on your '
              'screen or keyboard to move and jump.',
          textRenderer: TextPaint(style: textStyle),
          anchor: Anchor.center,
          // center
          boxConfig: TextBoxConfig(
            margins: const EdgeInsets.all(4),
            timePerChar: 0.06,
            dismissDelay: 3,
          ),
        ) {
    x = camera.viewport.size.x * 0.5;
    y = camera.viewport.size.y * 0.9;
    rect = Rect.fromLTWH(0, 0, width, height);
  }

  final bgPaint = Paint()..color = Colors.blueGrey.withOpacity(0.8);
  final borderPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void update(double dt) {
    super.update(dt);
    if (finished) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(rect, bgPaint);
    canvas.drawRect(rect, borderPaint);
    super.render(canvas);
  }
}
