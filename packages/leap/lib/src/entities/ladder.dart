import 'package:flame/components.dart';
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

enum LadderMovingDirection {
  up,
  down,
  stopped,
}

class OnLadderStatus<T extends LeapGame> extends StatusComponent
    with HasGameReference<T>, IgnoresGravity, IgnoresGroundCollisions {
  OnLadderStatus(this.ladder);

  final Ladder<T> ladder;
  LadderMovingDirection direction = LadderMovingDirection.stopped;
  double moveSpeed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    final parentEntity = parent! as PhysicalEntity;

    if (!(parentEntity.collisionInfo.otherCollisions?.contains(ladder) ??
        false)) {
      // No longer on the ladder
      removeFromParent();
      parentEntity.velocity.y = 0;
      parentEntity.velocity.x = 0;
      parentEntity.bottom = ladder.top;
    } else {
      // Still on the ladder.

      // Center the parent and stop x movement
      parentEntity.velocity.x = 0;
      parentEntity.centerX = ladder.centerX;

      // Update ladder y movement.
      switch (direction) {
        case LadderMovingDirection.up:
          parentEntity.velocity.y = -moveSpeed;
          break;
        case LadderMovingDirection.down:
          parentEntity.velocity.y = moveSpeed;
          break;
        case LadderMovingDirection.stopped:
          parentEntity.velocity.y = 0;
          break;
        default:
      }
    }
  }

  @override
  void onMount() {
    super.onMount();
    moveSpeed = game.world.gravity / 10;
  }
}
