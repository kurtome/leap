import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

class Coin extends PhysicalEntity {
  Coin(TiledObject tiledObject, this.animation) : super(static: true) {
    width = 16;
    height = 16;
    priority = 2;

    // in Tiled we center position the Coins
    // so, we need to offset here for top-left position.
    position = Vector2(tiledObject.x - width / 2, tiledObject.y - height / 2);
    add(
      SpriteAnimationComponent(
        size: Vector2.all(20),
        position: Vector2(-2, -2),
        animation: animation,
        anchor: Anchor.topLeft,
      ),
    );
  }

  final SpriteAnimation animation;

  void collect() {
    removeFromParent();
    FlameAudio.play('coin.wav');
  }
}

class CoinFactory implements TiledObjectHandler {
  late final SpriteAnimation spriteAnimation;

  CoinFactory(this.spriteAnimation);

  @override
  void handleObject(TiledObject object, Layer layer, LeapMap map) {
    final coin = Coin(object, spriteAnimation);
    map.add(coin);
  }

  static Future<CoinFactory> createFactory() async {
    final tileset = await Flame.images.load('level_ice_tileset.png');
    final spriteAnimation = SpriteAnimation.fromFrameData(
      tileset,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.2,
        textureSize: Vector2(16, 16),
        texturePosition: Vector2(169, 8),
      ),
    );
    return CoinFactory(spriteAnimation);
  }
}
