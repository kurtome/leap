import 'package:flame/extensions.dart';
import 'package:leap/leap.dart';
import 'package:tiled/tiled.dart';

/// A vertical ladder that entities (usually the player) can climb up/down.
abstract class Ladder<T extends LeapGame> extends PhysicalEntity<T> {
  Ladder({
    super.position,
    super.size,
  }) : super(static: true, collisionType: CollisionType.standard);

  Ladder.fromTiledObject(
    TiledObject tiledObject, {
    double entranceBufferPx = 8,
  }) : this(
          position: Vector2(tiledObject.x - entranceBufferPx, tiledObject.y),
          size: Vector2(
            tiledObject.width,
            tiledObject.height + entranceBufferPx * 2,
          ),
        );

  void enter(PhysicalEntity<T> other) {
    other.tags.add(CommonTags.onLadder);
  }

  void exit(PhysicalEntity<T> other) {
    other.tags.remove(CommonTags.onLadder);
  }
}

enum MovingPlatformLoopMode {
  none,
  resetAndLoop,
  reverseAndLoop,
}
