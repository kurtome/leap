import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

class BasicLadder extends Ladder {
  BasicLadder(Image tileset, {required super.tiledObject})
      : super.fromTiledObject(topExtraHitbox: 4) {
    width = 16 * 2; // this is the width of our ladder sprite
    priority = 2;

    // Top sprite
    final topSprite = Sprite(
      tileset,
      srcSize: Vector2(32, 16),
      srcPosition: Vector2(0, 32),
    );
    add(
      SpriteComponent(
        sprite: topSprite,
        position: Vector2(0, topExtraHitbox),
      ),
    );

    addAll(_buildMiddleSprites(height, tileset, topExtraHitbox + 16));

    // Bottom sprite
    final bottomSprite = Sprite(
      tileset,
      srcSize: Vector2(32, 16),
      srcPosition: Vector2(0, 112),
    );
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
    double topOfMiddle,
  ) {
    final list = List<SpriteComponent>.empty(growable: true);
    final bottomOfMiddle = height - 16;
    for (var top = topOfMiddle; top < bottomOfMiddle;) {
      // This should be anywhere between one tile (16px) and 4 tiles
      var sectionHeight = bottomOfMiddle - top;
      if (sectionHeight > 16 * 4) {
        sectionHeight = sectionHeight % (16 * 4);
      }
      if (sectionHeight == 0) {
        sectionHeight = 16 * 4;
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
    final ladder = BasicLadder(tileset, tiledObject: object);
    map.add(ladder);
  }

  static Future<BasicLadderFactory> createFactory() async {
    final tileset = await Flame.images.load('level_ice_tileset.png');
    return BasicLadderFactory(tileset);
  }
}
