import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

class Coin extends PhysicalEntity {
  Coin({
    required this.tiledObject,
    required this.animation,
  }) : super(static: true, collisionType: CollisionType.standard) {
    width = 16;
    height = 16;
    priority = 2;

    anchor = Anchor.center;
    position = Vector2(tiledObject.x, tiledObject.y);
    add(
      SpriteAnimationComponent(
        size: Vector2.all(20),
        position: Vector2(-2, -2),
        animation: animation,
        anchor: Anchor.topLeft,
      ),
    );
  }

  final TiledObject tiledObject;
  final SpriteAnimation animation;

  @override
  void onRemove() {
    super.onRemove();
    animation.stepTime = 0.2;
    FlameAudio.play('coin.wav');
  }

  static Future<void> loadAllInMap(LeapMap map) async {
    final objGroup = map.getTileLayer<ObjectGroup>('AnimatedCoins')!;
    final tileset = await Flame.images.load('level_ice_tileset.png');
    final spriteAnimation = SpriteAnimation.fromFrameData(
      tileset,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 2.5,
        textureSize: Vector2(16, 16),
        texturePosition: Vector2(169, 8),
      ),
    );

    // We are 100% sure that an object layer named `AnimatedCoins`
    // exists in the example `map.tmx`.
    for (final obj in objGroup.objects) {
      map.add(Coin(tiledObject: obj, animation: spriteAnimation));
    }
  }
}
