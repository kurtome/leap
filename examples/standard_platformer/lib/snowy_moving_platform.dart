import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/main.dart';
import 'package:tiled/tiled.dart';

class SnowyMovingPlatform extends MovingPlatform<ExamplePlatformerLeapGame> {
  SnowyMovingPlatform(super.tiledObject) : super.fromTiledObject() {
    width = 16 * 6;
    height = 16 * 2;
    priority = 2;
  }

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    super.onLoad();

    final tileset = await Flame.images.load('level_ice_tileset.png');
    final sprite = Sprite(
      tileset,
      srcPosition: Vector2(97, 64),
      srcSize: Vector2(16 * 6, 16 * 2),
    );

    add(
      SpriteComponent(
        sprite: sprite,
      ),
    );
  }
}

class SnowyMovingPlatformFactory implements TiledObjectHandler {
  @override
  void handleObject(TiledObject object, Layer layer, LeapMap map) {
    final platform = SnowyMovingPlatform(object);
    map.add(platform);
  }

  static Future<SnowyMovingPlatformFactory> createFactory() async {
    return SnowyMovingPlatformFactory();
  }
}
