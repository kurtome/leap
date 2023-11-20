import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/main.dart';
import 'package:tiled/tiled.dart';

class InfoText extends PhysicalEntity<ExamplePlatformerLeapGame> {
  InfoText(TiledObject object)
      : super(
          position: Vector2(object.x, object.y),
          size: Vector2(object.width, object.height),
          collisionType: CollisionType.standard,
        ) {
    text = object.properties.getValue<String>('Text') ??
        'Lorem ipsum mising text.';
  }

  late final String text;
  TextBoxComponent? textBoxComponent;

  TextBoxComponent _buildTextBox() {
    return TextBoxComponent(
      text: text,
      // size: Vector2(160, 32),
      position: Vector2(-16, -48),
      boxConfig:
          TextBoxConfig(dismissDelay: 3, margins: const EdgeInsets.all(4)),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 8,
          backgroundColor: Colors.black.withOpacity(0.4),
        ),
      ),
    );
  }

  void activateText() {
    if (textBoxComponent == null) {
      textBoxComponent = _buildTextBox();
      add(textBoxComponent!);
    }
  }

  @override
  void update(double dt) {
    if (textBoxComponent?.finished ?? false) {
      textBoxComponent!.removeFromParent();
      textBoxComponent = null;
    }
  }
}

class InfoTextFactory implements TiledObjectHandler {
  @override
  void handleObject(TiledObject object, Layer layer, LeapMap map) {
    final component = InfoText(object);
    map.add(component);
  }
}
