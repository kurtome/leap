import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:leap/leap.dart';
import 'package:leap_standard_platformer/main.dart';
import 'package:tiled/tiled.dart';

class BasicLadder extends Ladder<ExamplePlatformerLeapGame> {
  BasicLadder(TiledObject tiledObject, Image tileset)
      : super.fromTiledObject(tiledObject) {
    width = 16 * 2; // this is the width of our ladder sprite
    height = tiledObject.height;
    priority = 2;

    // Top sprite
    final topSprite =
        Sprite(tileset, srcSize: Vector2(32, 16), srcPosition: Vector2(0, 32));
    add(
      SpriteComponent(
        sprite: topSprite,
      ),
    );

    addAll(_buildMiddleSprites(height, tileset));

    // Bottom sprite
    final bottomSprite =
        Sprite(tileset, srcSize: Vector2(32, 16), srcPosition: Vector2(0, 112));
    add(
      SpriteComponent(
        sprite: bottomSprite,
        position: Vector2(0, height - 16),
      ),
    );
  }

  static List<SpriteComponent> _buildMiddleSprites(
    double height,
    Image tileset,
  ) {
    final list = List<SpriteComponent>.empty(growable: true);
    final bottomOfMiddle = height - 16;
    for (var top = 16.0; top < bottomOfMiddle;) {
      // This should be anywhere between one tile (16px) and 4 tiles
      var sectionHeight = bottomOfMiddle - top;
      if (sectionHeight > 16 * 4) {
        sectionHeight = sectionHeight % (16 * 4);
      }
      list.add(
        SpriteComponent(
          sprite: Sprite(
            tileset,
            srcSize: Vector2(32, sectionHeight),
            srcPosition: Vector2(0, 48),
          ),
          position: Vector2(0, top),
        ),
      );
      top += sectionHeight;
    }
    return list;
  }
}

class BasicLadderFactory implements TiledObjectHandler {
  late final Image tileset;

  BasicLadderFactory(this.tileset);

  @override
  void handleObject(TiledObject object, Layer layer, LeapMap map) {
    final ladder = BasicLadder(object, tileset);
    map.add(ladder);
  }

  static Future<BasicLadderFactory> createFactory() async {
    final tileset = await Flame.images.load('level_ice_tileset.png');
    return BasicLadderFactory(tileset);
  }
}
