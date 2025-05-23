import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

class InfoText extends PhysicalEntity {
  InfoText(TiledObject object)
      : super(
          position: Vector2(object.x, object.y),
          size: Vector2(object.width, object.height),
        ) {
    text = object.properties.getValue<String>('Text') ??
        'Lorem ipsum mising text.';
  }

  late final String text;
  TextBoxComponent? textBoxComponent;

  TextBoxComponent _buildTextBox() {
    return TextBoxComponent(
      text: text,
      position: Vector2(-16, -48),
      boxConfig:
          const TextBoxConfig(dismissDelay: 3, margins: EdgeInsets.all(4)),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 8,
          backgroundColor: Colors.black.withValues(alpha: 0.4),
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
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
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
