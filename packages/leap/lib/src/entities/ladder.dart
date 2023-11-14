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
    TiledObject tiledObject,
  ) : this(
          position: Vector2(tiledObject.x, tiledObject.y),
          size: Vector2(
            tiledObject.width,
            tiledObject.height,
          ),
        );
}

class OnLadderStatus<T extends LeapGame> extends EntityStatus
    with IgnoresGravity, IgnoresGroundCollisions {
  // Singleton only
  OnLadderStatus._privateConstructor(this.ladder);

  final Ladder<T> ladder;

  static void enterLadder<T extends LeapGame>(
    PhysicalEntity<T> entity,
    Ladder<T> ladder,
  ) {
    entity.velocity.x = 0;
    entity.velocity.y = 0;
    entity.statuses.add(OnLadderStatus._privateConstructor(ladder));
  }

  static void exitLadder<T extends LeapGame>(
    PhysicalEntity<T> entity,
    OnLadderStatus<T> status,
  ) {
    entity.statuses.remove(status);
  }
}
